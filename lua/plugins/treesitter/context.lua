-- nvim-treesitter/nvim-treesitter-context: sticky "current function/class" header at the top
-- of the window as you scroll past its start. Has both `event` (loads passively on buffer
-- read, since the header should just appear without a manual keypress) and `keys` (the
-- toggle + jump-to-context commands) — a plugin whose whole point is a passive header
-- shouldn't need a toggle-flavored keypress just to turn on for the first time in a session.
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
			"<leader>tx",
			function()
				require("treesitter-context").toggle()
			end,
			desc = "Toggle TS Context",
		},
		{
			"[x",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "Jump to upper context",
			silent = true,
		},
	},
}
