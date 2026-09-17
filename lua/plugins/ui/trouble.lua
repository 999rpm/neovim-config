-- folke/trouble.nvim: diagnostics, symbols and LSP locations in a list under <leader>d.
-- List keys: <Tab>/<S-Tab> next/previous, <CR> jump, o jump and close, p preview, P auto preview, q close.
return {
	"folke/trouble.nvim",
	cmd = "Trouble",

	dependencies = { "nvim-mini/mini.nvim" },

	keys = {
		{ "<leader>dd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (All)" },
		{
			"<leader>dD",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Diagnostics (Buffer)",
		},

		{ "<leader>ds", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
		{ "<leader>dl", "<cmd>Trouble lsp toggle focus=false<cr>", desc = "LSP Locations" },

		{ "<leader>dq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
	},

	opts = {
		keys = {
			["<Tab>"] = "next",
			["<S-Tab>"] = "prev",
		},
		focus = false,
		auto_preview = true,

		win = {
			border = "rounded",
		},

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
