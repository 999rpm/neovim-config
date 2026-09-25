-- nvim-mini/mini.nvim: mini.icons (icon provider, also stands in for nvim-web-devicons) and mini.ai (text objects).
-- mini.ai: a/i + b brackets, q quotes, t tag, a argument, ? prompt; aN/iN and al/il pick the next/last match.
-- an/in stay 0.12's node selection and g] stays the built-in :tselect, so mini.ai's g[/g] edge jumps are off.
return {
	"nvim-mini/mini.nvim",
	version = "*",
	lazy = false,
	priority = 1000, -- icons must exist before the dashboard and barbar draw
	config = function()
		require("mini.icons").setup()
		require("mini.icons").mock_nvim_web_devicons()
		require("mini.ai").setup({
			n_lines = 500,
			custom_textobjects = {
				f = false, -- af/if come from textobjects.lua (function definition)
			},
			mappings = {
				around_next = "aN", -- off an/in: 0.12 maps those in x and o to select the parent and child treesitter node
				inside_next = "iN",
				goto_left = "", -- empty disables; g] is the built-in :tselect
				goto_right = "",
			},
		})
	end,
}
