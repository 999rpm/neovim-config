-- avante-corp/avante.nvim: Claude sidebar with diff-based edits. Needs ANTHROPIC_API_KEY. The build step fetches the
-- prebuilt libraries with curl and tar; upstream's Makefile would compile them with cargo instead. It follows its
-- main branch (no version set), as avante's own docs ask. Owns <leader>i except io/ic/iS (opencode.lua).
return {
	"avante-corp/avante.nvim",
	build = "bash build.sh",
	cmd = { "AvanteAsk", "AvanteChat", "AvanteEdit", "AvanteToggle" }, -- with the keys below; nothing loads at startup
	opts = {
		providers = {
			claude = {
				model = "claude-sonnet-5-5", -- current Sonnet API id; "claude-sonnet-5" matches no model
			},
		},
		behaviour = {
			auto_set_keymaps = false,
		},
	},
	-- avante's own keys in the sidebar: A apply every change, a apply the one at the cursor, r retry, e edit the request,
	-- ]p/[p next/previous prompt, @ add a file, d remove a file, x hide the code pane, <Tab>/<S-Tab> switch panes, q close.
	keys = {
		{
			"<leader>ia",
			function()
				require("avante").toggle()
			end,
			mode = { "n", "x" },
			desc = "Avante sidebar",
		}, -- n/x: open or close the chat beside the code (a for avante)
		{
			"<leader>ie",
			function()
				require("avante").edit()
			end,
			mode = { "n", "x" },
			desc = "Avante: edit selection",
		}, -- n/x: describe a change and get a diff for the selection
		{
			"<leader>iA",
			function()
				require("avante.api").ask()
			end,
			mode = { "n", "x" },
			desc = "Avante: ask",
		}, -- n/x: a question about the file or selection, uppercase twin of ia
		{
			"<leader>in",
			function()
				require("avante.api").ask({ new_chat = true })
			end,
			mode = { "n", "x" },
			desc = "Avante: new chat",
		}, -- n/x: start over with an empty history
		{
			"<leader>is",
			function()
				require("avante.api").stop()
			end,
			desc = "Avante: stop",
		}, -- n: stop the answer being written
		{
			"<leader>ir",
			function()
				require("avante.api").refresh()
			end,
			desc = "Avante: refresh",
		}, -- n: redraw the sidebar
		{
			"<leader>if",
			function()
				require("avante.api").focus()
			end,
			desc = "Avante: focus window",
		}, -- n: jump between the sidebar and the code
		{
			"<leader>im",
			function()
				require("avante.api").select_model()
			end,
			desc = "Avante: select model",
		}, -- n: switch the Claude model
		{
			"<leader>ih",
			function()
				require("avante.api").select_history()
			end,
			desc = "Avante: history",
		}, -- n: reopen an earlier chat
		{
			"<leader>ib",
			function()
				require("avante.api").add_buffer_files()
			end,
			desc = "Avante: add open buffers",
		}, -- n: every open buffer as context
		{
			"<leader>iF",
			function()
				require("avante.api").add_selected_file(vim.api.nvim_buf_get_name(0))
			end,
			desc = "Avante: add this file",
		}, -- n: the current file as context, uppercase twin of if
		{
			"<leader>iz",
			function()
				require("avante.api").zen_mode()
			end,
			mode = { "n", "x" },
			desc = "Avante: zen mode",
		}, -- n/x: the chat full screen
		{
			"<leader>iR",
			function()
				require("avante.repo_map").show()
			end,
			desc = "Avante: repo map",
		}, -- n: the project outline avante sends as context
	},
	config = function(_, opts)
		require("utils.core").warn_if_missing_env("ANTHROPIC_API_KEY", "avante.nvim")
		require("avante").setup(opts)
	end,
}
