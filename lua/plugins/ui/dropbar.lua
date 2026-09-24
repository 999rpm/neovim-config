-- Bekaboo/dropbar.nvim: clickable breadcrumbs in the winbar. <leader>ub picks a crumb by label.
-- Menu keys: <Tab>/<S-Tab> down/up, <CR> open, i fuzzy find, q or <Esc> close.
return {
	"Bekaboo/dropbar.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-telescope/telescope-fzf-native.nvim" }, -- fuzzy find inside menus
	keys = {
		{
			"<leader>ub",
			function()
				require("dropbar.api").pick()
			end,
			desc = "Pick breadcrumb",
		},
	},
	opts = {
		bar = {
			hover = false, -- mouse is normal-mode only (options.lua)
		},
		menu = {
			win_configs = { border = "rounded" },
			keymaps = {
				["<Tab>"] = "j",
				["<S-Tab>"] = "k",
			},
		},
	},
}
