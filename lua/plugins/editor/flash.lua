-- folke/flash.nvim: jump to any visible position by label. f/F/t/T and / keep working as usual.
-- Keys: s jump, S treesitter select, r remote (operator), R treesitter search, <C-s> toggle in search.
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		modes = {
			char = {
				enabled = false, -- stop flash from hooking f/F/t/T internally
			},
		},
	},
	keys = {
		{
			"f",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash",
		},
		{
			"F",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter Search",
		},
		{
			"<C-s>",
			mode = { "c" },
			function()
				require("flash").toggle()
			end,
			desc = "Toggle Flash Search",
		},
	},
}
