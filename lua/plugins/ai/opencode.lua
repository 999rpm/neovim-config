-- NickvanDyke/opencode.nvim: opencode TUI plus prompts sent from the editor. The TUI runs in a snacks terminal on the
-- right. Owns <leader>io, <leader>ic and <leader>iS, in avante.lua's AI group.
local opencode_cmd = "opencode"
local term_opts = { win = { position = "right", enter = false } }

return {
	"NickvanDyke/opencode.nvim",
	init = function()
		vim.g.opencode_opts = {
			server = {
				start = function()
					require("snacks.terminal").open(opencode_cmd, term_opts) -- started on demand when a prompt needs the TUI
				end,
			},
		}
	end,
	keys = {
		{
			"<leader>io",
			function()
				require("snacks.terminal").toggle(opencode_cmd, term_opts)
			end,
			desc = "Opencode terminal",
		}, -- n: show or hide the opencode TUI (o for opencode)
		{
			"<leader>ic",
			function()
				require("opencode").ask("@this: ")
			end,
			mode = { "n", "x" },
			desc = "Opencode: ask about this",
		}, -- n/x: a prompt about the word under the cursor or the selection (c for context)
		{
			"<leader>iS",
			function()
				require("opencode").select()
			end,
			mode = { "n", "x" },
			desc = "Opencode: actions",
		}, -- n/x: one of opencode's ready-made prompts and commands (S for select)
	},
}
