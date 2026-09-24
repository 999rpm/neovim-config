-- mikavilpas/yazi.nvim: the yazi file manager in a float (<leader>ey). Needs yazi on $PATH.
-- In the float: <F1> help, <C-v>/<C-x>/<C-t> open in vsplit/split/tab, <C-s> grep and <C-g> replace in the directory,
-- <C-y> copy relative paths, <C-q> selection to quickfix, <Tab> cycle open buffers.
return {
	"mikavilpas/yazi.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "Yazi" },
	keys = {
		{
			"<leader>ey",
			function()
				local utils = require("utils")
				if utils.executable("yazi") then
					require("yazi").yazi()
				else
					utils.warn_if_missing_exec("yazi", "yazi.nvim", "Install it from the yazi-rs project first.")
				end
			end,
			desc = "Open Yazi (current file)",
		},
	},
	opts = {
		open_for_directories = false, -- oil.nvim opens directories
		floating_window_scaling_factor = 0.9,
		yazi_floating_window_border = "rounded",
	},
}
