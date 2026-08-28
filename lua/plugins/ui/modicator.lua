-- mawkler/modicator.nvim: colors the cursorline's line number according to the current mode —
-- a second, ambient mode indicator alongside plugins/ui/lualine.lua's own icon+text mode
-- component, on a different visual channel (the gutter, always in view, vs. the statusline
-- edge). A low-priority candidate from the smaller aesthetic group (AUDIT_SUMMARY.md), added
-- now that a plugin addition is an explicit ask.
--
-- All three of its stated requirements — `termguicolors`, `cursorline`, `number` — are already
-- true in options.lua for unrelated reasons (24-bit color throughout; the line the cursor is on
-- highlighted; absolute line numbers alongside relative ones), so nothing needed changing there
-- to adopt this. `show_warnings = false`: those three options are real, deliberate, permanent
-- choices in this config, not a maybe — the warning exists upstream for setups where one of
-- them might be toggled elsewhere by accident, which isn't a real risk here.
return {
	"mawkler/modicator.nvim",
	event = "VeryLazy",
	opts = {
		show_warnings = false,
	},
}
