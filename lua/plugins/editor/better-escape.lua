-- max397574/better-escape.nvim: jj/jk leave insert and command-line mode. Visual mode keeps j fast and hardtime's count;
-- <Esc> or <leader><leader> leaves it.
return {
	"max397574/better-escape.nvim",
	event = "InsertEnter",
	opts = {
		timeout = vim.o.timeoutlen,
		default_mappings = false, -- the defaults also map j in terminal mode, which breaks j/k in lazygit and yazi
		mappings = {
			i = { j = { k = "<Esc>", j = "<Esc>" } },
			c = { j = { k = "<C-c>", j = "<C-c>" } }, -- no v/s entries: mapping j there replaces hardtime's own visual j
		},
	},
}
