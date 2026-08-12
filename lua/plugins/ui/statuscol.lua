-- luukvbaal/statuscol.nvim: click-able, clean-fold-aware statuscolumn (line numbers + sign
-- column + fold column) — replaces the hand-written `'statuscolumn'` string options.lua would
-- otherwise need. `builtin.foldfunc` renders one glyph per nesting level, up to however wide
-- options.lua's `foldcolumn` resolves to ("auto:4" — see that file's note on why this needs to
-- be wider than 1 to show nesting at all).
return {
	{
		"luukvbaal/statuscol.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local builtin = require("statuscol.builtin")

			require("statuscol").setup({
				relculright = true, -- matches this config's hybrid number setup (options.lua)
				segments = {
					{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" }, -- line numbers
					{ text = { "%s" }, click = "v:lua.ScSa" }, -- sign column (diagnostics/git)
					{ text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" }, -- fold column
				},
			})
		end,
	},
}
