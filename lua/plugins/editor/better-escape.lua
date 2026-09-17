-- max397574/better-escape.nvim: jj/jk leave insert and cmdline mode, jk leaves visual and select mode.
return {
	"max397574/better-escape.nvim",
	event = "InsertEnter",
	opts = {
		timeout = vim.o.timeoutlen,
		default_mappings = false, -- the defaults also map j in terminal mode, which breaks j/k in lazygit and yazi
		mappings = {
			i = { j = { k = "<Esc>", j = "<Esc>" } },
			c = { j = { k = "<C-c>", j = "<C-c>" } },
			v = { j = { k = "<Esc>" } },
			s = { j = { k = "<Esc>" } },
		},
	},
}
