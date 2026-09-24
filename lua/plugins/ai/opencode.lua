-- NickvanDyke/opencode.nvim: opencode TUI plus prompts sent from the editor. Terminal and picker come from core/snacks.lua.
-- Keys: <leader>io toggle the opencode window, <leader>ic ask about the word or selection.
return {
	"NickvanDyke/opencode.nvim",
	dependencies = { "folke/snacks.nvim" },
	keys = {
		{
			"<leader>io",
			function()
				require("opencode").toggle()
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
	},
}
