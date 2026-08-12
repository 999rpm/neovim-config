-- folke/todo-comments.nvim: highlights and lets you jump/search TODO-style comment keywords
-- (TODO/FIX/HACK/WARN/PERF/NOTE — see `keywords` below for the exact set and their aliases).
-- `<leader>sT` (not `<leader>Ft`) since `:TodoTelescope` is a Telescope picker and belongs in
-- plugins/search/telescope.lua's `<leader>s*` group; `<leader>st` was already taken (Type
-- Definition, telescope.lua's own LSP mapping), so capital `T` it is.
--
-- Jump keys are `]n`/`[n`, not this plugin's own commonly-suggested `]t`/`[t` — those collide
-- with Neovim's *built-in* `[t`/`]t` (`:tprevious`/`:tnext`, ctags tag-stack navigation,
-- confirmed against this config's real installed runtime, $VIMRUNTIME/lua/vim/_core/
-- defaults.lua's "vim-unimpaired style mappings" block). `n` is free (checked against that same
-- block's full key list: d/D, q/Q/<C-q>, l/L/<C-l>, a/A, t/T/<C-t>, b/B are all taken).
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
