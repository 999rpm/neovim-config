-- nvim-dap helpers: Mason paths and adapters that check for their Mason package when a session starts.
local fn = vim.fn

local M = {}

---Absolute path inside Mason's data directory, with the Windows layout when running there.
---@param unix string path relative to the Mason root, POSIX layout
---@param windows? string same path in the Windows layout, when it differs
---@return string
function M.mason_path(unix, windows) -- This util is used by dap-python.lua and dap.lua
	local root = fn.stdpath("data") .. "/mason/"
	return root .. ((fn.has("win32") == 1 and windows) or unix)
end

---Wraps an adapter so its Mason file is checked when a session starts, not when nvim-dap loads.
---@param path string absolute path of the Mason-installed file
---@param label string Mason package name
---@param adapter table|function the adapter as nvim-dap takes it
---@return function
function M.mason_adapter(path, label, adapter) -- This util is used by dap-python.lua and dap.lua
	return function(callback, config, parent)
		if not vim.uv.fs_stat(path) then
			return require("utils.core").warn(
				("%s not found at %s. Check :Mason or :MasonLog, then run :MasonInstall %s."):format(label, path, label),
				"DAP"
			)
		end
		if type(adapter) == "function" then
			return adapter(callback, config, parent)
		end
		callback(adapter)
	end
end

return M
