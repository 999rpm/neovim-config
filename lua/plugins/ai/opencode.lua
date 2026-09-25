-- NickvanDyke/opencode.nvim: opencode TUI plus prompts sent from the editor. The TUI runs in a snacks terminal on the right.
-- Keys: <leader>io toggle the opencode terminal, <leader>ic ask about the word or selection, <leader>iS pick an opencode action.
local opencode_cmd = "opencode"
local term_opts = { win = { position = "right", enter = false } }

return {
	"NickvanDyke/opencode.nvim",
	dependencies = { "folke/snacks.nvim" },
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
			desc = "Opencode",
		},
		{
			"<leader>ic",
			function()
				require("opencode").ask("@this: ")
			end,
			mode = { "n", "x" },
			desc = "Ask opencode about this",
		},
		{
			"<leader>iS",
			function()
				require("opencode").select()
			end,
			mode = { "n", "x" },
			desc = "Opencode actions",
		},
	},
}
