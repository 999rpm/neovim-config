-- Bekaboo/dropbar.nvim: clickable breadcrumbs in the winbar; fuzzy find inside a menu uses telescope-fzf-native's
-- library (deps/shared.lua), loaded on its first require. Owns <leader>ub.
return {
	"Bekaboo/dropbar.nvim",
	event = { "BufReadPost", "BufNewFile" },
	-- dropbar's own keys in a menu: <CR> open, i fuzzy find (then <C-n>/<C-p> or <C-j>/<C-k> move), q or <Esc> close.
	keys = {
		{
			"<leader>ub",
			function()
				require("dropbar.api").pick()
			end,
			desc = "Pick breadcrumb",
		}, -- n: each crumb shows a letter; typing it opens that crumb's menu
	},
	opts = {
		bar = {
			hover = false, -- mouse is normal-mode only (options.lua)
		},
		menu = {
			win_configs = { border = "rounded" },
			keymaps = {
				["<Tab>"] = "j", -- menu: next entry, as Tab moves through every menu here
				["<S-Tab>"] = "k", -- menu: previous entry
			},
		},
	},
}
