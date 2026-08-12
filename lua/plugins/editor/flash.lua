-- folke/flash.nvim: labelled jump-to-anywhere-visible motions, replacing several native
-- single-character motions below.
--
-- Native behavior this overrides (for reference — each mapping below carries its own note,
-- and config/mappings.lua's own overrides are documented the same way, inline per-mapping):
--   • `f`/`F` (Normal/Visual/op-pending) — natively "find next/prev occurrence of {char} on
--     this line". `modes.char.enabled = false` above stops flash from also hooking Nvim's
--     built-in f/F/t/T internally; the `keys` below then remap bare `f`/`F` to flash's own
--     jump/treesitter-jump instead. `t`/`T` are untouched and still work natively.
--   • `r` (operator-pending only, e.g. `dr` before a motion) — not a native Normal-mode
--     mapping to begin with (that's plain `r`, unaffected), so this is a new binding, not an
--     override.
--   • `R` (operator-pending AND Visual) — the Visual-mode part *does* override something real:
--     natively, Visual `R` acts like `c` (delete the selection, enter Insert). With this
--     mapping active, Visual `R` runs flash's treesitter-search instead — if you're used to
--     `R` as "replace my selection", this is the one to know about.
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		modes = {
			char = {
				enabled = false, -- stop flash from hooking f/F/t/T internally
			},
		},
	},
	keys = {
		{
			"f",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash",
		},
		{
			"F",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter Search",
		},
		{
			"<C-/>",
			mode = { "c" },
			function()
				require("flash").toggle()
			end,
			desc = "Toggle Flash Search",
		},
	},
}
