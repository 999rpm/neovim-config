-- folke/todo-comments.nvim: highlights and lets you jump/search TODO-style comment keywords
-- (TODO/FIX/HACK/WARN/PERF/NOTE — see `keywords` below for the exact set and their aliases).
-- `<leader>sT` (not `<leader>Ft`) since `:TodoTelescope` is a Telescope picker and belongs in
-- plugins/search/telescope.lua's `<leader>s*` group; `<leader>st` was already taken (Type
-- Definition, telescope.lua's own LSP mapping), so capital `T` it is.
return {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },

	keys = {
		{
			"]t",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "Next Todo",
		},
		{
			"[t",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "Prev Todo",
		},
		{ "<leader>sT", "<cmd>TodoTelescope<cr>", desc = "Find Todos" },
	},

	opts = {
		signs = true,
		highlight = {
			before = "",
			keyword = "wide",
			after = "fg",
		},
		keywords = {
			FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "ISSUE" } },
			TODO = { icon = " ", color = "info" },
			HACK = { icon = " ", color = "warning" },
			WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
			PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
			NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
		},
	},
}
