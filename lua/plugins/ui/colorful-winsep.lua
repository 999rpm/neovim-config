-- nvim-zh/colorful-winsep.nvim: colours the separator around the active window.
return {
	"nvim-zh/colorful-winsep.nvim",
	event = "WinLeave",
	opts = {
		border = "rounded",
		excluded_ft = { "packer", "snacks_picker_list", "snacks_picker_input", "mason", "neo-tree", "alpha", "Trouble", "trouble", "lazy" },
	},
}
