-- s1n7ax/nvim-window-picker: pick a window by letter (<leader>ew); neo-tree uses it for split targets.
return {
	"s1n7ax/nvim-window-picker",
	event = "VeryLazy",
	opts = {
		filter_rules = {
			bo = {
				filetype = {
					"NvimTree",
					"neo-tree",
					"notify",
					"snacks_notif",
					"Trouble",
					"trouble",
					"qf",
					"lazy",
					"mason",
					"alpha",
					"snacks_picker_list",
				},
			},
		},
	},
	keys = {
		{
			"<leader>ew",
			function()
				local picked = require("window-picker").pick_window()
				if picked then
					vim.api.nvim_set_current_win(picked)
				end
			end,
			desc = "Pick Window",
		},
	},
}
