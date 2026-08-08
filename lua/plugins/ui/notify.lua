-- rcarriga/nvim-notify: the toast/popup notification backend noice.lua routes `vim.notify`
-- through (see that file's own header). No trigger of its own on purpose: noice.lua also has
-- no event/cmd/ft/keys (it needs to be active from very early in a session to catch startup
-- messages), so both fall back to lazy.lua's global `lazy = false` default and load eagerly.
return {
	"rcarriga/nvim-notify",
	opts = {
		icons = {
			ERROR = "",
			WARN = "",
			INFO = "",
			DEBUG = "",
			TRACE = "",
		},
	},
}
