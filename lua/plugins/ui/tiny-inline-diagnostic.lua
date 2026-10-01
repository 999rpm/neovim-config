-- rachartier/tiny-inline-diagnostic.nvim: the cursor line's diagnostics drawn inline in a rounded bubble, long messages
-- wrapped below it; other lines keep only their sign. Replaces a hand-written virtual-lines handler that lived in
-- utils.lua. <leader>od (snacks.lua) hides every diagnostic, these included; <leader>df opens the full float.
return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "VeryLazy",
	opts = {
		options = {
			show_source = { enabled = true, if_many = true }, -- the source only when several tools report on one line, as in the float
		},
	},
}
