-- folke/snacks.nvim: grab-bag of small QoL modules (bigfile handling, scratch buffers, zen
-- mode, lazygit/gitbrowse launchers, quickfile, scroll easing, indent guides). Several modules
-- are deliberately disabled below because this config already has a dedicated tool doing the
-- same job — each disabled line says which: `statuscolumn` (plugins/ui/statuscol.lua +
-- options.lua), `dashboard` (plugins/ui/alpha.lua), `bigfile` (autocmds.lua's own
-- `large_file` group).
--
-- `indent` is ON, not off — this config used lukas-reineke/indent-blankline.nvim for a while
-- (rainbow-colored, matching rainbow-delimiters.lua) before switching back here on request: the
-- rainbow coloring read as visual noise in practice. `chunk` (below) is snacks.indent's own
-- box-drawing mode — read `lua/snacks/indent.lua`'s `render_chunk` directly before configuring
-- this rather than assuming: it draws `corner_top`/`corner_bottom`/`horizontal`/`vertical`
-- characters (rounded corners here, matching options.lua's `winborder = "rounded"` elsewhere)
-- plus a closing arrow around whichever scope contains the cursor, animated as you move between
-- scopes (`animate`, on by default for Nvim 0.10+). It is NOT a permanent multi-level tree —
-- only the current scope gets the box; other levels stay plain single-character guides, same
-- as every other indent-guide plugin.
--
-- Per-level guide colour: rainbow again, but not a repeat of the earlier rejected attempt.
-- `indent.hl` below is `utils.rainbow_delimiter_groups` — the exact same 7 RainbowDelimiter*
-- group names rainbow-delimiters.lua points brackets at — not snacks.indent's own independent
-- `SnacksIndent1..8` numbered cycle (still available, see its commented-out example in
-- lua/snacks/indent.lua, confirmed by reading it directly: `indent.hl` accepts either one
-- string or a list, and `get_hl()` cycles through the list by `(level - 1) % #hl + 1`, so a
-- plain 7-entry list works with no extra numbered groups to define). The complaint that
-- prompted removing rainbow the first time was two DIFFERENT rainbow systems (ibl's own cycle
-- vs. rainbow-delimiters' bracket colours) visually competing; sharing one color source for
-- both brackets and indent levels is the opposite of that — level 3 always looks like level 3,
-- in both places, using literally the same highlight group, not just a similar palette. Because
-- these are group-name lookups (not cached hex), they follow theme switches for free, same as
-- rainbow-delimiters.lua's own groups — see themes.lua's ThemeChanged note for the full picture
-- of what does and doesn't need that event.
--
-- `chunk`/`scope` (the current-scope box and its fallback single-char highlight) deliberately
-- stay their own single-color default (`SnacksIndentChunk`/`SnacksIndentScope` -> `Special`),
-- NOT rainbow-linked like the per-level guides above: the entire point of highlighting the
-- current scope is for it to stand out FROM the (now multi-colored) guides around it — cycling
-- its color along with everything else would defeat that, not extend it.
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,

	---@type snacks.Config
	opts = {
		bigfile = { enabled = false }, -- duplicates autocmds.lua's own "large_file" group
		quickfile = { enabled = true },
		indent = {
			enabled = true,
			indent = {
				char = "│",
				hl = require("utils").rainbow_delimiter_groups, -- see header note: same groups rainbow-delimiters.lua uses for brackets
			},
			animate = { enabled = true, style = "out" }, -- grows outward from the cursor
			scope = { enabled = true }, -- fallback single-char scope highlight for shallow scopes chunk skips (see chunk.enabled note below)
			chunk = {
				enabled = true, -- the box-drawing mode — see header note
				char = {
					corner_top = "╭",
					corner_bottom = "╰",
					horizontal = "─",
					vertical = "│",
					arrow = "╴", -- was ">" by default; a closing dash reads less like a stray gt-sign inline with code
				},
			},
		},
		dashboard = { enabled = false }, -- plugins/ui/alpha.lua already owns the start screen
		scroll = { enabled = true },
		statuscolumn = { enabled = false }, -- plugins/ui/statuscol.lua + options.lua hand-build the statuscolumn; don't fight it
		input = { enabled = false }, -- Handled by plugins/ui/noice.lua
		notifier = { enabled = false }, -- Handled by plugins/ui/noice.lua
		picker = { enabled = false }, -- Disabled (using plugins/search/telescope.lua)
		lazygit = { enabled = true },
		gitbrowse = { enabled = true },
	},

	keys = {
		{
			"<leader>ts",
			function()
				Snacks.scratch()
			end,
			desc = "Toggle Scratch Pad",
		},
		{
			"<leader>tz",
			function()
				Snacks.zen()
			end,
			desc = "Toggle Zen Mode",
		},
		{
			"<leader>gl",
			function()
				Snacks.lazygit()
			end,
			desc = "LazyGit",
		},
		{
			"<leader>gb",
			function()
				Snacks.gitbrowse()
			end,
			desc = "Open in Browser",
		},
		{
			"<leader>sm",
			function()
				vim.cmd("Noice history")
			end,
			desc = "Message History",
		},
	},
	init = function()
		vim.api.nvim_create_user_command("Snacks", function(opts)
			Snacks.debug.inspect(opts.args)
		end, { nargs = "?" })
	end,
}
