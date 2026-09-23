-- Wansmer/treesj: split or join a node across lines. <leader>cj toggles between the two, which is the only key it owns
-- (<leader>cs is the snippets group). :TSJSplit and :TSJJoin force one direction.
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
