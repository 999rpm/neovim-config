-- Build and run, after Visual Studio's Ctrl+F5 and SpaceVim's code runner. A project owns its flags: under a Makefile,
-- make builds the default target and the run target starts the program, whichever file is open. A lone C or C++ file
-- compiles with clang, the warning flags below and the extra flags its own "// 999rpm-flags:" lines name, then runs in a
-- terminal split; scripts run through their interpreter. Every command is an argument list, so 'shell' (zsh or nushell)
-- never parses it. A failed build fills the quickfix list.
local fn = vim.fn
local api = vim.api
local core = require("utils.core")

local M = {}

---Compiler flags of every lone C and C++ build here, and the starting flags of every new project's Makefile; -g keeps
---the symbols dap.lua's codelldb reads.
---@type string[]
M.flags = { "-g", "-Wall", "-Wextra", "-Wpedantic", "-Werror", "-Wshadow", "-Wconversion" } -- This util is used by utils/project.lua, and build_cmd and set_makeprg below
local COMPILERS = { c = "clang", cpp = "clang++" }
local MAKEFILES = { "Makefile", "makefile", "GNUmakefile" }
local BUILD_FILES = vim.list_extend({ "CMakeLists.txt", "meson.build" }, MAKEFILES)
local FLAG_LINES = 10 -- only a file's first lines are read for "// 999rpm-flags:", so a long file costs nothing

---@type table<string, fun(file: string): string[]>
local INTERPRETERS = {
	python = function(file)
		if core.executable("uv") and vim.fs.root(file, { "pyproject.toml", "uv.lock" }) then
			return { "uv", "run", file } -- the project's own environment and dependencies
		end
		return { core.executable("python3") and "python3" or "python", file }
	end,
	javascript = function(file)
		return { "node", file }
	end,
	haskell = function(file)
		return { "runghc", file }
	end,
	lua = function(file)
		return { vim.v.progpath, "-l", file } -- Neovim's own LuaJIT
	end,
	sh = function(file)
		return { "sh", file }
	end,
	bash = function(file)
		return { "bash", file }
	end,
	zsh = function(file)
		return { "zsh", file }
	end,
	nu = function(file)
		return { "nu", file }
	end,
}

local term_win -- window of the last run, reused by the next one

---@param argv string[]
---@param cwd string
local function open_term(argv, cwd)
	if term_win and api.nvim_win_is_valid(term_win) then
		api.nvim_win_close(term_win, true)
	end
	vim.cmd("botright 15new")
	term_win = api.nvim_get_current_win()
	local buf = api.nvim_get_current_buf()
	fn.jobstart(argv, { term = true, cwd = cwd }) -- TermOpen (autocmds.lua) starts insert mode, so the program reads input
	vim.bo[buf].bufhidden = "wipe"
	core.map_close(buf, true)
end

---Runs a build command in cwd. Its output fills the quickfix list, which opens when the build fails and closes when it
---passes; then on_success runs.
---@param cmd string[]
---@param cwd string
---@param on_success fun()
---@param relative? boolean the output names files relative to cwd (make), so a directory line leads the list
local function build(cmd, cwd, on_success, relative)
	vim.system(cmd, { text = true, cwd = cwd }, function(res)
		vim.schedule(function()
			local output = vim.trim(table.concat({ res.stdout or "", res.stderr or "" }, "\n")) -- the command make echoes, then its errors
			local lines = output ~= "" and vim.split(output, "\n") or {}
			if relative then
				table.insert(lines, 1, ("make: Entering directory '%s'"):format(cwd)) -- the default 'errorformat' joins relative names to it
			end
			fn.setqflist({}, " ", {
				title = table.concat(cmd, " "),
				lines = lines,
				efm = vim.o.errorformat, -- the default format reads clang's file:line:col messages
			})
			if res.code ~= 0 then
				return vim.cmd("botright cwindow")
			end
			vim.cmd("cclose")
			on_success()
		end)
	end)
end

---Nearest Makefile at or above the folder, the one a build there reads.
---@param dir string
---@return string? path
function M.makefile(dir) -- This util is used by overseer.lua and run below
	return vim.fs.find(MAKEFILES, { upward = true, type = "file", path = dir })[1]
end

---True when no Makefile, CMake or meson file sits above the path: a lone source file builds on its own there.
---@param path string file or folder
---@return boolean
function M.is_lone(path) -- This util is used by overseer.lua, and run and set_makeprg below
	return vim.fs.root(path, BUILD_FILES) == nil
end

---Flags a lone C or C++ file asks for on "// 999rpm-flags:" lines among its first ten lines, split at spaces (no
---quoting), e.g. "// 999rpm-flags: -std=c++23 -lncurses". They follow the file on the command line: a library has to
---come after the code that calls it, and a later flag overrides an earlier one (-Wno-error undoes -Werror for that file).
---@param file string
---@return string[]
function M.file_flags(file) -- This util is used by build_cmd and set_makeprg below
	local ok, lines = pcall(fn.readfile, file, "", FLAG_LINES)
	local flags = {}
	for _, line in ipairs(ok and lines or {}) do
		local list = line:match("^%s*//%s*999rpm%-flags:(.*)$")
		if list then
			vim.list_extend(flags, vim.split(list, "%s+", { trimempty = true }))
		end
	end
	return flags
end

---clang command that builds one C or C++ file next to itself: the warning flags above, the file, then its own flags.
---@param file string
---@return string[]
function M.build_cmd(file) -- This util is used by overseer.lua and run below
	local compiler = COMPILERS[vim.filetype.match({ filename = file }) or ""] or "clang"
	local cmd = vim.list_extend({ compiler }, M.flags)
	vim.list_extend(cmd, { file, "-o", fn.fnamemodify(file, ":r") })
	return vim.list_extend(cmd, M.file_flags(file))
end

---Sets 'makeprg' for a C or C++ buffer outside any project with a build file, so :make compiles the file with clang and
---its 999rpm-flags lines; autocmds.lua calls it again after each write, so an edited line counts at the next :make.
---@param buf integer
function M.set_makeprg(buf) -- This util is used by autocmds.lua
	local compiler, file = COMPILERS[vim.bo[buf].filetype], api.nvim_buf_get_name(buf)
	if not compiler or file == "" or not M.is_lone(file) then
		return -- 'makeprg' stays make; CMake and meson projects set their own
	end
	local own = vim.tbl_map(fn.shellescape, M.file_flags(file)) -- 'makeprg' goes through 'shell', so each flag is quoted
	local flags = table.concat(M.flags, " ")
	vim.bo[buf].makeprg = vim.trim(("%s %s %%:S -o %%:r:S %s"):format(compiler, flags, table.concat(own, " "))) -- :S quotes a path for either shell
end

---Writes every modified file buffer under root before a project build, since make reads the whole project from disk
---('autowrite', options.lua, does the same for :make). Buffers that are not plain files, such as oil's, stay unwritten.
---@param root string
local function save_project(root)
	for _, buf in ipairs(api.nvim_list_bufs()) do
		local name = api.nvim_buf_get_name(buf)
		if vim.bo[buf].modified and vim.bo[buf].buftype == "" and vim.startswith(name, root .. "/") then
			api.nvim_buf_call(buf, function()
				vim.cmd("silent update")
			end)
		end
	end
end

---Builds a Makefile project with make's default target, then starts its run target in the terminal split: Visual
---Studio's Ctrl+F5, which builds the project and starts its program whichever file is open. The Makefile owns the flags.
---@param root string folder of the Makefile
local function run_make(root)
	if not core.executable("make") then
		return core.warn("'make' not found on $PATH.", "Run")
	end
	save_project(root)
	build({ "make" }, root, function()
		vim.system({ "make", "-q", "run" }, { cwd = root }, function(res)
			if res.code == 2 then -- -q answers 2 when no rule makes the target
				return core.warn(
					"The Makefile has no run target: <leader>wb builds it, <leader>wr picks a target.",
					"Run"
				)
			end
			vim.schedule(function()
				open_term({ "make", "-s", "run" }, root) -- -s: the terminal shows the program's output only
			end)
		end)
	end, true)
end

---Builds and runs the current buffer's program; q closes the terminal split once it ends. Rust runs through `cargo run`
---in its Cargo project; C and C++ through their Makefile project, or build_cmd above for a lone file.
function M.run() -- This util is used by mappings.lua
	local file, ft = api.nvim_buf_get_name(0), vim.bo.filetype
	if file == "" or vim.bo.buftype ~= "" then
		return core.warn("The buffer has no file to run.", "Run")
	end
	vim.cmd("silent update")
	local dir = vim.fs.dirname(file)
	if ft == "rust" then
		local root = vim.fs.root(file, { "Cargo.toml" })
		return root and open_term({ "cargo", "run", "--quiet" }, root)
			or core.warn("No Cargo.toml above this file.", "Run")
	end
	local compiler = COMPILERS[ft]
	if not compiler then
		local interpreter = INTERPRETERS[ft]
		if not interpreter then
			return core.warn(("No runner for filetype %q."):format(ft), "Run")
		end
		return open_term(interpreter(file), dir)
	end
	local makefile = M.makefile(dir)
	if makefile then
		return run_make(vim.fs.dirname(makefile))
	elseif not M.is_lone(file) then
		return core.warn(
			"CMake and meson projects have no runner here; <leader>cr runs Makefile projects and lone files.",
			"Run"
		)
	end
	if not core.executable(compiler) then
		return core.warn(("'%s' not found on $PATH."):format(compiler), "Run")
	end
	build(M.build_cmd(file), dir, function()
		open_term({ fn.fnamemodify(file, ":r") }, dir)
	end)
end

return M
