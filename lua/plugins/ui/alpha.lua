-- goolord/alpha-nvim: startify-themed start screen (recent files, sessions, etc). The only
-- dashboard plugin active — snacks.lua's own `dashboard` module is disabled in favor of this
-- one, which has real configuration (startify theme, devicons provider) rather than a bare
-- default toggle.
return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local startify = require("alpha.themes.startify")
		-- available: devicons, mini, default is mini
		startify.file_icons.provider = "devicons"
		require("alpha").setup(startify.config)
	end,
}
