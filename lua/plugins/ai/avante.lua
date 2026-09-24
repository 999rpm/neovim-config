-- avante-corp/avante.nvim: Claude sidebar with diff-based edits. Needs ANTHROPIC_API_KEY, and cargo for the build step.
-- Keys: <leader>ia toggle, ie edit selection, iA ask, in new chat, is stop, ir refresh, if focus, im model, ih history,
-- ib add open buffers, iF add current file, iz zen mode, iR repo map.
-- In the sidebar: A apply all, a apply at cursor, r retry, e edit request, @ add file, d remove file, <Tab>/<S-Tab> switch panes, q close.
return {
	"avante-corp/avante.nvim",
	build = "make",
	event = "VeryLazy",
	version = false, -- avante's own docs: never pin this to "*", the plugin tracks Nvim API changes closely
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-mini/mini.nvim",
	},
	opts = {
		provider = "claude",
		providers = {
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-sonnet-5",
			},
		},
		behaviour = {
			auto_suggestions = false, -- don't compete with copilot.lua's own ghost text
			auto_apply_diff_after_generation = false, -- review before applying, not automatic
			auto_set_keymaps = false,
		},
	},
	keys = {
		{
			"<leader>ia",
			function()
				require("avante").toggle()
			end,
			mode = { "n", "x" },
			desc = "Toggle Avante Sidebar",
		},
		{
			"<leader>ie",
			function()
				require("avante").edit()
			end,
			mode = { "n", "x" },
			desc = "Avante Edit Selection",
		},
		{
			"<leader>iA",
			function()
				require("avante.api").ask()
			end,
			mode = { "n", "x" },
			desc = "Avante Ask",
		},
		{
			"<leader>in",
			function()
				require("avante.api").ask({ new_chat = true })
			end,
			mode = { "n", "x" },
			desc = "Avante New Chat",
		},
		{
			"<leader>is",
			function()
				require("avante.api").stop()
			end,
			desc = "Avante Stop Generation",
		},
		{
			"<leader>ir",
			function()
				require("avante.api").refresh()
			end,
			desc = "Avante Refresh",
		},
		{
			"<leader>if",
			function()
				require("avante.api").focus()
			end,
			desc = "Avante Focus Window",
		},
		{
			"<leader>im",
			function()
				require("avante.api").select_model()
			end,
			desc = "Avante Select Model",
		},
		{
			"<leader>ih",
			function()
				require("avante.api").select_history()
			end,
			desc = "Avante Select History",
		},
		{
			"<leader>ib",
			function()
				require("avante.api").add_buffer_files()
			end,
			desc = "Avante Add All Buffers",
		},
		{
			"<leader>iF",
			function()
				require("avante.api").add_selected_file(vim.api.nvim_buf_get_name(0))
			end,
			desc = "Avante Add Current File",
		},
		{
			"<leader>iz",
			function()
				require("avante.api").zen_mode()
			end,
			mode = { "n", "x" },
			desc = "Avante Zen Mode",
		},
		{
			"<leader>iR",
			function()
				require("avante.repo_map").show()
			end,
			desc = "Avante Show Repo Map",
		},
	},
	config = function(_, opts)
		require("utils").warn_if_missing_env("ANTHROPIC_API_KEY", "avante.nvim")
		require("avante").setup(opts)
	end,
}
