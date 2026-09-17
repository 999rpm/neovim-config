-- folke/todo-comments.nvim: highlights TODO, FIX, HACK, WARN, PERF and NOTE comments.
-- Keys: ]n/[n next/previous todo, <leader>st list them, <leader>sT only TODO and FIX.
return {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },

	keys = {
		{
			"]n",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "Next Todo",
		},
		{
			"[n",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "Prev Todo",
		},
		{
			"<leader>st",
			function()
				Snacks.picker.todo_comments()
			end,
			desc = "Todo comments",
		},
		{
			"<leader>sT",
			function()
				Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
			end,
			desc = "Todo/Fix comments",
		},
	},

	opts = {
		signs = true,
		highlight = {
			before = "",
			keyword = "wide",
			after = "fg",
		},
		keywords = {
			FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "ISSUE" } },
			TODO = { icon = " ", color = "info" },
			HACK = { icon = " ", color = "warning" },
			WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
			PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
			NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
		},
	},
}
