-- nvim-zh/colorful-winsep.nvim: colours the separator around the active window.
return {
	"nvim-zh/colorful-winsep.nvim",
	event = "WinLeave",
	opts = {
		border = "rounded",
		excluded_ft = { "snacks_picker_list", "snacks_picker_input", "snacks_dashboard", "mason", "neo-tree", "trouble", "lazy" },
	},
}
