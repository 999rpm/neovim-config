-- hiphish/rainbow-delimiters.nvim: colours matching brackets by depth, sharing the groups in utils.lua.
return {
	"hiphish/rainbow-delimiters.nvim",
	event = { "BufReadPost", "BufNewFile" }, -- same trigger as treesitter.lua
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	submodules = false, -- the only submodule is a test harness hosted on gitlab.com
	init = function()
		vim.g.rainbow_delimiters = { highlight = require("utils").rainbow_delimiter_groups }
	end,
}
