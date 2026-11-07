-- lewis6991/satellite.nvim: scrollbar with marks for diagnostics, search hits, git hunks and cursor position.
return {
	"lewis6991/satellite.nvim",
	event = { "BufReadPost", "BufNewFile" },
	-- satellite's own keys: (n) <LeftMouse> on the scrollbar drags it, upgrades built-in <LeftMouse>, which clicks as
	-- before everywhere else.
	opts = {
		excluded_filetypes = {
			"neo-tree",
			"snacks_dashboard",
			"trouble",
			"lazy",
			"mason",
			"snacks_picker_list",
			"snacks_picker_input",
		},
	},
}
