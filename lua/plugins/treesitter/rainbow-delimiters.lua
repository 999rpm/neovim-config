-- hiphish/rainbow-delimiters.nvim: alternating colors for nested brackets/delimiters, driven
-- by treesitter (matches any paired node, not just parens — HTML tags, Lua do/end, etc). Its
-- highlight groups (RainbowDelimiterRed/Yellow/Blue/Orange/Green/Violet/Cyan) are `default =
-- true`, so tokyonight/catppuccin/kanagawa's own bundled overrides win automatically, and stay
-- in sync across theme switches with no extra wiring needed here.
--
-- 2026-08-06: config-wide audit (full scope in init.lua). Explicitly set `vim.g.rainbow_
-- delimiters.highlight` to `utils.rainbow_delimiter_groups` — functionally a no-op (this is
-- already the plugin's own internal default order, verified against its lua/rainbow-
-- delimiters/default.lua), but being explicit here gives plugins/ui/indent-blankline.lua's
-- rainbow scope coloring one single shared list to point at instead of a second hand-typed
-- copy that could quietly drift out of matching order. See utils.lua's own note on that list.
-- Also added `submodules = false`, found while verifying the category-folder restructure
-- under a real `lazy.nvim` install: this plugin's only git submodule is a gitlab.com-hosted
-- test harness its own test suite uses, never needed to actually use the plugin — but cloning
-- it by default adds a second host and a failure point unrelated to whether the plugin works,
-- and repeated failures there were enough to trip lazy.nvim's "too many rounds of missing
-- plugins" retry ceiling in one test run. Skipping it removes that risk entirely.
return {
	"hiphish/rainbow-delimiters.nvim",
	event = { "BufReadPost", "BufNewFile" }, -- matches treesitter.lua's own trigger — needs a parser to rainbow anything
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	submodules = false, -- its only submodule is a gitlab.com-hosted test harness (test/bin), used only by the plugin's own internal test suite — never needed to actually use it, and cloning it needlessly adds a second host + a failure point unrelated to the plugin working
	init = function()
		vim.g.rainbow_delimiters = { highlight = require("utils").rainbow_delimiter_groups }
	end,
}
