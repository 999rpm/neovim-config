-- nvim-zh/colorful-winsep.nvim: colours the separator around the active window. The coloured lines are floating windows
-- that slide to the next window's edges, so the plugin stays off under Neovide, which draws every float with a shadow
-- and animates its moves: the separators would leave grey bars and shadow streaks across the code.
return {
	"nvim-zh/colorful-winsep.nvim",
	cond = not vim.g.neovide, -- Neovide keeps the plain WinSeparator lines
	event = "WinLeave",
	opts = {
		border = "rounded",
		excluded_ft = {
			"snacks_picker_list",
			"snacks_picker_input",
			"snacks_dashboard",
			"mason",
			"neo-tree",
			"trouble",
			"lazy",
		},
	},
}
