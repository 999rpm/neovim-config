-- rcarriga/nvim-dap-ui: scopes, breakpoints, stacks and REPL panels that open and close with the session.
-- In a panel: <CR> expand or edit, o step into value, d remove, e edit, r send to REPL.
return {
	"rcarriga/nvim-dap-ui",
	lazy = true, -- loads with nvim-dap, which lists it as a dependency
	dependencies = { "nvim-neotest/nvim-nio", "mfussenegger/nvim-dap" },
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup({
			icons = {
				expanded = "󰅀",
				collapsed = "󰅂",
				current_frame = "󰜴",
			},
			controls = {
				icons = {
					pause = "󰏤",
					play = "󰐊",
					step_out = "󰆸",
					step_back = "󰓕",
					step_into = "󰆹",
					step_over = "󰆷",
					run_last = "󰜉",
					terminate = "󰓛",
					disconnect = "󰌙",
				},
			},
		})

		dap.listeners.before.attach["dapui_auto"] = function()
			dapui.open()
		end
		dap.listeners.before.launch["dapui_auto"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_auto"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_auto"] = function()
			dapui.close()
		end
	end,
}
