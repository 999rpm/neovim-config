-- monaqa/dial.nvim: <C-a>/<C-x> in normal mode also step dates (2026-10-16, 2026/10/16) and switch true/false, when one
-- of them is the first target at or after the cursor; any other line gets the built-in keys, counts and . repeat
-- included, so -5, 0x0f and 0b101 change as in plain Neovim. A date steps the part under the cursor, the year when the
-- cursor is before it, as the built-in would. g<C-a>/g<C-x>, which have no normal-mode job of their own, step numbers
-- too, by one more on each . repeat. Visual <C-a>/<C-x>/g<C-a>/g<C-x> stay built-in. Owns normal g<C-a>/g<C-x>.
local targets = { "%d%d%d%d%-%d%d%-%d%d", "%d%d%d%d/%d%d/%d%d", "%f[%w]true%f[%W]", "%f[%w]false%f[%W]" } -- Lua patterns of dial's targets below

---True when a date or true/false holds the cursor, or comes after it before any other digit.
---@return boolean
local function on_target()
	local line, col = vim.api.nvim_get_current_line(), vim.fn.col(".")
	local first
	for _, pattern in ipairs(targets) do
		local s, e = line:find(pattern)
		while s and e < col do
			s, e = line:find(pattern, e + 1)
		end
		if s and (not first or s < first) then
			first = s
		end
	end
	local digit = line:find("%d", col)
	return first ~= nil and (first <= col or not digit or digit >= first)
end

---@param key string the built-in key, run when no dial target comes first
---@param direction "inc"|"dec"
local function step(key, direction)
	return function()
		return on_target() and require("dial.map")[direction .. "_normal"]("999rpm-targets") or key
	end
end

local function sequential(direction)
	return function()
		require("dial.map").manipulate(direction, "gnormal")
	end
end

---Dates and true/false, new objects per group, since a date remembers the part it last stepped.
local function extra_targets(augend)
	return {
		augend.date.new({ pattern = "%Y-%m-%d", default_kind = "year" }), -- year: what the built-in steps from before the date
		augend.date.new({ pattern = "%Y/%m/%d", default_kind = "year" }),
		augend.constant.alias.bool,
	}
end

return {
	"monaqa/dial.nvim",
	keys = {
		{ "<C-a>", step("<C-a>", "inc"), expr = true, desc = "Increment (also dates, true/false)" }, -- n: upgrades built-in <C-a>: also steps a date and flips true/false; numbers stay the built-in's
		{ "<C-x>", step("<C-x>", "dec"), expr = true, desc = "Decrement (also dates, true/false)" }, -- n: upgrades built-in <C-x> the same way
		{ "g<C-a>", sequential("increment"), desc = "Increment, one more per repeat" }, -- n: 1 becomes 2, then . adds 2, then 3 (1, 2, 4, 7)
		{ "g<C-x>", sequential("decrement"), desc = "Decrement, one more per repeat" }, -- n: the same downwards
	},
	config = function()
		local augend = require("dial.augend")
		require("dial.config").augends:register_group({
			default = vim.list_extend({ -- g<C-a>/g<C-x>
				augend.integer.alias.decimal_int, -- signed: -5 steps to -4, as with the built-in
				augend.integer.alias.hex,
				augend.integer.alias.binary,
			}, extra_targets(augend)),
			["999rpm-targets"] = extra_targets(augend), -- <C-a>/<C-x> once on_target() picked dial
		})
	end,
}
