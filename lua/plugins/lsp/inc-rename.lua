-- smjonas/inc-rename.nvim: live preview while renaming. lspconfig.lua maps it over grn.
return {
	"smjonas/inc-rename.nvim",
	cmd = "IncRename",
	config = function()
		require("inc_rename").setup({})
	end,
}
