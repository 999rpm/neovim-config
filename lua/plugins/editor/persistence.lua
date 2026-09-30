-- folke/persistence.nvim: per-directory, per-branch session files.
-- Keys: <leader>qs restore this directory, qS pick a session, ql restore the last one, qd stop saving this session.
return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- only start tracking once a real file's open, not on a bare `nvim` with no args
	opts = {
		branch = true,
	},
	keys = {
		{
			"<leader>qs",
			function()
				require("persistence").load()
			end,
			desc = "Restore session for this directory",
		},
		{
			"<leader>qS",
			function()
				require("persistence").select()
			end,
			desc = "Select session",
		},
		{
			"<leader>ql",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "Restore last session",
		},
		{
			"<leader>qd",
			function()
				require("persistence").stop()
			end,
			desc = "Stop saving this session",
		},
	},
}
