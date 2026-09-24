-- chrisgrieser/nvim-scissors: add and edit VS Code style snippets in stdpath("config")/snippets, which blink.lua reads.
-- Keys: <leader>csa add, <leader>cse edit. In the editor popup: <CR> or :w save, q cancel, <BS> back to the list,
-- <C-BS> delete, <C-d> duplicate, <C-o> open the snippet file, <C-p> insert the next placeholder, ? help.
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
