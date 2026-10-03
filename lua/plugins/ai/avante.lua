-- avante-corp/avante.nvim: Claude sidebar with diff-based edits. Needs ANTHROPIC_API_KEY. The build step fetches the
-- prebuilt libraries with curl and tar; upstream's Makefile would compile them with cargo instead.
-- Keys: <leader>ia toggle, ie edit selection, iA ask, in new chat, is stop, ir refresh, if focus, im model, ih history,
-- ib add open buffers, iF add current file, iz zen mode, iR repo map.
-- In the sidebar: A apply all, a apply at cursor, r retry, e edit request, @ add file, d remove file, <Tab>/<S-Tab> switch panes, q close.
return {
	"avante-corp/avante.nvim",
	build = "bash build.sh",
	cmd = { "AvanteAsk", "AvanteChat", "AvanteEdit", "AvanteToggle" }, -- with the keys below; nothing loads at startup
	version = false, -- avante's own docs: never pin this to "*", the plugin tracks Nvim API changes closely
	dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "ColinKennedy/mega.cmdparse" }, -- mini.icons is already loaded at priority 1000
	opts = {
		provider = "claude",
		providers = {
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-sonnet-5-5", -- current Sonnet API id; "claude-sonnet-5" matches no model
			},
		},
		behaviour = {
			auto_suggestions = false, -- copilot.lua already draws the ghost text
			auto_apply_diff_after_generation = false, -- a diff waits for review before it applies
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
			desc = "Avante sidebar",
		},
		{
			"<leader>ie",
			function()
				require("avante").edit()
			end,
			mode = { "n", "x" },
			desc = "Avante: edit selection",
		},
		{
			"<leader>iA",
			function()
				require("avante.api").ask()
			end,
			mode = { "n", "x" },
			desc = "Avante: ask",
		},
		{
			"<leader>in",
			function()
				require("avante.api").ask({ new_chat = true })
			end,
			mode = { "n", "x" },
			desc = "Avante: new chat",
		},
		{
			"<leader>is",
			function()
				require("avante.api").stop()
			end,
			desc = "Avante: stop",
		},
		{
			"<leader>ir",
			function()
				require("avante.api").refresh()
			end,
			desc = "Avante: refresh",
		},
		{
			"<leader>if",
			function()
				require("avante.api").focus()
			end,
			desc = "Avante: focus window",
		},
		{
			"<leader>im",
			function()
				require("avante.api").select_model()
			end,
			desc = "Avante: select model",
		},
		{
			"<leader>ih",
			function()
				require("avante.api").select_history()
			end,
			desc = "Avante: history",
		},
		{
			"<leader>ib",
			function()
				require("avante.api").add_buffer_files()
			end,
			desc = "Avante: add open buffers",
		},
		{
			"<leader>iF",
			function()
				require("avante.api").add_selected_file(vim.api.nvim_buf_get_name(0))
			end,
			desc = "Avante: add this file",
		},
		{
			"<leader>iz",
			function()
				require("avante.api").zen_mode()
			end,
			mode = { "n", "x" },
			desc = "Avante: zen mode",
		},
		{
			"<leader>iR",
			function()
				require("avante.repo_map").show()
			end,
			desc = "Avante: repo map",
		},
	},
	config = function(_, opts)
		require("utils.core").warn_if_missing_env("ANTHROPIC_API_KEY", "avante.nvim")
		require("avante").setup(opts)
	end,
}
