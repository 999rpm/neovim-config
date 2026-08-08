-- theHamsta/nvim-dap-virtual-text: shows variable values inline next to their definitions
-- during a debug session, instead of only in dap-ui.lua's separate Scopes panel. Starts
-- disabled (see `enabled = false` below) — toggle with `<leader>Dv`.
return {
	"theHamsta/nvim-dap-virtual-text",
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	event = "VeryLazy",

	opts = {
		enabled = false, -- IMPORTANT: start disabled (safety)
		commented = false,

		virt_text_pos = "inline", -- maximal clarity, heavier
		virt_text_win_col = nil, -- allow adaptive placement

		only_first_definition = false,
		all_references = true,
		all_frames = false, -- top frame only (adaptive)

		clear_on_continue = true, -- avoid stale extmarks
		highlight_changed_variables = true,
		show_stop_reason = true,

		virt_text_prefix = " ",
	},

	config = function(_, opts)
		local dapvt = require("nvim-dap-virtual-text")
		dapvt.setup(opts)

		vim.keymap.set("n", "<leader>Dv", function()
			dapvt.toggle()
		end, { desc = "Toggle virtual text" })
	end,
}
