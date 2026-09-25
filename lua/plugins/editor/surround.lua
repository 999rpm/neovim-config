-- kylechui/nvim-surround: add, change and delete surrounding pairs. The built-in s and visual S stay untouched.
-- Keys: ys{motion}{char} add, yss whole line, yS/ySS onto new lines, ds{char} delete, cs{old}{new} change, cS onto new lines,
-- gs/gS surround the visual selection, <C-g>s/<C-g>S in insert mode.
return {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
	init = function()
		vim.g.nvim_surround_no_visual_mappings = true -- upstream's visual S is the built-in "substitute lines"; gs/gS below take its place
	end,
	keys = {
		{ "gs", "<Plug>(nvim-surround-visual)", mode = "x", desc = "Surround selection" },
		{ "gS", "<Plug>(nvim-surround-visual-line)", mode = "x", desc = "Surround selection on new lines" },
	},
	opts = {},
}
