-- hiphish/rainbow-delimiters.nvim: colours matching brackets by depth, sharing the groups in utils.lua.
return {
	"hiphish/rainbow-delimiters.nvim",
	event = { "BufReadPost", "BufNewFile" }, -- matches treesitter.lua's own trigger; needs a parser to rainbow anything
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	submodules = false, -- its only submodule is a gitlab.com-hosted test harness (test/bin), used only by the plugin's own internal test suite; never needed to actually use it, and cloning it needlessly adds a second host + a failure point unrelated to the plugin working
	init = function()
		vim.g.rainbow_delimiters = { highlight = require("utils").rainbow_delimiter_groups }
	end,
}
