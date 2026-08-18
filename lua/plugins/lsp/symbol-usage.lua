-- Wansmer/symbol-usage.nvim: shows reference counts as virtual text above functions/methods
-- ("3 usages"), sourced from the LSP's own reference data — a JetBrains-IDE-style ambient hint,
-- not an interactive picker (plugins/search/telescope.lua's `<leader>sr` already covers "list
-- every actual reference" when the count alone isn't enough). Fully automatic by design (no
-- keymap here on purpose, matching colorizer.lua/rainbow-delimiters.lua's own no-keymap,
-- always-on shape) — toggle off entirely via `enabled = false` below if it reads as noisy.
return {
	"Wansmer/symbol-usage.nvim",
	event = "LspAttach",
	opts = function()
		local SymbolKind = vim.lsp.protocol.SymbolKind
		return {
			hl = { link = "Comment" }, -- matches this config's other ambient-hint styling (inlay hints use the same LSP-default look)
			kinds = { SymbolKind.Function, SymbolKind.Method },
		}
	end,
}
