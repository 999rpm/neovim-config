-- folke/snacks.nvim: grab-bag of small QoL modules (bigfile handling, scratch buffers, zen
-- mode, lazygit/gitbrowse launchers, quickfile, scroll easing, indent guides). Several modules
-- are deliberately disabled below because this config already has a dedicated tool doing the
-- same job — each disabled line says which: `statuscolumn` (plugins/ui/statuscol.lua +
-- options.lua), `dashboard` (plugins/ui/alpha.lua), `bigfile` (config/autocmds.lua's own
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
-- as every other indent-guide plugin. Default highlight groups are deliberately single-color
-- (`SnacksIndent` -> `NonText`, `SnacksIndentChunk`/`SnacksIndentScope` -> `Special`) rather
-- than the numbered `SnacksIndent1..8` rainbow cycle snacks.indent also supports — left off on
-- purpose, this is the "less noise" side of that option, not an oversight.
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
			indent = { char = "│" }, -- plain per-level guide everywhere except the current scope
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
