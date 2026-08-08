-- folke/snacks.nvim: grab-bag of small QoL modules (bigfile handling, scratch buffers, zen
-- mode, lazygit/gitbrowse launchers, quickfile, scroll easing, indent guides). Several modules
-- are deliberately disabled below because this config already has a dedicated tool doing the
-- same job on purpose — each disabled line says which.
--
-- 2026-08-06: config-wide audit (full scope in init.lua). Disabled `indent` — replaced by
-- plugins/ui/indent-blankline.lua, which adds rainbow coloring (shared with rainbow-
-- delimiters.lua) and treesitter-based scope-boundary highlighting that snacks.indent doesn't
-- have; see that file's own header for exactly what it can and can't do relative to
-- snacks.indent (notably: no animation — snacks.indent was the only piece of this config with
-- that, and indent-blankline has no equivalent). Everything else below was re-verified this
-- pass and still holds: `statuscolumn`/`dashboard`/`bigfile` stay off because options.lua,
-- plugins/ui/alpha.lua, and config/autocmds.lua's own `large_file` group already do those jobs
-- (each with real, working configuration, unlike snacks' bare-default versions); the four
-- `<leader>s*` keys that collided with plugins/search/telescope.lua were moved to groups that
-- already fit (Git, Toggle) rather than telescope giving any of its own keys up.
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,

	---@type snacks.Config
	opts = {
		bigfile = { enabled = false }, -- duplicates autocmds.lua's own "large_file" group
		quickfile = { enabled = true },
		indent = { enabled = false }, -- replaced by plugins/ui/indent-blankline.lua — see header note
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
