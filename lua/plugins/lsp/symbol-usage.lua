-- Wansmer/symbol-usage.nvim: reference counts above functions and methods.
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
