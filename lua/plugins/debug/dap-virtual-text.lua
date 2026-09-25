-- theHamsta/nvim-dap-virtual-text: variable values inline while a session is stopped. <leader>Dv toggles them.
return {
	"theHamsta/nvim-dap-virtual-text",
	dependencies = { "mfussenegger/nvim-dap" },
	cmd = { "DapVirtualTextToggle", "DapVirtualTextEnable", "DapVirtualTextDisable" },
	keys = {
		{
			"<leader>Dv",
			function()
				require("nvim-dap-virtual-text").toggle()
			end,
			desc = "Toggle virtual text",
		},
	},
	opts = {
		enabled = false, -- off until toggled; inline values over real code are noise outside a live session
		commented = false,
		virt_text_pos = "inline", -- values sit beside the variable, not at the end of the line
		only_first_definition = false,
		all_references = true,
		all_frames = false, -- top frame only
		clear_on_continue = true, -- no stale values after a step
		highlight_changed_variables = true,
		show_stop_reason = true,
	},
}
