-- Build and run the current file, after SpaceVim's code runner: C and C++ compile with clang and the warning flags
-- below, then the program runs in a terminal split; scripts run through their interpreter. Every command is an argument
-- list, so 'shell' (zsh or nushell) never parses it. A failed build fills the quickfix list.
local fn = vim.fn
local api = vim.api
local core = require("utils.core")

local M = {}

---Compiler flags of every C and C++ build here; -g keeps the symbols dap.lua's codelldb reads.
---@type string[]
M.flags = { "-g", "-Wall", "-Wextra", "-Wpedantic", "-Werror", "-Wshadow", "-Wconversion" } -- This util is used by utils/project.lua, and build_cmd and set_makeprg below
local COMPILERS = { c = "clang", cpp = "clang++" }
local BUILD_FILES = { "Makefile", "makefile", "GNUmakefile", "CMakeLists.txt", "meson.build" }

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

---True for a folder with no Makefile, CMake or meson file above it: a lone source file builds on its own there.
---@param dir string
---@return boolean
function M.is_lone(dir) -- This util is used by overseer.lua and set_makeprg below
	return vim.fs.root(dir, BUILD_FILES) == nil
end

---clang command that builds one C or C++ file next to itself, with the warning flags above.
---@param file string
---@return string[]
function M.build_cmd(file) -- This util is used by overseer.lua and run below
	local compiler = COMPILERS[vim.filetype.match({ filename = file }) or ""] or "clang"
	return vim.list_extend(vim.list_extend({ compiler }, M.flags), { file, "-o", fn.fnamemodify(file, ":r") })
end

---Sets 'makeprg' for a C or C++ buffer outside any project with a build file, so :make compiles the file with clang.
---@param buf integer
function M.set_makeprg(buf) -- This util is used by autocmds.lua
	local compiler = COMPILERS[vim.bo[buf].filetype]
	if not compiler or not M.is_lone(api.nvim_buf_get_name(buf)) then
		return -- 'makeprg' stays make; CMake and meson projects set their own
	end
	vim.bo[buf].makeprg = ("%s %s %%:S -o %%:r:S"):format(compiler, table.concat(M.flags, " ")) -- :S quotes a path for either shell
end

---Builds the current file when it is C or C++, then runs it in a terminal split; q closes the split once the program
---ends. Rust runs through `cargo run` in its Cargo project.
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
	if not core.executable(compiler) then
		return core.warn(("'%s' not found on $PATH."):format(compiler), "Run")
	end
	local cmd = M.build_cmd(file)
	local out = cmd[#cmd]
	vim.system(cmd, { text = true, cwd = dir }, function(res)
		vim.schedule(function()
			local output = vim.trim((res.stderr or "") .. (res.stdout or ""))
			fn.setqflist({}, " ", {
				title = table.concat(cmd, " "),
				lines = output ~= "" and vim.split(output, "\n") or {},
				efm = vim.o.errorformat, -- the default format reads clang's file:line:col messages
			})
			if res.code ~= 0 then
				return vim.cmd("botright cwindow")
			end
			vim.cmd("cclose")
			open_term({ out }, dir)
		end)
	end)
end

return M
