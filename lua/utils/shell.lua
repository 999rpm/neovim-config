-- Shell helpers: the login shell and the shell* flags that match it (zsh and other POSIX shells, csh, nushell).
local fn = vim.fn

local M = {}

local nu_shell_options = { -- nushell/integrations values, except shellpipe
	shellcmdflag = "--stdin --no-newline -c", -- --stdin feeds :%!filter text to the command; no --login, so :! skips env.nu and config.nu
	shellredir = "out+err> %s",
	shellpipe = "| complete | update stderr { ansi strip } | do {|r| [$r.stdout $r.stderr] | str join | ansi strip | save --force --raw %s; $r } $in", -- do, not tee: tee's closure runs in parallel and nu exits before it writes the errorfile
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

---Sets the shell* options that match 'shell': nushell's for nu, Vim's own shell-family values otherwise.
function M.apply_shell_options() -- This util is used by autocmds.lua and options.lua
	local name = fn.fnamemodify(vim.o.shell, ":t")
	local set = name == "nu" and nu_shell_options or (name:match("csh$") and csh_shell_options or posix_shell_options)
	for option, value in pairs(set) do
		vim.o[option] = value
	end
end

return M
