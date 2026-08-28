-- m-demare/hlargs.nvim: highlights function/method parameters distinctly from other
-- identifiers, via treesitter queries. A low-priority candidate from the smaller aesthetic
-- group (AUDIT_SUMMARY.md), added now that a plugin addition is an explicit ask.
--
-- Left at upstream's own default color rather than `link`-ed to an existing theme group, unlike
-- most of this config's other highlighting (rainbow-delimiters.lua, snacks.lua's indent guides,
-- dap.lua's breakpoint signs): this plugin's entire purpose is to make a parameter read as
-- something OTHER than whatever the active theme's own treesitter capture already does for it —
-- linking back to a theme group risks landing on the exact color the theme already uses nearby,
-- defeating the point. Upstream's own default (verified against lua/hlargs/config.lua: `{ fg =
-- color, default = true }`) is already `default = true`, so any of the four themes this config
-- switches between (plugins/ui/themes.lua) that DOES define its own `Hlargs` group would still
-- win over this — it just falls back to a fixed, theme-agnostic accent when none does, which in
-- practice is every theme here today.
return {
	"m-demare/hlargs.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {},
}
