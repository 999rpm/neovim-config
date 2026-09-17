-- nvim-mini/mini.nvim: mini.icons (icon provider, also stands in for nvim-web-devicons) and mini.ai (text objects).
-- mini.ai: a/i + b brackets, q quotes, t tag, a argument, ? prompt; an/in and al/il target the next/last match; g[ g] jump to object edges.
return {
	"nvim-mini/mini.nvim",
	version = "*",
	lazy = false,
	priority = 1000, -- icons must exist before alpha and barbar draw
	config = function()
		require("mini.icons").setup()
		require("mini.icons").mock_nvim_web_devicons()
		require("mini.ai").setup({
			n_lines = 500,
			custom_textobjects = {
				f = false, -- af/if come from textobjects.lua (function definition)
			},
		})
	end,
}
