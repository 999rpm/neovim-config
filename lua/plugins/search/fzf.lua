-- ibhagwan/fzf-lua: fast fzf-backed pickers for the handful of lookups (files/grep/buffers/
-- recent/git) where raw speed matters more than plugins/search/telescope.lua's broader
-- picker/LSP coverage — see that file's own header for why both are kept.
return {
	"ibhagwan/fzf-lua",
	dependencies = { "echasnovski/mini.nvim" },

	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Files" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
		{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent Files" },
		{ "<leader>fc", "<cmd>FzfLua git_commits<cr>", desc = "Git Commits" },
		{ "<leader>fs", "<cmd>FzfLua git_status<cr>", desc = "Git Status" },
	},

	opts = {
		winopts = {
			border = "rounded",
			preview = { layout = "vertical" },
		},
		fzf_opts = {
			["--info"] = "inline",
			["--prompt"] = "❯ ",
		},
	},
}
