-- d2 diagrams: the whole buffer in a d2 file, else the ```d2 block holding the cursor, rendered by the d2 binary to
-- PNG (snacks.image draws it) or to box-drawing text that any terminal shows.
local fn = vim.fn
local api = vim.api
local core = require("utils.core")

local M = {}

---@return string? source
---@return string name file stem for the rendered output
local function source()
	local lines = api.nvim_buf_get_lines(0, 0, -1, false)
	local stem = fn.expand("%:t:r")
	stem = stem ~= "" and stem or "untitled"
	if vim.bo.filetype == "d2" then
		return table.concat(lines, "\n"), stem
	end
	local row = api.nvim_win_get_cursor(0)[1]
	for _, block in ipairs(require("utils.fences").blocks(lines)) do
		if block.lang == "d2" and row >= block.open and row <= block.close then
			return table.concat(lines, "\n", block.open + 1, block.close - 1), ("%s-%d"):format(stem, block.open)
		end
	end
	return nil, stem
end

---@param args string[]
---@param src? string diagram source; the diagram under the cursor when nil
---@param name? string file stem of the output
---@param on_done fun(stdout: string, name: string)
local function run(args, src, name, on_done)
	if not core.executable("d2") then
		return core.warn("'d2' not found on $PATH. It is one static binary: https://d2lang.com/tour/install", "d2")
	end
	if not src then
		src, name = source()
		if not src then
			return core.warn("The cursor is not in a d2 file or inside a ```d2 block.", "d2")
		end
	end
	local cmd = { "d2" }
	for _, arg in ipairs(args) do
		cmd[#cmd + 1] = (arg:gsub("{name}", name)) -- {name}: the output file stem
	end
	vim.system(
		cmd,
		{ stdin = src, text = true },
		function(res) -- argv, not a shell string, so zsh and nushell behave the same
			vim.schedule(function()
				if res.code ~= 0 then
					return vim.notify(
						vim.trim(res.stderr ~= "" and res.stderr or res.stdout),
						vim.log.levels.ERROR,
						{ title = "d2" }
					)
				end
				on_done(res.stdout, name)
			end)
		end
	)
end

---Renders a diagram (the one under the cursor when src is nil) to PNG in a split, where snacks.image draws it.
---@param src? string
---@param name? string
function M.render(src, name) -- This util is used by d2-diagrams.lua and utils/notes.lua
	local dir = fn.stdpath("cache") .. "/999rpm-d2"
	core.may_create_dir(dir)
	local theme = vim.o.background == "light" and "0" or "200" -- d2's Neutral default, or Dark Mauve on a dark background
	run({ "--theme=" .. theme, "-", dir .. "/{name}.png" }, src, name, function(_, stem)
		local png = ("%s/%s.png"):format(dir, stem)
		local win = fn.bufwinid(png)
		if win ~= -1 then
			api.nvim_win_call(win, function()
				vim.cmd("edit!") -- reload the image after a re-render
			end)
		else
			vim.cmd("vsplit " .. fn.fnameescape(png))
		end
	end)
end

---Renders a diagram (the one under the cursor when src is nil) as text in a split; q closes it.
---@param src? string
---@param name? string
function M.text(src, name) -- This util is used by d2-diagrams.lua and utils/notes.lua
	run({ "--stdout-format=txt", "-", "-" }, src, name, function(stdout)
		local buf = fn.bufnr("999rpm://d2-text")
		if buf == -1 then
			buf = api.nvim_create_buf(false, true)
			api.nvim_buf_set_name(buf, "999rpm://d2-text")
			core.map_close(buf)
		end
		local lines = vim.split(stdout, "\n", { trimempty = true })
		vim.bo[buf].modifiable = true
		api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modifiable = false
		if fn.bufwinid(buf) == -1 then
			vim.cmd(("botright %dsplit"):format(math.min(#lines + 1, 25)))
			api.nvim_win_set_buf(0, buf)
		end
	end)
end

return M
