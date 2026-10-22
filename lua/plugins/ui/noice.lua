-- folke/noice.nvim: command line, messages and LSP progress as floating UI. noice maps no keys itself; :Noice dismiss
-- clears the views. Owns <leader>sm under snacks.lua's search group.
return {
	"folke/noice.nvim",
	lazy = false, -- keys alone would defer it, and the command line UI is needed from the first :
	keys = {
		{ "<leader>sm", "<cmd>Noice history<cr>", desc = "Message history" }, -- n: :messages output and command-line messages in a split; popups from vim.notify are in <leader>sn
	},
	opts = {
		lsp = {
			signature = { enabled = false },
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},

		notify = { enabled = false }, -- snacks.notifier owns vim.notify
		messages = {
			view = "mini",
			view_error = "mini",
			view_warn = "mini",
		},

		presets = {
			bottom_search = true,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = true,
			lsp_doc_border = true,
		},

		routes = {
			{
				filter = { event = "msg_show", kind = "written" },
				opts = { skip = true },
			},
			{
				filter = {
					event = "lsp",
					kind = "progress",
					cond = function(message)
						local client = vim.tbl_get(message.opts, "progress", "client")
						return client == "basedpyright"
					end,
				},
				opts = { skip = true },
			},
		},
	},
}
