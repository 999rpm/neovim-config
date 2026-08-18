-- Wansmer/treesj: treesitter-aware smart join/split for any language it has a parser for —
-- toggle between "one line" and "multi-line, one item per line" for the node under the cursor
-- (function args, object literals, arrays, etc). Complements native `J` (line join, untouched)
-- rather than replacing it — `J` still does its own always-available thing.
return {
	"Wansmer/treesj",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	keys = {
		{
			"<leader>cj",
			function()
				require("treesj").toggle()
			end,
			desc = "Toggle Split/Join",
		},
	},
	opts = {
		use_default_keymaps = false, -- keymap lives above, in this config's own Code group
		max_join_length = 120,
	},
}
