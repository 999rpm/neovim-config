-- chrisgrieser/nvim-scissors: add/edit VS-Code-format JSON snippets from a small popup, instead
-- of hand-editing snippet JSON files directly. Requires VS-Code-style snippet files specifically
-- (its own README) — friendly-snippets (plugins/completion/blink.lua's dependency) already ships
-- in exactly that format, so this is a compatible extension of what's already there, not a
-- second, incompatible snippet system.
--
-- `snippetDir` below must be the SAME path blink.lua's snippets provider searches, or snippets
-- created here would be invisible to actual completion — see that file's own matching note.
return {
	"chrisgrieser/nvim-scissors",
	dependencies = { "nvim-telescope/telescope.nvim" },
	opts = {
		snippetDir = vim.fn.stdpath("config") .. "/snippets",
	},
	keys = {
		{
			"<leader>csa",
			function()
				require("scissors").addNewSnippet()
			end,
			mode = { "n", "x" },
			desc = "Add Snippet",
		},
		{
			"<leader>cse",
			function()
				require("scissors").editSnippet()
			end,
			desc = "Edit Snippet",
		},
	},
}
