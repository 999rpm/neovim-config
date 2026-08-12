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
			-- K's hover window rendering, not just its border: `lsp.hover.enabled` above makes
			-- Noice register its own `textDocument/hover` handler (confirmed in
			-- lua/noice/lsp/init.lua: `vim.lsp.buf_request(0, "textDocument/hover", params,
			-- require("noice.lsp.hover").on_hover)`), so it's Noice's own "hover" view that
			-- actually gets drawn on K — the `border = border_style` passed to
			-- vim.lsp.buf.hover() in lspconfig.lua never reaches it. That view's own real
			-- default (lua/noice/config/views.lua) is `border = { style = "none" }` — no
			-- border at all, not just a non-rounded one, and NOT inherited from
			-- options.lua's global `winborder = "rounded"` either, since Noice sets `style`
			-- explicitly rather than leaving it unset. `lsp_doc_border = true` is the preset
			-- that actually fixes this (lua/noice/config/preset.lua): it sets exactly
			-- `views.hover.border.style = "rounded"` and nudges the popup's position
			-- slightly for better placement near the cursor. The previous `false` here,
			-- with a comment claiming "Blink/LSP handles borders", was the actual bug —
			-- blink.cmp only borders its OWN completion-doc popup, a different window; it
			-- has no involvement in LSP hover at all once Noice has taken it over.
			lsp_doc_border = true,
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
