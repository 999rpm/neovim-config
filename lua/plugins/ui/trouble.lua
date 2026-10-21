-- folke/trouble.nvim: diagnostics, symbols and LSP locations in a list. Owns <leader>dd, dD, ds, dl and dq; the same
-- group holds mappings.lua's df (line float), db and dw (buffer and workspace to the plain quickfix list).
return {
	"folke/trouble.nvim",
	cmd = "Trouble",

	-- trouble's own keys in the list: (n) <CR> jump, o jump and close, <C-s>/<C-v> jump in a split/vsplit, p preview,
	-- P auto preview on or off, }/]] next and {/[[ previous item, dd delete, i inspect, gb this buffer only, s severity
	-- filter, r refresh, z folds, ? help, q close.
	keys = {
		{ "<leader>dd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (all)" }, -- n: every diagnostic of the open buffers in a list
		{
			"<leader>dD",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Diagnostics (buffer)",
		}, -- n: only this buffer's, uppercase twin of dd

		{ "<leader>ds", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" }, -- n: the file's functions, classes and fields in a side list
		{ "<leader>dl", "<cmd>Trouble lsp toggle focus=false<cr>", desc = "LSP locations" }, -- n: definitions, references and calls of the symbol under the cursor

		{ "<leader>dq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" }, -- n: the quickfix list in trouble's view
	},

	opts = {
		keys = {
			["<Tab>"] = "next", -- list: the next item, as Tab moves through every menu here
			["<S-Tab>"] = "prev", -- list: the previous item
		},
		icons = {
			indent = {
				last = "╰╴",
				fold_open = "󰅀 ",
				fold_closed = "󰅂 ",
			},
			folder_closed = "󰉋 ",
			folder_open = "󰝰 ",
		},
	},
}
