-- nmac427/guess-indent.nvim: detects the actual indentation style of each buffer (tabs vs
-- spaces, width) from its first few hundred lines and overrides expandtab/shiftwidth/tabstop
-- locally — options.lua's own expandtab/shiftwidth/tabstop stay the global default for a new,
-- empty file; this only overrides them per-buffer once real content disagrees with that
-- default. A previously-open candidate (an active choice, not a template default, in 4 of the 9
-- originally-reviewed reference repos — AUDIT_SUMMARY.md), added now that a plugin addition is
-- an explicit ask.
--
-- `override_editorconfig = false` (upstream default, kept): a project's own `.editorconfig` is
-- a deliberate, committed statement of intent — guessing from buffer content should defer to it,
-- not override it. No keymap: fully automatic (`auto_cmd = true`, upstream default), matching
-- this config's other silent, always-on detectors (colorizer.lua, symbol-usage.lua); `:GuessIndent`
-- still exists for a manual re-check if a buffer's content changes enough to warrant one.
return {
	"nmac427/guess-indent.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {},
}
