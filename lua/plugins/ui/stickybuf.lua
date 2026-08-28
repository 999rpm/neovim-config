-- stevearc/stickybuf.nvim: pins a sidebar/utility window to its own buffer, so a stray `gf`,
-- `:bnext`, or LSP jump can't silently replace plugins/explorer/neo-tree.lua's tree or
-- plugins/debug/dap-ui.lua's panels with a real file — the wrong buffer just gets rerouted to
-- the nearest normal window instead. A previously-open candidate (AUDIT_SUMMARY.md), added now
-- that a plugin addition is an explicit ask.
--
-- Upstream's own built-in filetype list (lua/stickybuf.lua's `builtin_supported_filetypes`,
-- verified against current source) already covers quickfix/help/neotest/toggleterm/nvim-notify/
-- neo-tree/nvim-dap-ui/grug-far by name — every one of those is already installed here. It does
-- NOT cover plugins/explorer/oil.lua, plugins/ui/trouble.lua, lazy.nvim's own `:Lazy` window, or
-- mason.nvim's `:Mason` window, so `get_auto_pin` below layers those four on top rather than
-- replacing upstream's own function outright: falls through to
-- `require("stickybuf").should_auto_pin()` (the README's own documented pattern for extending
-- this callback) for everything upstream already recognizes, including its internal special
-- cases (`TelescopePrompt` deliberately un-pinned, DAP prompt buffers pinned by `bufnr` not
-- `filetype`) that would otherwise need reimplementing here to match exactly.
return {
	"stevearc/stickybuf.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		get_auto_pin = function(bufnr)
			local extra_filetypes = {
				oil = true,
				Trouble = true,
				trouble = true,
				lazy = true,
				mason = true,
			}
			if extra_filetypes[vim.bo[bufnr].filetype] then
				return "filetype"
			end
			return require("stickybuf").should_auto_pin(bufnr)
		end,
	},
}
