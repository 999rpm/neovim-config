-- folke/trouble.nvim: diagnostics, symbols and LSP locations in a list.
-- Keys: <leader>dd all diagnostics, dD this buffer, ds symbols, dl LSP locations, dq quickfix. The same group holds
-- mappings.lua's df (line float), db and dw (buffer and workspace to the plain quickfix list).
-- In the list: <Tab>/<S-Tab> next/previous, <CR> jump, o jump and close, p preview, P auto preview, q close.
return {
	"folke/trouble.nvim",
	cmd = "Trouble",

	keys = {
		{ "<leader>dd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (all)" },
		{
			"<leader>dD",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Diagnostics (buffer)",
		},

		{ "<leader>ds", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
		{ "<leader>dl", "<cmd>Trouble lsp toggle focus=false<cr>", desc = "LSP locations" },

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
				fold_open = "󰅀 ",
				fold_closed = "󰅂 ",
			},
			folder_closed = "󰉋 ",
			folder_open = "󰝰 ",
		},
	},
}
