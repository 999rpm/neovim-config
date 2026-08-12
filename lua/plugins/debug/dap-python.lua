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

		-- Path shape verified against mason.nvim's own pypi.lua installer (venv_path():
		-- `<package_dir>/venv/bin` on Unix, `.../venv/Scripts` on Windows) — this is correct as
		-- written. If it's still not there, Mason hasn't finished installing debugpy (or failed
		-- to) rather than this path being wrong; see the warning below for what to check.
		require("utils").warn_if_missing_mason_bin(debugpy_path, "debugpy")

		require("dap-python").setup(debugpy_path)
	end,
}
