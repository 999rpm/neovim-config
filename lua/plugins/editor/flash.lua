-- folke/flash.nvim: jump to any visible position by typing the label shown there. f/F/t/T and their ;/, repeats stay built-in.
-- Keys: <leader>j jump, <leader>J select a treesitter node, r remote action and R treesitter search (both after an operator,
-- as in yr or dR), <C-s> toggle labels while typing a / or ? search.
return {
	"folke/flash.nvim",
	opts = {
		modes = {
			char = { enabled = false }, -- f/F/t/T stay the built-in character search
		},
	},
	keys = {
		{
			"<leader>j",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Jump (flash)",
		},
		{
			"<leader>J",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Select node (flash)",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote flash",
		},
		{
			"R",
			mode = "o",
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter search",
		},
		{
			"<C-s>",
			mode = "c",
			function()
				require("flash").toggle()
			end,
			desc = "Toggle flash search",
		},
	},
}
