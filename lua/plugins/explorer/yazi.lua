-- mikavilpas/yazi.nvim: the yazi file manager in a float (<leader>ey). Needs yazi on $PATH.
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
					utils.warn_if_missing_exec("yazi", "yazi.nvim", "Install it from the yazi-rs project first.") -- shared warn-once helper; see utils.lua
				end
			end,
			desc = "Open Yazi (current file)",
		},
	},
	opts = {
		open_for_directories = false, -- see header note; oil.nvim already owns this role
		floating_window_scaling_factor = 0.9,
		yazi_floating_window_border = "rounded", -- matches options.lua's global winborder default
	},
}
