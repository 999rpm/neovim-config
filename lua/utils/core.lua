-- Helpers most files share. Every entry names the files that call it, so a helper with no caller shows up as dead code.
local fn = vim.fn
local api = vim.api

local M = {}

---@param name string
---@return boolean
function M.executable(name) -- This util is used by autocmds.lua, lazy.lua, lint.lua, lspconfig.lua, mason.lua, options.lua, package-info.lua, shared.lua, treesitter.lua, yazi.lua, utils/d2.lua, utils/notes.lua, utils/jupyter.lua, utils/project.lua and utils/run.lua
	return fn.executable(name) > 0
end

---@param dir string
function M.may_create_dir(dir) -- This util is used by autocmds.lua, options.lua, utils/d2.lua, utils/notes.lua and utils/project.lua
	if fn.isdirectory(dir) == 0 then
		fn.mkdir(dir, "p")
	end
end

---Scheduled warning, safe inside vim.system and libuv callbacks.
---@param msg string
---@param title string
function M.warn(msg, title) -- This util is used by utils/debugger.lua, utils/d2.lua, utils/notes.lua, utils/jupyter.lua, utils/notebook.lua, utils/project.lua, utils/run.lua and utils/themes.lua
	vim.schedule(function()
		vim.notify(msg, vim.log.levels.WARN, { title = title })
	end)
end

---@param var_name string
---@param label string
function M.warn_if_missing_env(var_name, label) -- This util is used by avante.lua
	if (vim.env[var_name] or "") == "" then
		M.warn(("%s is not set; %s will fail on first use."):format(var_name, label), label)
	end
end

---@param name string executable looked up on $PATH
---@param label string
---@param hint string
---@return boolean found
function M.warn_if_missing_exec(name, label, hint) -- This util is used by hex.lua, octo.lua, treesitter.lua and yazi.lua
	if M.executable(name) then
		return true
	end
	M.warn(("'%s' not found on $PATH. %s"):format(name, hint), label)
	return false
end

---Runs argv lists one after another through vim.system, in cwd; the first failure is reported and ends the chain.
---@param steps string[][]
---@param cwd string
---@param title string notification title
---@param on_done fun()
function M.run_chain(steps, cwd, title, on_done) -- This util is used by utils/jupyter.lua and utils/project.lua
	local i = 0
	local function next_step()
		i = i + 1
		if not steps[i] then
			return on_done()
		end
		local ok, err = pcall(vim.system, steps[i], { text = true, cwd = cwd }, function(res)
			if res.code ~= 0 then
				return M.warn(vim.trim((res.stderr or "") .. (res.stdout or "")), title)
			end
			vim.schedule(next_step)
		end)
		if not ok then
			M.warn(tostring(err), title) -- vim.system raises when the executable is missing
		end
	end
	next_step()
end

---Augroup named "999rpm-<name>", so :autocmd 999rpm-* lists every group of this config.
---@param name string
---@param clear? boolean defaults to true
---@return integer
function M.augroup(name, clear) -- This util is used by autocmds.lua, ipynb.lua, lint.lua, logseq.lua, lspconfig.lua, lualine.lua, markdown-plus.lua, molten.lua, nvim-bqf.lua, oil.lua, package-info.lua, persistence.lua, treesitter.lua, utils/notebook.lua and on_colorscheme below
	return api.nvim_create_augroup("999rpm-" .. name:gsub("_", "-"), { clear = clear ~= false })
end

---Runs `apply` now and after every colorscheme change, so highlight overrides survive a theme switch.
---@param name string augroup suffix
---@param apply fun()
function M.on_colorscheme(name, apply) -- This util is used by barbar.lua, dap.lua, logseq.lua, multicursor.lua and render-markdown.lua
	apply()
	api.nvim_create_autocmd("ColorScheme", {
		group = M.augroup(name),
		desc = "999rpm: re-apply " .. name .. " after a theme switch",
		callback = apply,
	})
end

---Binds q to close a throwaway window, and wipe its buffer where nothing else holds it.
---@param buf integer
---@param wipe? boolean also delete the buffer, defaults to false
function M.map_close(buf, wipe) -- This util is used by autocmds.lua, utils/d2.lua and utils/run.lua
	if not api.nvim_buf_is_valid(buf) then
		return -- autocmds.lua calls this through vim.schedule, and the buffer can be wiped before the callback runs
	end
	vim.keymap.set("n", "q", function()
		pcall(vim.cmd.close) -- the last window cannot close; the buffer still goes
		if wipe then
			pcall(api.nvim_buf_delete, buf, { force = true })
		end
	end, { buf = buf, silent = true, desc = "Close" })
end

---Tab/S-Tab move through the entries of one list buffer, as in the picker, Trouble and dropbar.
---@param buf integer
function M.menu_nav(buf) -- This util is used by harpoon.lua and nvim-bqf.lua
	vim.keymap.set("n", "<Tab>", "j", { buf = buf, desc = "Next entry" })
	vim.keymap.set("n", "<S-Tab>", "k", { buf = buf, desc = "Previous entry" })
end

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

return M
