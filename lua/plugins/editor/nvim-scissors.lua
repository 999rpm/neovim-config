-- chrisgrieser/nvim-scissors: add and edit VS Code style snippets in stdpath("config")/snippets, which blink.lua reads.
return {
	"chrisgrieser/nvim-scissors",
	opts = {
		snippetDir = vim.fn.stdpath("config") .. "/snippets",
		snippetSelection = { picker = "snacks" },
	},
	keys = {
		{
			"<leader>csa",
			function()
				require("scissors").addNewSnippet()
			end,
			mode = { "n", "x" },
			desc = "Add snippet",
		},
		{
			"<leader>cse",
			function()
				require("scissors").editSnippet()
			end,
			desc = "Edit snippet",
		},
	},
}
