-- Theme switcher: tokyonight, catppuccin, kanagawa and monokai-pro with their styles and a transparent background. The
-- choice persists in stdpath("data")/999rpm-theme.json and loads at startup. Each switch drops the theme's Lua modules,
-- so its setup() runs again with the new style, then fires User ThemeChanged after the ColorScheme event. A theme that
-- fails to load leaves the last one in place (Neovim's default colours at startup) and warns.
local fn, api = vim.fn, vim.api
local core = require("utils.core")

local M = {}

local STATE_FILE = fn.stdpath("data") .. "/999rpm-theme.json"

local adapters = {
	tokyonight = {
		styles = { "day", "storm", "night", "moon" },
		is_light = function(s)
			return s == "day"
		end,
		setup = function(s, transparent)
			require("tokyonight").setup({
				dim_inactive = true,
				style = s,
				transparent = transparent,
				styles = {
					sidebars = transparent and "transparent" or "dark",
					floats = transparent and "transparent" or "dark",
				},
			})
		end,
	},
	catppuccin = {
		styles = { "latte", "mocha", "macchiato", "frappe" },
		is_light = function(s)
			return s == "latte"
		end,
		setup = function(s, transparent)
			require("catppuccin").setup({
				flavour = s,
				transparent_background = transparent,
				dim_inactive = { enabled = true, shade = "dark", percentage = 0.15 },
			})
		end,
	},
	kanagawa = {
		styles = { "lotus", "wave", "dragon" },
		is_light = function(s)
			return s == "lotus"
		end,
		setup = function(s, transparent)
			require("kanagawa").setup({
				dimInactive = true,
				theme = s,
				transparent = transparent,
				compile = false,
				background = { dark = s, light = s },
			})
		end,
	},
	["monokai-pro"] = {
		styles = { "pro", "classic", "octagon", "machine", "ristretto", "spectrum", "light" },
		colorscheme = function(s)
			return s == "pro" and "monokai-pro" or "monokai-pro-" .. s -- colors/monokai-pro.lua pins the "pro" filter; the per-filter files do not
		end,
		is_light = function(s)
			return s == "light"
		end,
		setup = function(s, transparent)
			require("monokai-pro").setup({
				filter = s,
				transparent_background = transparent,
				devicons = true, -- themes the icon highlights, as the other three themes do by default
			})
		end,
	},
}
local ORDER = { "tokyonight", "catppuccin", "kanagawa", "monokai-pro" }

local state = { theme = "tokyonight", style_index = 4, transparent = false } -- first run: moon, tokyonight's own default

---Reads the saved choice over the defaults; a missing file, broken JSON or an unknown theme keeps them.
local function read_state()
	local f = io.open(STATE_FILE, "r")
	if not f then
		return
	end
	local ok, saved = pcall(vim.json.decode, f:read("*a"))
	f:close()
	if not ok or type(saved) ~= "table" then
		return -- "null" and bare strings decode too, to values that are not tables
	end
	if adapters[saved.theme] then
		state.theme = saved.theme
	end
	state.style_index = math.floor(tonumber(saved.style_index) or state.style_index)
	state.transparent = saved.transparent == true
end

local function write_state()
	local f = io.open(STATE_FILE, "w")
	if f then
		f:write(vim.json.encode(state))
		f:close()
	end
end

---Loads the current theme and style on a clean slate.
---@return boolean ok false when the theme failed and Neovim's default colours were loaded instead
local function apply()
	local adapter = adapters[state.theme]
	state.style_index = math.max(1, math.min(state.style_index, #adapter.styles))
	local style = adapter.styles[state.style_index]
	local pattern = "^" .. vim.pesc(state.theme)
	for name in pairs(package.loaded) do
		if name:match(pattern) then
			package.loaded[name] = nil -- the next require reads the theme's options again
		end
	end
	vim.cmd("highlight clear")
	if fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.g.colors_name = nil
	vim.o.background = adapter.is_light(style) and "light" or "dark"
	local ok, err = pcall(function()
		adapter.setup(style, state.transparent)
		vim.cmd.colorscheme(adapter.colorscheme and adapter.colorscheme(style) or state.theme)
	end)
	if not ok then
		core.warn(("%s did not load: %s"):format(state.theme, err), "Themes")
		vim.cmd.colorscheme("default")
	end
	return ok
end

---Changes the state, applies it and saves it; a theme that fails to load is rolled back to the previous one.
---@param change fun(s: table)
local function update(change)
	local previous = vim.deepcopy(state)
	change(state)
	if apply() then
		write_state()
	else
		state = previous
		apply()
	end
	api.nvim_exec_autocmds("User", { pattern = "ThemeChanged" }) -- a hook for code outside this config
end

---Applies the saved theme at startup.
function M.load() -- This util is used by colorschemes.lua
	read_state()
	apply()
end

function M.cycle_theme() -- This util is used by colorschemes.lua
	update(function(s)
		local idx = 0
		for i, name in ipairs(ORDER) do
			idx = name == s.theme and i or idx
		end
		s.theme, s.style_index = ORDER[idx % #ORDER + 1], 1
	end)
end

function M.cycle_style() -- This util is used by colorschemes.lua
	update(function(s)
		s.style_index = s.style_index % #adapters[s.theme].styles + 1
	end)
end

function M.toggle_transparency() -- This util is used by colorschemes.lua
	update(function(s)
		s.transparent = not s.transparent
	end)
end

---Every theme and style in one picker.
function M.pick_theme() -- This util is used by colorschemes.lua
	local items = {}
	for _, name in ipairs(ORDER) do
		for i, style in ipairs(adapters[name].styles) do
			items[#items + 1] = { label = name .. ": " .. style, theme = name, index = i }
		end
	end
	vim.ui.select(items, {
		prompt = "Theme and style",
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if choice then
			update(function(s)
				s.theme, s.style_index = choice.theme, choice.index
			end)
		end
	end)
end

return M
