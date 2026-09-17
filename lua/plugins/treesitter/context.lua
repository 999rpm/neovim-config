-- nvim-treesitter-context: pins the enclosing function or class to the top of the window. [u jumps to it.
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		enable = true,
		max_lines = 3,
		mode = "cursor",
		trim_scope = "outer",
	},
	keys = {
		{
			"<leader>oc",
			function()
				require("treesitter-context").toggle()
			end,
			desc = "Toggle TS Context",
		},
		{
			"[u",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "Jump to upper context",
			silent = true,
		},
	},
}
