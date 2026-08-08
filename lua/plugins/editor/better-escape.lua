-- max397574/better-escape.nvim: leave insert/terminal/visual/select/cmdline mode by typing
-- "jj" or "jk" instead of reaching for Escape, without the usual timeoutlen delay on the
-- first of the two keys.
return {
	"max397574/better-escape.nvim",
	event = "InsertEnter",
	config = function()
		require("better_escape").setup({
			timeout = vim.o.timeoutlen, -- after `timeout` passes, pressing the escape key is left alone
			default_mappings = true,
			mappings = {
				i = {
					j = {
						k = "<Esc>",
						j = "<Esc>",
					},
				},
				c = {
					j = {
						k = "<C-c>",
						j = "<C-c>",
					},
				},
				t = {
					j = {
						k = "<C-\\><C-n>",
					},
				},
				v = {
					j = {
						k = "<Esc>",
					},
				},
				s = {
					j = {
						k = "<Esc>",
					},
				},
			},
		})
	end,
}
