-- folke/persistence.nvim: auto-saves a session per working directory on exit, restore on
-- demand. options.lua already trims `sessionoptions` (drops blank/buffers/terminal) for exactly
-- this — this file is the first thing in this config that actually calls :mksession/:source
-- against it. `branch = true` keeps a separate session per git branch, so switching branches in
-- the same worktree doesn't clobber another branch's window layout.
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
