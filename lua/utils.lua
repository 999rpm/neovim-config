-- Shared helpers. Every entry names the files that call it.
local fn = vim.fn
local api = vim.api

local M = {}

---@param dir string
function M.may_create_dir(dir) -- This util is used by autocmds.lua
	if fn.isdirectory(dir) == 0 then
		fn.mkdir(dir, "p")
	end
end

---@param name string
---@return boolean
function M.executable(name) -- This util is used by options.lua, lspconfig.lua, treesitter.lua, lint.lua, copilot.lua, yazi.lua and mcphub.lua
	return fn.executable(name) > 0
end

---Leading-edge throttle: calls inside the window are dropped, not queued.
---@param callback fun()
---@param ms integer
---@return fun()
function M.throttle(callback, ms) -- This util is used by lualine.lua
	local last = 0
	return function()
		local now = vim.uv.now()
		if now - last < ms then
			return
		end
		last = now
		callback()
	end
end

---@param msg string
---@param title string
local function warn(msg, title)
	vim.schedule(function()
		vim.notify(msg, vim.log.levels.WARN, { title = title })
	end)
end

---@param path string absolute path of a Mason-installed file
---@param label string Mason package name
function M.warn_if_missing_mason_bin(path, label) -- This util is used by dap.lua and dap-python.lua
	if not vim.uv.fs_stat(path) then
		warn(("%s not found at %s. Check :Mason or :MasonLog, then run :MasonInstall %s."):format(label, path, label), "DAP")
	end
end

---@param var_name string
---@param label string
function M.warn_if_missing_env(var_name, label) -- This util is used by avante.lua
	if (vim.env[var_name] or "") == "" then
		warn(("%s is not set; %s will fail on first use."):format(var_name, label), label)
	end
end

---@param name string executable looked up on $PATH
---@param label string
---@param hint string
function M.warn_if_missing_exec(name, label, hint) -- This util is used by octo.lua, yazi.lua, treesitter.lua and hex.lua
	if not M.executable(name) then
		warn(("'%s' not found on $PATH. %s"):format(name, hint), label)
	end
end

---Augroup namespaced as "999rpm-<name>".
---@param name string
---@param clear? boolean defaults to true
---@return integer
function M.augroup(name, clear) -- This util is used by autocmds.lua, lspconfig.lua, treesitter.lua, lint.lua, dap.lua, lualine.lua and nvim-bqf.lua
	return api.nvim_create_augroup("999rpm-" .. name:gsub("_", "-"), { clear = clear ~= false })
end

---Binds the shared list-menu navigation (Tab/S-Tab) in one buffer, matching the picker, Trouble and dropbar.
---@param buf integer
function M.menu_nav(buf) -- This util is used by nvim-bqf.lua and harpoon.lua
	vim.keymap.set("n", "<Tab>", "j", { buf = buf, desc = "Next entry" })
	vim.keymap.set("n", "<S-Tab>", "k", { buf = buf, desc = "Previous entry" })
end

-- Shell

local nu_shell_options = { -- values from nushell/integrations (nvim/init.lua)
	shellcmdflag = "--login --stdin --no-newline -c",
	shellredir = "out+err> %s",
	shellpipe = "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record",
	shellquote = "",
	shellxquote = "",
	shellxescape = "",
	shelltemp = false,
}

local posix_shell_options = {
	shellcmdflag = "-c",
	shellredir = ">%s 2>&1",
	shellpipe = "2>&1| tee",
	shellquote = "",
	shellxquote = "",
	shellxescape = "",
	shelltemp = false,
}

local csh_shell_options = vim.tbl_extend("force", posix_shell_options, { shellpipe = "|& tee", shellredir = ">&" })

---Login shell from the passwd database (follows chsh without a new login), then $SHELL, then sh.
---@return string
function M.login_shell() -- This util is used by options.lua
	local ok, passwd = pcall(vim.uv.os_get_passwd)
	for _, shell in ipairs({ ok and passwd and passwd.shell or "", vim.env.SHELL or "" }) do
		if shell ~= "" and fn.executable(shell) == 1 then
			return shell
		end
	end
	return "sh"
end

---Set the shell* options that match 'shell': nushell values for nu, Vim's own shell-family values otherwise.
function M.apply_shell_options() -- This util is used by options.lua and autocmds.lua
	local name = fn.fnamemodify(vim.o.shell, ":t")
	local set = name == "nu" and nu_shell_options or (name:match("csh$") and csh_shell_options or posix_shell_options)
	for option, value in pairs(set) do
		vim.o[option] = value
	end
end

---Run a Lua function as a terminal-mode window move; floating windows get the key instead.
---@param dir "h"|"j"|"k"|"l"
---@param key string
---@return fun(): string
function M.term_wincmd(dir, key) -- This util is used by mappings.lua
	return function()
		if api.nvim_win_get_config(0).relative ~= "" then
			return key
		end
		return "<Cmd>wincmd " .. dir .. "<CR>"
	end
end

---Per-buffer memo keyed on b:changetick, so a statusline component scans a buffer once per edit, not once per redraw.
---@generic T
---@param key string
---@param compute fun(): T
---@return T
function M.buf_cached(key, compute) -- This util is used by lualine.lua
	local buf = api.nvim_get_current_buf()
	local tick = api.nvim_buf_get_changedtick(buf)
	local store = vim.b[buf]._999rpm_cache or {}
	local hit = store[key]
	if hit and hit.tick == tick then
		return hit.value
	end
	local value = compute()
	store[key] = { tick = tick, value = value }
	vim.b[buf]._999rpm_cache = store -- reassigned whole: vim.b returns a copy, so mutating `store` alone does not persist
	return value
end

-- Git

---@param cmd string[]
---@return string?
local function run_git(cmd)
	local out = fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		return nil
	end
	return vim.trim(out)
end

---Branch for the current buffer: gitsigns' cached head, else one cached `git rev-parse` per buffer.
---@return string
function M.get_current_branch_name() -- This util is used by options.lua
	local head = vim.tbl_get(vim.b, "gitsigns_status_dict", "head")
	if head and head ~= "" then
		return head
	end
	local cached = vim.b._999rpm_branch
	if cached == nil then
		local dir = fn.expand("%:p:h")
		cached = fn.isdirectory(dir) == 1 and (run_git({ "git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" }) or "") or ""
		if cached == "HEAD" then
			cached = run_git({ "git", "-C", dir, "rev-parse", "--short", "HEAD" }) or cached
		end
		vim.b._999rpm_branch = cached
	end
	return cached
end

-- LSP

---Client capabilities with folding ranges (nvim-ufo) and blink.cmp completion.
---@return lsp.ClientCapabilities
function M.get_lsp_capabilities() -- This util is used by lspconfig.lua
	local caps = vim.lsp.protocol.make_client_capabilities()
	caps.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
	local ok, blink = pcall(require, "blink.cmp")
	return ok and blink.get_lsp_capabilities(caps) or caps
end

---Registers the "virtual_lines_rounded" diagnostic handler: the built-in virtual_lines for the
---cursor line only, drawn with a rounded corner.
function M.setup_rounded_virtual_lines() -- This util is used by lspconfig.lua
	local builtin = vim.diagnostic.handlers.virtual_lines
	local state = {} ---@type table<integer, table<integer, {diagnostics: vim.Diagnostic[], opts: table, lnum?: integer}>>
	local group = api.nvim_create_augroup("999rpm-virtual-lines", { clear = true })

	local function round(namespace, bufnr)
		local vl_ns = vim.diagnostic.get_namespace(namespace).user_data.virt_lines_ns
		if not vl_ns then
			return
		end
		for _, mark in ipairs(api.nvim_buf_get_extmarks(bufnr, vl_ns, 0, -1, { details = true })) do
			local lines = mark[4].virt_lines
			if lines then
				for _, line in ipairs(lines) do
					for _, chunk in ipairs(line) do
						chunk[1] = chunk[1]:gsub("└", "╰")
					end
				end
				api.nvim_buf_set_extmark(bufnr, vl_ns, mark[2], mark[3], {
					id = mark[1],
					virt_lines = lines,
					virt_lines_overflow = "scroll",
				})
			end
		end
	end

	local function render(namespace, bufnr, force)
		local entry = state[namespace] and state[namespace][bufnr]
		local win = fn.bufwinid(bufnr)
		if not entry or win == -1 then
			return
		end
		local lnum = api.nvim_win_get_cursor(win)[1] - 1
		if lnum == entry.lnum and not force then
			return
		end
		entry.lnum = lnum
		local on_line, spanning = {}, {}
		for _, d in ipairs(entry.diagnostics) do
			if d.lnum == lnum then
				table.insert(on_line, d)
			elseif lnum > d.lnum and lnum <= (d.end_lnum or d.lnum) then
				table.insert(spanning, d)
			end
		end
		local opts = vim.tbl_extend("force", entry.opts, {
			virtual_lines = { current_line = false, format = entry.opts.virtual_lines_rounded.format },
		})
		builtin.show(namespace, bufnr, #on_line > 0 and on_line or spanning, opts)
		round(namespace, bufnr)
	end

	vim.diagnostic.handlers.virtual_lines_rounded = {
		show = function(namespace, bufnr, diagnostics, opts)
			state[namespace] = state[namespace] or {}
			state[namespace][bufnr] = { diagnostics = diagnostics, opts = opts }
			if not vim.b[bufnr]._999rpm_vlines then
				vim.b[bufnr]._999rpm_vlines = true
				api.nvim_create_autocmd("CursorMoved", {
					group = group,
					buf = bufnr,
					desc = "999rpm: redraw rounded virtual lines for the cursor line",
					callback = function()
						for ns in pairs(state) do
							render(ns, bufnr, false)
						end
					end,
				})
			end
			render(namespace, bufnr, true)
		end,
		hide = function(namespace, bufnr)
			if state[namespace] then
				state[namespace][bufnr] = nil
			end
			builtin.hide(namespace, bufnr)
		end,
	}
end

-- Theming

---RainbowDelimiter groups, in rainbow-delimiters' own order. Colors follow the active theme.
---@type string[]
M.rainbow_delimiter_groups = { -- This util is used by rainbow-delimiters.lua and snacks.lua
	"RainbowDelimiterRed",
	"RainbowDelimiterYellow",
	"RainbowDelimiterBlue",
	"RainbowDelimiterOrange",
	"RainbowDelimiterGreen",
	"RainbowDelimiterViolet",
	"RainbowDelimiterCyan",
}

---Active Python virtual environment (venv before conda), or "".
---@return string
function M.get_virtual_env() -- This util is used by lualine.lua
	local venv = os.getenv("VIRTUAL_ENV")
	if venv then
		return fn.fnamemodify(venv, ":t")
	end
	return os.getenv("CONDA_DEFAULT_ENV") or ""
end

return M
