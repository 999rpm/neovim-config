-- zbirenbaum/copilot.lua: inline suggestions. Needs Node 22+ (the plugin checks the version itself; :checkhealth copilot) and :Copilot auth once.
-- Keys (insert): <C-l> accept, <M-l> accept word, <M-S-l> accept line, <M-]>/<M-[> next/previous, <M-e> dismiss.
return {
	"zbirenbaum/copilot.lua",
	event = "InsertEnter",
	opts = {
		suggestion = {
			auto_trigger = true,
			keymap = {
				accept = "<C-l>",
				accept_word = "<M-l>",
				accept_line = "<M-S-l>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<M-e>", -- <C-]> stays the native insert-mode abbreviation trigger
			},
		},
		filetypes = {
			markdown = true,
			help = true,
		},
	},
}
