-- akinsho/git-conflict.nvim: highlights merge-conflict markers and gives buffer-local commands
-- to pick a side — a gap plugins/git/gitsigns.lua's hunk staging and plugins/git/diffview.lua's
-- full-repo diff views don't cover (neither is about an in-progress conflict marker in a single
-- file). A previously-open candidate (AUDIT_SUMMARY.md), added now that a plugin addition is an
-- explicit ask.
--
-- `default_mappings = true` (upstream default, kept): its buffer-local `co`/`ct`/`cb`/`c0`/`]x`/
-- `[x` only activate inside a buffer where a real conflict is currently detected (wired through
-- this plugin's own `GitConflictDetected`/`GitConflictResolved` User autocommands) — checked
-- against this config's full keymap inventory for anything that would collide in that specific
-- context: nothing here binds `co`/`ct`/`cb`/`c0` at all, and outside an actual conflicted
-- buffer they're unaffected (e.g. `c0` still means Neovim's native "change to column 0"
-- everywhere else). `]x`/`[x` (jump between conflicts) are new, always-available letters,
-- confirmed free.
return {
	"akinsho/git-conflict.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {},
}
