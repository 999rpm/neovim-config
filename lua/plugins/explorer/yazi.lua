-- mikavilpas/yazi.nvim: the yazi file manager in a float. Needs yazi on $PATH. Owns <leader>ey.
return {
	"mikavilpas/yazi.nvim",
	cmd = { "Yazi" },
	-- yazi.nvim's own keys in the float: <F1> help, <C-v>/<C-x>/<C-t> open in vsplit/split/tab, <C-o> open in a picked
	-- window, <C-s> grep and <C-g> replace in the folder, <C-y> copy relative paths, <C-q> selection to quickfix,
	-- <C-\> make the folder the working directory, <Tab> cycle open buffers.
	keys = {
		{
			"<leader>ey",
			function()
				local core = require("utils.core")
				if core.executable("yazi") then
					require("yazi").yazi()
				else
					core.warn_if_missing_exec("yazi", "yazi.nvim", "Install it from the yazi-rs project first.")
				end
			end,
			desc = "Open yazi at this file",
		}, -- n: the file manager in a float, on the current file (y for yazi)
	},
	opts = {},
}
