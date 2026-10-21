-- Shells: 'shell' is sh whatever the login shell is (options.lua), since :!, :make, :grep and plugins build sh syntax;
-- the login shell (zsh, nushell or any other) runs where a person types: snacks.lua's terminals and a bare :terminal.
local M = {}

---Login shell from the passwd database (follows chsh without a new login), then $SHELL, then sh.
---@return string
function M.login_shell() -- This util is used by snacks.lua and terminal_login_shell below
	local ok, passwd = pcall(vim.uv.os_get_passwd) -- raises where the platform has no passwd database
	for _, shell in ipairs({ ok and passwd and passwd.shell or "", vim.env.SHELL or "" }) do
		if shell ~= "" and vim.fn.executable(shell) == 1 then
			return shell
		end
	end
	return "sh"
end

---CmdlineLeave handler: a bare :terminal (modifiers and a range allowed, no command) runs the login shell. 'shell'
---holds it while the command runs and gets sh back right after, so :! and :make never see the login shell.
function M.terminal_login_shell() -- This util is used by autocmds.lua
	if vim.v.event.abort then
		return
	end
	local ok, cmd = pcall(vim.api.nvim_parse_cmd, vim.fn.getcmdline(), {}) -- raises on a line that is not a command
	if not (ok and cmd.cmd == "terminal" and #cmd.args == 0) then
		return
	end
	local posix = vim.o.shell
	vim.o.shell = M.login_shell()
	vim.schedule(function() -- runs once the :terminal command has started its job
		vim.o.shell = posix
	end)
end

return M
