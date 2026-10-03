-- Fenced code blocks of markdown text, read without treesitter, so it works before a parser loads and on any buffer.
local M = {}

---Opening and closing row (1-based), the info string's language ("" for none) and the fence itself.
---@param lines string[]
---@return { open: integer, close: integer, lang: string, fence: string }[]
function M.blocks(lines) -- This util is used by utils/d2.lua and utils/notebook.lua
	local blocks, open = {}, nil
	for i, line in ipairs(lines) do
		if open then
			local close = line:match("^%s*([`~]+)%s*$")
			if close and close:sub(1, 1) == open.fence:sub(1, 1) and #close >= #open.fence then
				blocks[#blocks + 1] = { open = open.row, close = i, lang = open.lang, fence = open.fence }
				open = nil
			end
		else
			local fence, lang = line:match("^%s*(```+)%s*{?([%w_.+-]*)")
			if not fence then
				fence, lang = line:match("^%s*(~~~+)%s*{?([%w_.+-]*)")
			end
			if fence then
				open = { row = i, lang = lang, fence = fence } -- {?: quarto writes ```{python}
			end
		end
	end
	return blocks
end

return M
