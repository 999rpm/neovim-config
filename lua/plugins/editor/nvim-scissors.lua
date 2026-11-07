-- chrisgrieser/nvim-scissors: add and edit VS Code style snippets in stdpath("config")/snippets, which blink reads.
-- Owns <leader>csa and <leader>cse, in which-key.lua's snippets group.
return {
	"chrisgrieser/nvim-scissors",
	opts = {
		snippetSelection = { picker = "snacks" },
	},
	-- scissors' own keys in its editor popup: (n) <CR> or :w save, q cancel, <BS> back to the list, <C-BS> delete,
	-- <C-d> duplicate, <C-o> open the snippet file, ? help; (n/i) <C-p> insert the next placeholder.
	keys = {
		{
			"<leader>csa",
			function()
				require("scissors").addNewSnippet()
			end,
			mode = { "n", "x" },
			desc = "Add snippet",
		}, -- n/x: a new snippet for this filetype, the selected text as its body
		{
			"<leader>cse",
			function()
				require("scissors").editSnippet()
			end,
			desc = "Edit snippet",
		}, -- n: pick one of the snippets and change it in a popup
	},
}
