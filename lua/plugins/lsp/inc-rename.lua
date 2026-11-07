-- smjonas/inc-rename.nvim: live preview while renaming: every occurrence changes on screen as the new name is typed.
-- lspconfig.lua maps it over grn; noice.lua's inc_rename preset draws the prompt. Owns no prefix.
return {
	"smjonas/inc-rename.nvim",
	cmd = "IncRename",
	opts = {},
}
