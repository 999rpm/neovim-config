-- smjonas/inc-rename.nvim: live-preview LSP rename via Nvim's command-preview feature — typing
-- a new name updates every occurrence in the buffer as you type, instead of the plain "type a
-- name, hit enter, hope" native prompt. Closes a gap plugins/ui/noice.lua's own `presets.
-- inc_rename` flag already anticipated (was `false`, "use standard rename for now" — flipped to
-- `true` alongside this file so Noice renders the command-preview through its own cmdline UI).
--
-- Overrides `grn` itself (see plugins/lsp/lspconfig.lua's LspAttach keymap box) rather than
-- adding a new key: same muscle memory, better implementation — same trade this config already
-- made for `K` (border + size) over leaving the native default alone.
return {
	"smjonas/inc-rename.nvim",
	cmd = "IncRename",
	config = function()
		require("inc_rename").setup({})
	end,
}
