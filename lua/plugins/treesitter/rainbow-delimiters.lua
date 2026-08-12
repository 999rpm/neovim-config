-- hiphish/rainbow-delimiters.nvim: alternating colors for nested brackets/delimiters, driven
-- by treesitter (matches any paired node, not just parens — HTML tags, Lua do/end, etc). Its
-- highlight groups (RainbowDelimiterRed/Yellow/Blue/Orange/Green/Violet/Cyan) are `default =
-- true`, so tokyonight/catppuccin/kanagawa's own bundled overrides win automatically, and stay
-- in sync across theme switches with no extra wiring needed here. `vim.g.rainbow_delimiters.
-- highlight` points at `utils.rainbow_delimiter_groups` — a single named list rather than a
-- literal table here, in case anything else in this config ever wants the same 7 group names
-- in the same order; see utils.lua's own note on that list. `submodules =
-- false`: this plugin's only git submodule is a gitlab.com-hosted test harness its own test
-- suite uses, never needed to actually use the plugin, and skipping it avoids a needless
-- second clone host.
return {
	"hiphish/rainbow-delimiters.nvim",
	event = { "BufReadPost", "BufNewFile" }, -- matches treesitter.lua's own trigger — needs a parser to rainbow anything
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	submodules = false, -- its only submodule is a gitlab.com-hosted test harness (test/bin), used only by the plugin's own internal test suite — never needed to actually use it, and cloning it needlessly adds a second host + a failure point unrelated to the plugin working
	init = function()
		vim.g.rainbow_delimiters = { highlight = require("utils").rainbow_delimiter_groups }
	end,
}
