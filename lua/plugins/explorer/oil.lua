-- stevearc/oil.nvim: edit a directory like a buffer; writing the buffer applies the renames, creates and deletes.
-- Keys: <leader>eP open the buffer's directory, <leader>ef the same in a float.
-- In an oil buffer: <CR> open, - parent directory, _ cwd, g? help, gs sort, g. hidden files, <C-p> preview, <C-c> close.
-- Renaming or moving a file there and writing the buffer asks the language servers to update imports (Snacks.rename).
return {
	"stevearc/oil.nvim",
	cmd = "Oil",
	init = function()
		if vim.fn.argc() == 1 then
			local stat = vim.uv.fs_stat(vim.fn.argv(0))
			if stat and stat.type == "directory" then
				require("lazy").load({ plugins = { "oil.nvim" } })
			end
		end
	end,
	keys = {
		{ "<leader>eP", "<cmd>Oil<cr>", desc = "Edit directory (buffer)" },
		{ "<leader>ef", "<cmd>Oil --float<cr>", desc = "Edit directory (float)" },
	},
	opts = {
		default_file_explorer = true,
		view_options = {
			show_hidden = true,
		},
	},
	config = function(_, opts)
		require("oil").setup(opts)
		vim.api.nvim_create_autocmd("User", {
			group = require("utils").augroup("oil-rename"),
			pattern = "OilActionsPost",
			desc = "999rpm: language servers update imports after oil moves a file",
			callback = function(ev)
				for _, action in ipairs(ev.data and ev.data.actions or {}) do
					if action.type == "move" then
						Snacks.rename.on_rename_file(
							(action.src_url:gsub("^oil://", "")),
							(action.dest_url:gsub("^oil://", ""))
						) -- oil:// urls to paths
					end
				end
			end,
		})
	end,
}
