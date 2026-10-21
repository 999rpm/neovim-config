-- Wansmer/treesj: split or join a node across lines. <leader>cj toggles between the two, which is the only key it owns
-- (<leader>cs is the snippets group). :TSJSplit and :TSJJoin force one direction.
return {
	"Wansmer/treesj",
	keys = {
		{
			"<leader>cj",
			function()
				require("treesj").toggle()
			end,
			desc = "Split or join node",
		}, -- n: the treesitter node under the cursor from one line to several, or back (j for join)
	},
	opts = {
		use_default_keymaps = false, -- keymap lives above, in this config's own Code group
	},
}
