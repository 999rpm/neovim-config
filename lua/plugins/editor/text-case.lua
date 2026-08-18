-- johmsalas/text-case.nvim: convert word/selection case — snake_case, camelCase, PascalCase,
-- kebab-case, CONSTANT_CASE, Title Case, and more (native Nvim only has gu/gU/g~ for plain
-- upper/lower/toggle, all left untouched — this is additive, not a replacement for those).
--
-- `prefix = "ga"` is the plugin's own default, kept as-is: native `ga` (show the decimal/hex/
-- octal value of the char under cursor, :h ga) is rarely used, and text-case's own `ga.` opens
-- a Telescope picker over every case style — telescope.nvim is already installed here, no new
-- dependency. `lazy = false`: text-case.nvim's own issue tracker documents its which-key names
-- sometimes failing to register under lazy-loading; loading eagerly sidesteps that outright
-- rather than working around it.
return {
	"johmsalas/text-case.nvim",
	lazy = false,
	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		require("textcase").setup({})
		require("telescope").load_extension("textcase")
	end,
	keys = {
		"ga",
		{ "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Case: Telescope Picker" },
	},
}
