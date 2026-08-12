-- folke/trouble.nvim: list-style views for diagnostics/symbols/LSP-locations/quickfix, under
-- the `<leader>d` group (which-key.lua labels it "Trouble (diagnostics UI)" specifically to
-- distinguish it from lspconfig.lua's own native diagnostic *actions* under `<leader>x`).
-- `[d`/`]d` are deliberately NOT mapped here — those are Neovim's own built-in diagnostic-jump
-- defaults (documented in lspconfig.lua's LSP-defaults comment box); Trouble's list is one
-- keypress away via `<leader>dd` instead.
return {
	"folke/trouble.nvim",
	cmd = "Trouble",

	dependencies = { "nvim-tree/nvim-web-devicons" },

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
		use_diagnostic_signs = true,

		win = {
			border = "rounded",
		},

		----------------------------------------------------------------
		-- Icons (nf-fa / UI-consistent)
		----------------------------------------------------------------
		icons = {
			indent = {
				top = "│ ",
				middle = "├╴",
				last = "╰╴",
				fold_open = " ",
				fold_closed = " ",
			},
			folder_closed = " ",
			folder_open = " ",
			kinds = {
				Error = " ",
				Warn = " ",
				Hint = " ",
				Info = " ",
			},
		},
	},
}
