-- kylechui/nvim-surround: add, change and delete surrounding pairs. The built-in s and visual S stay untouched. Owns
-- ys, ds, cs and their line forms, insert-mode <C-g>s/<C-g>S, and visual gs/gS.
return {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
	init = function()
		vim.g.nvim_surround_no_visual_mappings = true -- upstream's visual S is the built-in "substitute lines"; gs/gS below take its place
	end,
	-- nvim-surround's own keys: (n) ys{motion}{char} add, yss the whole line, yS/ySS the same onto new lines, ds{char}
	-- delete, cs{old}{new} change, cS change onto new lines; (i) <C-g>s/<C-g>S add around the cursor.
	keys = {
		{ "gs", "<Plug>(nvim-surround-visual)", mode = "x", desc = "Surround selection" }, -- x: then a character: the selection goes inside that pair
		{ "gS", "<Plug>(nvim-surround-visual-line)", mode = "x", desc = "Surround selection on new lines" }, -- x: the same, the pair on lines of its own
	},
	opts = {},
}
