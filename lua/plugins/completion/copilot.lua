-- zbirenbaum/copilot.lua: GitHub Copilot inline (ghost-text) suggestions — a different kind of
-- AI assistance than blink.cmp's completion menu (accept/cycle keymaps below are entirely
-- separate from blink.lua's `<Tab>`/`<CR>`, so the two don't compete for the same keys).
return {
	"zbirenbaum/copilot.lua",
	opts = {
		suggestion = {
			auto_trigger = true,
			keymap = {
				accept = "<C-l>",
				accept_word = "<M-l>",
				accept_line = "<M-S-l>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
		},
		filetypes = {
			markdown = true,
			help = true,
		},
	},
}
