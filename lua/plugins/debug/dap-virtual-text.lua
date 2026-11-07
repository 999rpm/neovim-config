-- theHamsta/nvim-dap-virtual-text: values beside each variable while a session is stopped, top frame only.
-- Owns <leader>ov.
return {
	"theHamsta/nvim-dap-virtual-text",
	cmd = { "DapVirtualTextToggle", "DapVirtualTextEnable", "DapVirtualTextDisable" },
	keys = {
		{
			"<leader>ov",
			function()
				require("nvim-dap-virtual-text").toggle()
			end,
			desc = "Toggle debug virtual text",
		}, -- n: variable values beside the code while a debug session is paused (v for values)
	},
	opts = {
		enabled = false, -- off until toggled; inline values over real code are noise outside a live session
		only_first_definition = false,
		all_references = true,
		clear_on_continue = true, -- no stale values after a step
	},
}
