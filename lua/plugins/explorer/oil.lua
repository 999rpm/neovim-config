-- stevearc/oil.nvim: edit a directory like a buffer; writing the buffer applies the renames, creates and deletes.
-- Keys: <leader>eP open the buffer's directory, <leader>ef the same in a float.
-- In an oil buffer: <CR> open, - parent directory, _ cwd, g? help, gs sort, g. hidden files, <C-p> preview, <C-c> close.
return {
	"stevearc/oil.nvim",
	cmd = "Oil",
	dependencies = { "nvim-mini/mini.nvim" },
	init = function()
		if vim.fn.argc() == 1 then
			local stat = vim.uv.fs_stat(vim.fn.argv(0))
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
