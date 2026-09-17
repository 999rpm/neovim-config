-- mfussenegger/nvim-dap-python: python launch configurations through Mason's debugpy.
return {
	"mfussenegger/nvim-dap-python",
	event = "VeryLazy", -- matches dap.lua's own trigger; same effective load timing as when this rode along as its dependency
	dependencies = { "mfussenegger/nvim-dap" },
	config = function()
		local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

		if vim.fn.has("win32") == 1 then
			debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/Scripts/python.exe"
		end

		require("utils").warn_if_missing_mason_bin(debugpy_path, "debugpy")

		require("dap-python").setup(debugpy_path)
	end,
}
