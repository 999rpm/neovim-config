-- Multi-theme switcher (tokyonight/catppuccin/kanagawa) with persisted state. Sole owner of
-- all theme-related keymaps (<leader>os/ot/oT/ou) — see mappings.lua's note on why its own
-- old, non-functional <leader>os/<leader>ot entries were removed rather than left as dead code.
local fn, api, json = vim.fn, vim.api, vim.json
local state_file = fn.stdpath("data") .. "/theme_state.json"

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
			if package.loaded["kanagawa"] then
				package.loaded["kanagawa"] = nil
			end
			require("kanagawa").setup({
				dimInactive = true,
				theme = s,
				transparent = transparent,
				compile = false,
				background = { dark = s, light = s },
			})
		end,
	},
}
local theme_order = { "tokyonight", "catppuccin", "kanagawa" }

local State = {
	data = { theme = "tokyonight", style_index = 1, transparent = true },
}

function State:load()
	local f = io.open(state_file, "r")
	if f then
		local ok, saved = pcall(json.decode, f:read("*a"))
		if ok and saved then
			self.data = vim.tbl_deep_extend("force", self.data, saved)
		end
		f:close()
	end
end

function State:save()
	local f = io.open(state_file, "w")
	if f then
		f:write(json.encode(self.data))
		f:close()
	end
end

local Controller = {}

function Controller.apply()
	local s = State.data
	local adapter = adapters[s.theme]
	if not adapter then
		return
	end

	s.style_index = math.max(1, math.min(s.style_index, #adapter.styles))
	local style = adapter.styles[s.style_index]

	for pkg, _ in pairs(package.loaded) do
		if pkg:match("^" .. s.theme) then
			package.loaded[pkg] = nil
		end
	end

	vim.cmd("highlight clear")
	if fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.g.colors_name = nil

	vim.o.background = adapter.is_light(style) and "light" or "dark"
	adapter.setup(style, s.transparent)
	vim.cmd.colorscheme(s.theme)
end

function Controller.update(modifier_fn)
	modifier_fn(State.data)
	Controller.apply()
	State:save()

	if package.loaded["lualine"] then
		require("lualine").refresh()
	end
	-- Fires "ThemeChanged" for anything that needs to re-derive colors after a switch —
	-- currently plugins/ui/bufferline.lua's highlight refresh. plugins/treesitter/
	-- rainbow-delimiters.lua does NOT need this: it references RainbowDelimiter* group names
	-- rather than caching hex values, so `vim.cmd.colorscheme()` above already refreshes them
	-- for free, no event needed.
	api.nvim_exec_autocmds("User", { pattern = "ThemeChanged" })
end

local actions = {
	toggle_transparency = function()
		Controller.update(function(s)
			s.transparent = not s.transparent
		end)
	end,

	cycle_style = function()
		Controller.update(function(s)
			local count = #adapters[s.theme].styles
			s.style_index = (s.style_index % count) + 1
		end)
	end,

	cycle_theme = function()
		Controller.update(function(s)
			local idx = 0
			for i, name in ipairs(theme_order) do
				if name == s.theme then
					idx = i
					break
				end
			end
			s.theme = theme_order[(idx % #theme_order) + 1]
			s.style_index = 1
		end)
	end,

	select_style = function()
		local items = {}
		for _, name in ipairs(theme_order) do
			for i, style in ipairs(adapters[name].styles) do
				table.insert(items, { label = name .. ": " .. style, theme = name, index = i })
			end
		end

		vim.ui.select(items, {
			prompt = "Select Theme Style",
			format_item = function(item)
				return item.label
			end,
		}, function(choice)
			if choice then
				Controller.update(function(s)
					s.theme = choice.theme
					s.style_index = choice.index
				end)
			end
		end)
	end,
}

local function init()
	State:load()
	Controller.apply()

	local mappings = {
		["<leader>ou"] = { actions.select_style, "Select Theme Style" },
		["<leader>os"] = { actions.cycle_style, "Cycle Style" },
		["<leader>ot"] = { actions.cycle_theme, "Switch Theme" },
		["<leader>oT"] = { actions.toggle_transparency, "Toggle Transparency" },
	}
	for k, v in pairs(mappings) do
		vim.keymap.set("n", k, v[1], { desc = v[2] })
	end
end

return {
	{ "folke/tokyonight.nvim", lazy = true, opts = {} },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	{ "rebelot/kanagawa.nvim", lazy = true },
	{
		dir = fn.stdpath("config"),
		name = "999rpm-themer", -- matches this config's "999rpm-" naming convention (utils.lua) — purely a display/identity name for this local, repo-less spec, nothing else references the literal string
		lazy = false,
		priority = 1000,
		config = init,
	},
}
