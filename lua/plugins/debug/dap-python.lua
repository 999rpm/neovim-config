-- mfussenegger/nvim-dap-python: python launch configurations through Mason's debugpy. Started with dap.lua's keys.
return {
	"mfussenegger/nvim-dap-python",
	lazy = true, -- loads with nvim-dap, which lists it as a dependency
	dependencies = { "mfussenegger/nvim-dap" },
	config = function()
		local utils = require("utils")
		local debugpy = utils.mason_path("packages/debugpy/venv/bin/python", "packages/debugpy/venv/Scripts/python.exe")
		utils.warn_if_missing_mason_bin(debugpy, "debugpy")
		require("dap-python").setup(debugpy)
	end,
}
