-- folke/noice.nvim: replaces the cmdline, search, and message UI with floating/popup views;
-- takes over `vim.notify` and routes it through nvim-notify (plugins/ui/notify.lua) so every
-- plain `vim.notify(...)` call elsewhere in this config (utils.lua's cowboy(), autocmds.lua's
-- file-change warning, etc.) renders as a toast instead of a plain `:messages` line.
--
-- Cross-checked against plugins/completion/blink.lua (Blink handles the completion menu, Noice
-- handles cmdline/search/message UI — `cmdline` below is tuned not to fight Blink's own popup)
-- and options.lua (`cmdheight = 0` there assumes Noice owns cmdline rendering).
return {
	"folke/noice.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify", -- full config in plugins/ui/notify.lua; listed here for install/load ordering only
	},

	opts = {
		------------------------------------------------------------------
		-- LSP Integration
		------------------------------------------------------------------
		lsp = {
			-- Disable signature help here; Blink handles it faster/better
			signature = { enabled = false },
			hover = { enabled = true },
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
		},

		------------------------------------------------------------------
		-- Cmdline UI
		------------------------------------------------------------------
		cmdline = {
			enabled = true,
		},

		------------------------------------------------------------------
		-- Messages & Notifications
		------------------------------------------------------------------
		messages = {
			enabled = true,
			view = "mini", -- Use mini view for less distraction
			view_error = "mini",
			view_warn = "mini",
		},

		------------------------------------------------------------------
		-- Presets
		------------------------------------------------------------------
		presets = {
			bottom_search = true, -- Classic search position
			command_palette = true, -- Position cmdline in center
			long_message_to_split = true,
			inc_rename = false, -- Use standard rename for now
			lsp_doc_border = false, -- Blink/LSP handles borders
		},

		------------------------------------------------------------------
		-- Routes (Noise Reduction)
		------------------------------------------------------------------
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
