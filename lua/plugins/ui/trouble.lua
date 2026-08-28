-- folke/trouble.nvim: list-style views for diagnostics/symbols/LSP-locations/quickfix, under
-- the `<leader>d` group (which-key.lua labels it "Trouble (diagnostics UI)" specifically to
-- distinguish it from lspconfig.lua's own native diagnostic *actions* under `<leader>x`).
-- `[d`/`]d` are deliberately NOT mapped here — those are Neovim's own built-in diagnostic-jump
-- defaults (documented in lspconfig.lua's LSP-defaults comment box); Trouble's list is one
-- keypress away via `<leader>dd` instead.
return {
	"folke/trouble.nvim",
	cmd = "Trouble",

	dependencies = { "echasnovski/mini.nvim" },

	------------------------------------------------------------------
	-- Keymaps (Diagnostics & Lists)
	------------------------------------------------------------------
	keys = {
		-- Diagnostics
		{ "<leader>dd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (All)" },
		{
			"<leader>dD",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Diagnostics (Buffer)",
		},

		-- Symbol & LSP views (diagnostic-adjacent)
		{ "<leader>ds", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
		{ "<leader>dl", "<cmd>Trouble lsp toggle focus=false<cr>", desc = "LSP Locations" },

		-- Quickfix
		{ "<leader>dq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
	},

	------------------------------------------------------------------
	-- Options
	------------------------------------------------------------------
	opts = {
		focus = false,
		auto_preview = true,

		win = {
			border = "rounded",
		},

		----------------------------------------------------------------
		-- Icons. fold_open/fold_closed/folder_closed/folder_open below are trouble.nvim's own
		-- current defaults (lua/trouble/config/init.lua), restated explicitly. Diagnostic
		-- severity icons (Error/Warn/Hint/Info) are NOT configured here on purpose: confirmed by
		-- reading lua/trouble/format.lua directly that `severity_icon` pulls from
		-- `vim.diagnostic.config().signs.text[severity]` - i.e. lspconfig.lua's diagnostic signs
		-- - not from an `icons.kinds` table. `use_diagnostic_signs` (previously set above) doesn't
		-- exist as an option in trouble.nvim's current source either (grepped the whole plugin,
		-- zero matches) - both were silently-ignored dead config from an older version of the
		-- plugin, removed rather than "fixed" since there was nothing real to fix.
		----------------------------------------------------------------
		icons = {
			indent = {
				top = "│ ",
				middle = "├╴",
				last = "╰╴",
				fold_open = " ",
				fold_closed = " ",
			},
			folder_closed = " ",
			folder_open = " ",
		},
	},
}
