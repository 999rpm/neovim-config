-- mfussenegger/nvim-dap-python: python launch configurations through Mason's debugpy. Started with dap.lua's keys; a
-- missing debugpy is reported when a Python session starts, not when nvim-dap loads.
return {
	"mfussenegger/nvim-dap-python",
	lazy = true, -- loads with nvim-dap, which lists it as a dependency
	dependencies = { "mfussenegger/nvim-dap" },
	config = function()
		local utils = require("utils")
		local debugpy = utils.mason_path("packages/debugpy/venv/bin/python", "packages/debugpy/venv/Scripts/python.exe")
		require("dap-python").setup(debugpy)
		local dap = require("dap")
		for _, name in ipairs({ "python", "debugpy" }) do
			if dap.adapters[name] then
				dap.adapters[name] = utils.mason_adapter(debugpy, "debugpy", dap.adapters[name]) -- checked when a Python session starts
			end
		end
	end,
}
