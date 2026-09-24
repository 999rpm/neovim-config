-- goolord/alpha-nvim: start screen (startify layout) when Neovim opens without a file. e new file, q quit, a number opens that recent file.
return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-mini/mini.nvim" },
	config = function()
		local startify = require("alpha.themes.startify")
		startify.file_icons.provider = "devicons"
		require("alpha").setup(startify.config)
	end,
}
