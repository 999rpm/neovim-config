-- folke/persistence.nvim: per-directory, per-branch session files under <leader>q.
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
			desc = "Restore Session (cwd)",
		},
		{
			"<leader>qS",
			function()
				require("persistence").select()
			end,
			desc = "Select Session",
		},
		{
			"<leader>ql",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "Restore Last Session",
		},
		{
			"<leader>qd",
			function()
				require("persistence").stop()
			end,
			desc = "Don't Save Current Session",
		},
	},
}
