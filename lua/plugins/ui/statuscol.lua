-- luukvbaal/statuscol.nvim: click-able, clean-fold-aware statuscolumn (line numbers + sign
-- column + fold column) — replaces the hand-written `'statuscolumn'` string options.lua would
-- otherwise need. `builtin.foldfunc` renders a fold-open/close glyph on any line that starts a
-- fold, regardless of nesting depth (see options.lua's `foldcolumn` note for why width "1" is
-- deliberate here, not a wider stacked column) — fold segment is listed last/rightmost below so
-- its single glyph sits flush against the first indent guide in the text area, not floating in
-- its own strip.
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
