-- stevearc/oil.nvim: edit a directory as a normal buffer (rename/delete/create files by
-- editing text and `:w`), instead of plugins/explorer/neo-tree.lua's persistent sidebar tree.
-- `default_file_explorer = true` below plus neo-tree's own `hijack_netrw_behavior =
-- "disabled"` is a deliberate split, not a conflict: opening a directory path directly
-- (`nvim .`, `:e dir/`) goes to oil; the `<leader>ee`/`<leader>er` sidebar toggle is unaffected.
return {
	"stevearc/oil.nvim",
	cmd = "Oil",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	init = function()
		if vim.fn.argc() == 1 then
			local stat = vim.loop.fs_stat(vim.fn.argv(0))
			if stat and stat.type == "directory" then
				require("lazy").load({ plugins = { "oil.nvim" } })
			end
		end
	end,
	keys = {
		{ "<leader>eP", "<cmd>Oil<cr>", desc = "Edit Directory (Buffer)" },
		{ "<leader>ef", "<cmd>Oil --float<cr>", desc = "Edit Directory (Float)" },
	},
	opts = {
		default_file_explorer = true,
		view_options = {
			show_hidden = true,
		},
	},
}
