-- stevearc/oil.nvim: edit a directory like a buffer; writing the buffer applies the renames, creates and deletes.
-- Renaming or moving a file there and writing the buffer asks the language servers to update imports through oil's
-- own LSP file operations (lsp_file_methods, on by default), so no second request goes out after the move.
-- Owns <leader>eP and <leader>ef.
return {
	"stevearc/oil.nvim",
	cmd = "Oil",
	init = function()
		if vim.fn.argc() == 1 then
			local stat = vim.uv.fs_stat(vim.fn.argv(0) --[[@as string]])
			if stat and stat.type == "directory" then
				require("lazy").load({ plugins = { "oil.nvim" } })
			end
		end
	end,
	-- oil's own keys in its buffer: (n) <CR> open, <C-s>/<C-h>/<C-t> open in a vsplit/split/tab, <C-p> preview, <C-c>
	-- close, <C-l> refresh, - parent directory, _ working directory, ` make it the working directory (g~ for the tab
	-- only), gs sort, gx open outside Neovim, g. hidden files, g\ trash, g? help.
	keys = {
		{ "<leader>eP", "<cmd>Oil<cr>", desc = "Edit directory (buffer)" }, -- n: the file's folder as text: edit the names, then :w applies them
		{ "<leader>ef", "<cmd>Oil --float<cr>", desc = "Edit directory (float)" }, -- n: the same in a floating window
	},
	opts = {
		view_options = {
			show_hidden = true,
		},
	},
}
