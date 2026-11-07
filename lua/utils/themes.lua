-- Theme switcher: tokyonight, catppuccin, kanagawa and monokai-pro with their styles and a transparent background. The
-- choice persists in stdpath("data")/999rpm-theme.json and loads at startup. Each switch drops the theme's Lua modules,
-- so its setup() runs again with the new style, then fires User ThemeChanged after the ColorScheme event. A theme that
-- fails to load leaves the last one in place (Neovim's default colours at startup) and warns. :colorscheme clears every
-- highlight group, so each switch restores the default links plugins set once at load (copilot's ghost text, barbar's
-- tabs, markdown headings, trouble) wherever the new theme defines none.
local fn, api = vim.fn, vim.api
local core = require("utils.core")

local M = {}

local STATE_FILE = fn.stdpath("data") .. "/999rpm-theme.json"

local set_hl, get_hl = api.nvim_set_hl, api.nvim_get_hl
local default_links = {} -- group -> link a plugin set as its default: default = true, or into an empty group
local restored = {} -- groups the last switch refilled from default_links
local theme_loading = false -- between ColorSchemePre and ColorScheme the links are the theme's own

local function is_empty(name)
	return next(get_hl(0, { name = name, create = false })) == nil
end

---Records the default links plugins set, then sets the highlight as asked. A plugin that recomputes one of its groups
---with default = true after a switch (dap-ui's *NC groups) replaces the refilled link.
---@diagnostic disable-next-line: duplicate-set-field
api.nvim_set_hl = function(ns, name, val)
	if ns == 0 and not theme_loading and type(val) == "table" then
		if restored[name] and val.default then
			restored[name] = nil
			val = vim.tbl_extend("force", val, { default = false })
		elseif val.link and (val.default or is_empty(name)) then
			default_links[name] = val.link
		end
	end
	return set_hl(ns, name, val)
end

local links_group = core.augroup("theme-default-links")
api.nvim_create_autocmd("ColorSchemePre", {
	group = links_group,
	desc = "999rpm: stop recording default links while a colour scheme loads",
	callback = function()
		theme_loading, restored = true, {}
	end,
})
api.nvim_create_autocmd("ColorScheme", { -- registered before the plugins' own handlers, which then see the links
	group = links_group,
	desc = "999rpm: refill the default links plugins set once at load, which :colorscheme clears",
	callback = function()
		theme_loading = false
		for name, link in pairs(default_links) do
			if is_empty(name) then -- a group the new theme defines keeps its colours
				set_hl(0, name, { link = link })
				restored[name] = true
			end
		end
	end,
})

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
