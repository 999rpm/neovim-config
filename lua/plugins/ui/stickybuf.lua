-- stevearc/stickybuf.nvim: keeps utility windows from being replaced by a file buffer.
return {
	"stevearc/stickybuf.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		get_auto_pin = function(bufnr)
			local extra_filetypes = {
				oil = true,
				trouble = true,
				lazy = true,
				mason = true,
			}
			if extra_filetypes[vim.bo[bufnr].filetype] then
				return "filetype"
			end
			return require("stickybuf").should_auto_pin(bufnr)
		end,
	},
}
