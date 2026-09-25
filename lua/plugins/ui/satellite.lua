-- lewis6991/satellite.nvim: scrollbar with marks for diagnostics, search hits, git hunks and cursor position.
return {
	"lewis6991/satellite.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		excluded_filetypes = { "neo-tree", "snacks_dashboard", "trouble", "lazy", "mason", "snacks_picker_list", "snacks_picker_input" },
	},
}
