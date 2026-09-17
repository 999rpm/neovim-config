-- theHamsta/nvim-dap-virtual-text: shows variable values inline while a session is stopped.
return {
	"theHamsta/nvim-dap-virtual-text",
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	event = "VeryLazy",

	opts = {
		enabled = false, -- off until :DapVirtualTextToggle; inline values render over real code and are noise outside a live session
		commented = false,

		virt_text_pos = "inline", -- render values in-line with the code, not at end of line

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
