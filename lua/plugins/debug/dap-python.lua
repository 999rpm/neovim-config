-- mfussenegger/nvim-dap-python: pre-built debugpy adapter + launch configurations for Python,
-- so plugins/debug/dap.lua doesn't need to hand-write them the way it does for C/C++/Rust/JS/TS.
return {
	"mfussenegger/nvim-dap-python",
	event = "VeryLazy", -- matches dap.lua's own trigger — same effective load timing as when this rode along as its dependency
	dependencies = { "mfussenegger/nvim-dap" },
	config = function()
		local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

		if vim.fn.has("win32") == 1 then
			debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/Scripts/python.exe"
		end

		require("dap-python").setup(debugpy_path)
	end,
}
