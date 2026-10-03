-- Statusline and title helpers: throttling, per-edit caching, the git branch and the active Python environment.
local fn = vim.fn
local api = vim.api

local M = {}

---Leading-edge throttle: calls inside the window are dropped, not queued.
---@param callback fun()
---@param ms integer
---@return fun()
function M.throttle(callback, ms) -- This util is used by lualine.lua
	local last = 0
	return function()
		local now = vim.uv.now()
		if now - last < ms then
			return
		end
		last = now
		callback()
	end
end

---Per-buffer memo keyed on b:changedtick, so a statusline component scans a buffer once per edit, not once per redraw.
---@generic T
---@param key string
---@param compute fun(): T
---@return T
function M.buf_cached(key, compute) -- This util is used by lualine.lua
	local buf = api.nvim_get_current_buf()
	local tick = api.nvim_buf_get_changedtick(buf)
	local store = vim.b[buf]._999rpm_cache or {}
	local hit = store[key]
	if hit and hit.tick == tick then
		return hit.value
	end
	local value = compute()
	store[key] = { tick = tick, value = value }
	vim.b[buf]._999rpm_cache = store -- reassigned whole: vim.b returns a copy, so mutating `store` alone does not persist
	return value
end

---@param cmd string[]
---@return string?
local function run_git(cmd)
	local out = fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		return nil
	end
	return vim.trim(out)
end

---Branch of the current buffer: gitsigns' cached head, else one cached `git rev-parse` per buffer.
---@return string
function M.branch_name() -- This util is used by options.lua
	local head = vim.tbl_get(vim.b, "gitsigns_status_dict", "head")
	if head and head ~= "" then
		return head
	end
	local cached = vim.b._999rpm_branch
	if cached == nil then
		local dir = fn.expand("%:p:h")
		cached = fn.isdirectory(dir) == 1 and (run_git({ "git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" }) or "")
			or ""
		if cached == "HEAD" then
			cached = run_git({ "git", "-C", dir, "rev-parse", "--short", "HEAD" }) or cached -- detached: the short hash
		end
		vim.b._999rpm_branch = cached
	end
	return cached
end

---Active Python virtual environment (venv before conda), or "".
---@return string
function M.virtual_env() -- This util is used by lualine.lua
	local venv = os.getenv("VIRTUAL_ENV")
	if venv then
		return fn.fnamemodify(venv, ":t")
	end
	return os.getenv("CONDA_DEFAULT_ENV") or ""
end

return M
