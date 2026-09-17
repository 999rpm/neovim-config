-- folke/noice.nvim: command line, messages and LSP progress as floating UI.
-- Keys: <leader>sm history, <leader>ud dismiss, <C-f>/<C-b> scroll hover and docs.
return {
	"folke/noice.nvim",
	dependencies = { "MunifTanjim/nui.nvim" },

	opts = {
		lsp = {
			signature = { enabled = false },
			hover = { enabled = true },
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},

		cmdline = {
			enabled = true,
		},

		notify = { enabled = false }, -- snacks.notifier owns vim.notify; see header
		messages = {
			enabled = true,
			view = "mini", -- Use mini view for less distraction
			view_error = "mini",
			view_warn = "mini",
		},

		presets = {
			bottom_search = true, -- Classic search position
			command_palette = true, -- Position cmdline in center
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
				filter = { event = "msg_show", find = "search hit BOTTOM" },
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
