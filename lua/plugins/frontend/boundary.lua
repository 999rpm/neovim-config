-- Kenzo-Wada/boundary.nvim: marks JSX usages of client components with virtual text showing
-- their 'use client' boundary, for React Server Components work. Fully automatic (`auto = true`
-- re-scans on save/relevant events) — no keymap needed by design, same shape as plugins/ui/
-- colorizer.lua; `:BoundaryRefresh` exists for a manual nudge if the automatic refresh ever
-- feels stale.
return {
	"Kenzo-Wada/boundary.nvim",
	branch = "release",
	ft = { "typescriptreact", "javascriptreact" },
	opts = {
		auto = true,
	},
}
