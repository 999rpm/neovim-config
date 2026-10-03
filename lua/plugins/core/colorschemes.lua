-- folke/tokyonight.nvim, catppuccin/nvim, rebelot/kanagawa.nvim and loctvl842/monokai-pro.nvim, switched by the
-- 999rpm-themer spec below, whose code is utils/themes.lua. Theme, style and transparency persist across restarts.
-- Keys: <leader>ut next theme, <leader>uc next style, <leader>uC pick theme and style, <leader>ot toggle transparency.
local function themes(name)
	return function()
		require("utils.themes")[name]()
	end
end

return {
	{ "folke/tokyonight.nvim", lazy = true },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	{ "rebelot/kanagawa.nvim", lazy = true },
	{ "loctvl842/monokai-pro.nvim", lazy = true },
	{
		"999rpm-themer", -- a name with no slash: lazy.nvim looks for no repository
		virtual = true, -- and adds no rtp entry; local specs need distinct names, or lazy.nvim merges them
		lazy = false,
		priority = 1000, -- colours are set before the first screen draws
		keys = {
			{ "<leader>ut", themes("cycle_theme"), desc = "Next theme" },
			{ "<leader>uc", themes("cycle_style"), desc = "Next style" },
			{ "<leader>uC", themes("pick_theme"), desc = "Pick theme and style" },
			{ "<leader>ot", themes("toggle_transparency"), desc = "Toggle transparency" },
		},
		config = themes("load"),
	},
}
