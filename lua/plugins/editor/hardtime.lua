-- m4xshen/hardtime.nvim: blocks repeated h/j/k/l (and friends) past a short threshold and
-- suggests the more efficient motion instead — replaces utils.lua's old cowboy() (LazyVim-derived
-- hjkl throttle), removed in the same pass this file was added. cowboy() only nagged after 10
-- consecutive presses with no count prefix; hardtime is stricter by design (default: more than 3
-- presses of the same key within 1s blocks the next one) and adds hint messages that name the
-- better motion, not just a warning to slow down.
--
-- `lazy = false`, not an `event` like most of this config's other editor/*.lua files: upstream's
-- own installation instructions specify this (README.md's "Installation" section — verified
-- against the current repo, not memory), since hardtime needs to be watching keys from the very
-- first buffer, not deferred to VeryLazy. It also self-delays its own activation by 500ms
-- internally (lua/hardtime/init.lua's `M.setup`, confirmed by reading it directly) to let the
-- rest of startup settle first — `lazy = false` just starts that internal countdown as early as
-- possible; it doesn't make hardtime block the very first frame.
--
-- Two deliberate departures from upstream defaults, everything else left as-is:
--   • `disable_mouse = false` — upstream defaults this to `true`, which would fight
--     options.lua's own `opt.mouse = "n"` (mouse enabled in Normal mode, on purpose) and outright
--     break plugins/editor/multicursor.lua's Ctrl+click add/remove-cursor feature, which needs
--     the mouse enabled. Confirmed live: without this override, hardtime forces `vim.o.mouse`
--     back to `""` on activation, overriding options.lua's own choice.
--   • `restricted_keys["-"]` — cowboy() throttled `-` alongside `+`/hjkl; upstream's own
--     restricted_keys ships `+` but not its natural counterpart `-`. Added back for the same
--     symmetry cowboy() already had. Deep-merges into upstream's table (confirmed live — every
--     other default restricted key, and the full 34-entry disabled_filetypes list, is untouched).
--
-- `disabled_filetypes` is left at upstream's own default (not overridden): checked it against
-- every dashboard/tree/picker/notification surface this config actually installs — alpha,
-- Avante, dapui.*, Diffview.*, lazy, mason, neo-tree.*, neotest-summary, noice, notify, oil,
-- TelescopePrompt, Trouble/trouble, qf — all already excluded by name upstream, so adding a
-- config-specific override here would just duplicate what's already covered.
--
-- `showmode = false` (options.lua) is already exactly what upstream's README recommends for
-- seeing hint messages properly in Insert/Visual mode, and hint/notification messages go through
-- plain `vim.notify()`, which noice.lua already routes to nvim-notify as a toast — no separate
-- integration needed on either end.
--
-- `<leader>tH` below toggles it on/off for a task that genuinely needs rapid repeated movement
-- (bulk `jjjj`-scrolling to eyeball a diff, etc.) without editing this file — `:Hardtime report`
-- (not bound to a key, upstream command only) shows which habits you hit most.
return {
	"m4xshen/hardtime.nvim",
	lazy = false,
	dependencies = { "MunifTanjim/nui.nvim" }, -- shared; see plugins/deps/shared.lua for the other consumers
	opts = {
		disable_mouse = false, -- see header — upstream default (true) breaks multicursor.lua's Ctrl+click
		restricted_keys = {
			["-"] = { "n", "x" }, -- parity with the "+" upstream already restricts; cowboy() had both
		},
	},
	keys = {
		{
			"<leader>tH",
			"<cmd>Hardtime toggle<CR>",
			desc = "Toggle Hardtime",
		},
	},
}
