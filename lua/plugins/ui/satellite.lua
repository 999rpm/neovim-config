-- lewis6991/satellite.nvim: a right-edge scrollbar marking search matches, diagnostics, git
-- hunks, and marks at their actual line position — a low-priority candidate from the smaller
-- aesthetic group (AUDIT_SUMMARY.md), added now that a plugin addition is an explicit ask.
-- Every handler's own highlight group already links to this config's real, theme-following
-- groups by default (`SatelliteDiagnosticError` -> `DiagnosticError`, `SatelliteGitSignsAdd` ->
-- `GitSignsAdd`, etc. — verified against the current README) — nothing to re-link here the way
-- utils.rainbow_delimiter_groups does for rainbow-delimiters.lua/snacks.lua.
return {
	"lewis6991/satellite.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		excluded_filetypes = { "neo-tree", "alpha", "Trouble", "trouble", "lazy", "mason", "TelescopePrompt" },
	},
}
