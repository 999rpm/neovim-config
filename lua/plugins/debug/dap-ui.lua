-- rcarriga/nvim-dap-ui: breakpoints/scopes/watches/stack-frame panels and a REPL, opened and
-- closed automatically as nvim-dap sessions start and end.
return {
	"rcarriga/nvim-dap-ui",
	event = "VeryLazy", -- matches plugins/debug/dap.lua's own trigger — same effective load timing as when this rode along as its dependency
	dependencies = { "nvim-neotest/nvim-nio", "mfussenegger/nvim-dap" },
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- Icon values below are nvim-dap-ui's own current defaults (lua/dapui/config/init.lua) -
		-- restated explicitly rather than omitted, so this stays correct even if a future
		-- upstream release changes its defaults out from under an implicit fallback.
		dapui.setup({
			icons = {
				expanded = "",
				collapsed = "",
				current_frame = "",
			},
			controls = {
				icons = {
					pause = "",
					play = "",
					step_out = "",
					step_back = "",
					step_into = "",
					step_over = "",
					run_last = "",
					terminate = "",
					disconnect = "",
				},
			},
		})

		dap.listeners.after.event_initialized["dapui_auto"] = function()
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
