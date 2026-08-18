-- mikavilpas/yazi.nvim: a third file-manager entry point alongside plugins/explorer/neo-tree.lua
-- (persistent sidebar) and plugins/explorer/oil.lua (directory-as-buffer) — this one shells out
-- to the real `yazi` terminal file manager in a floating window, for its preview panes / bulk-
-- rename / archive-browsing that neither of the other two attempt. Needs the `yazi` binary on
-- $PATH (utils.executable() check below, same warn-once shape used elsewhere in this config).
--
-- `open_for_directories = false` is deliberate, not the plugin's own default: yazi.nvim's own
-- README explicitly documents that enabling it means yazi replaces netrw for `nvim <dir>` — but
-- oil.lua already claims that exact role (`default_file_explorer = true`) and neo-tree.lua
-- already disables netrw-hijacking in oil's favor (`hijack_netrw_behavior = "disabled"`).
-- Turning this on too would put oil.nvim and yazi.nvim in a real race over the same "a directory
-- was just opened" event — leaving it off keeps yazi purely on-demand (`<leader>ey` below),
-- which is what "a third option" should mean, not "replaces the second option."
return {
	"mikavilpas/yazi.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "Yazi" },
	keys = {
		{
			"<leader>ey",
			function()
				if require("utils").executable("yazi") then
					require("yazi").yazi()
				else
					vim.notify("'yazi' binary not found on $PATH", vim.log.levels.WARN, { title = "yazi.nvim" })
				end
			end,
			desc = "Open Yazi (current file)",
		},
	},
	opts = {
		open_for_directories = false, -- see header note — oil.nvim already owns this role
		floating_window_scaling_factor = 0.9,
		yazi_floating_window_border = "rounded", -- matches options.lua's global winborder default
	},
}
