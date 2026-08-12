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
--   • `<C-s>` in cmdline mode — flash's own documented default for this (its README's "setup"
--     block uses this exact key, never `<c-/>`), not a native mapping either way. It doesn't
--     collide with this config's other `<C-s>` uses (mappings.lua's normal-mode save, and
--     insert-mode signature help in lspconfig.lua) since keymaps are mode-scoped — cmdline,
--     normal, and insert are three separate namespaces. Was `<C-/>` here previously; changed
--     back to match upstream after it stopped registering reliably — `<C-/>` and `<C-_>` are
--     frequently indistinguishable at the raw keycode level depending on terminal/OS keyboard
--     layer, which upstream's own choice of `<C-s>` sidesteps entirely.
--
-- Quick tutorial: press "f" (not the native find-char) and every visible occurrence of the
-- NEXT character you type gets a 1-2 letter label overlaid on it — type that label to jump
-- straight there, from anywhere on screen, not just the current line. "F" does the same but
-- jumps by treesitter node (functions, classes, etc.) instead of by character. This replaces
-- native f/F entirely (see "modes.char.enabled = false" above); t/T are untouched.
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
			-- Toggles flash's jump labels ON TOP of an already-active "/" or "?" search — it
			-- does nothing pressed from Normal mode; press "/" first, THEN this, to label the
			-- matches incremental search is already highlighting. For a direct jump from
			-- Normal mode (no search involved), use "f"/"F" above instead.
			"<C-s>",
			mode = { "c" },
			function()
				require("flash").toggle()
			end,
			desc = "Toggle Flash Search",
		},
	},
}
