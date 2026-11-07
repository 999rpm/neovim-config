-- folke/persistence.nvim: per-directory, per-branch session files. Before each save it fires User SessionSavePre,
-- which barbar.lua answers by storing the tabline's buffer order and pins in the session. Owns <leader>qs, <leader>qS,
-- <leader>ql and <leader>qd.
return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- tracking starts with the first real file, not on a bare `nvim`
	opts = {},
	keys = {
		{
			"<leader>qs",
			function()
				require("persistence").load()
			end,
			desc = "Restore session for this directory",
		}, -- n: the windows and buffers last open in the working directory, on this git branch
		{
			"<leader>qS",
			function()
				require("persistence").select()
			end,
			desc = "Select session",
		}, -- n: a picker over every saved session
		{
			"<leader>ql",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "Restore last session",
		}, -- n: the most recent session, whatever the working directory
		{
			"<leader>qd",
			function()
				require("persistence").stop()
			end,
			desc = "Stop saving this session",
		}, -- n: quitting no longer writes this session; the saved one stays as it was
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
