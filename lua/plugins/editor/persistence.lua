-- folke/persistence.nvim: per-directory, per-branch session files. Before each save it fires User SessionSavePre,
-- which barbar.lua answers by storing the tabline's buffer order and pins in the session.
-- Keys: <leader>qs restore this directory, qS pick a session, ql restore the last one, qd stop saving this session.
return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- tracking starts with the first real file, not on a bare `nvim`
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
	config = function(_, opts)
		require("persistence").setup(opts)
		vim.api.nvim_create_autocmd("User", {
			group = require("utils.core").augroup("session-save"),
			pattern = "PersistenceSavePre",
			desc = "999rpm: let barbar store buffer order and pins before the session is written",
			callback = function()
				vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })
			end,
		})
	end,
}
