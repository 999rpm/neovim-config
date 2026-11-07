-- folke/todo-comments.nvim: highlights TODO, FIX, HACK, WARN, PERF and NOTE comments. ]n/[n in normal mode only:
-- 0.12 holds visual ]n/[n for treesitter nodes. Owns ]n/[n, <leader>st and <leader>sT; the plugin maps no keys itself.
return {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },

	keys = {
		{
			"]n",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "Next todo comment",
		}, -- n: the next TODO, FIX, HACK, WARN, PERF or NOTE (n for note)
		{
			"[n",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "Previous todo comment",
		}, -- n: the previous one
		{
			"<leader>st",
			function()
				Snacks.picker.todo_comments()
			end,
			desc = "Todo comments",
		}, -- n: every such comment in the project, in a picker
		{
			"<leader>sT",
			function()
				Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
			end,
			desc = "Todo and fix comments",
		}, -- n: only TODO, FIX and FIXME, uppercase twin of st
	},

	opts = {
		keywords = { -- nf-md icons; colours and alternative keywords stay upstream's, except that FIX leaves out FIXIT
			FIX = { icon = "󰃤 ", alt = { "FIXME", "BUG", "ISSUE" } },
			TODO = { icon = "󰗡 " },
			HACK = { icon = "󰈸 " },
			WARN = { icon = "󰀦 " },
			PERF = { icon = "󰓅 " },
			NOTE = { icon = "󱇗 " },
		},
	},
}
