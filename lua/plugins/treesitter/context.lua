-- nvim-treesitter/nvim-treesitter-context: pins the enclosing function or class to the top of the window. Owns [u and
-- <leader>oc.
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		max_lines = 3,
	},
	keys = {
		{
			"<leader>oc",
			function()
				require("treesitter-context").toggle()
			end,
			desc = "Toggle treesitter context",
		}, -- n: the pinned lines at the top of the window on or off (c for context)
		{
			"[u",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "Jump to upper context",
			silent = true,
		}, -- n: up to the line the pinned context starts at; a count goes further out (u for up)
	},
}
