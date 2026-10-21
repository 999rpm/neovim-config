-- zbirenbaum/copilot.lua: inline suggestions. Needs Node 22+ (the plugin checks the version itself; :checkhealth
-- copilot) and :Copilot auth once. Owns <leader>oa and insert-mode <C-l>, <M-l>, <M-S-l>, <M-]>, <M-[> and <M-e>.
-- <C-l> acts only while a grey suggestion shows; copilot hides it while the popup menu is open, so the menu keeps its
-- CTRL-L.
return {
	"zbirenbaum/copilot.lua",
	event = "InsertEnter",
	keys = {
		{ "<leader>oa", "<cmd>Copilot toggle<cr>", desc = "Toggle Copilot" }, -- n: attach or detach Copilot for this buffer; detached, no grey suggestions appear (a for assistant)
	},
	opts = {
		suggestion = {
			auto_trigger = true,
			trigger_on_accept = false, -- <C-l> with no suggestion reaches Neovim; true swallows it to ask for one
			keymap = {
				accept = "<C-l>", -- i: upgrades built-in <C-l>: the grey suggestion while one shows, else the built-in
				accept_word = "<M-l>", -- i: Alt+l, only its next word
				accept_line = "<M-S-l>", -- i: Alt+Shift+l, only its first line
				next = "<M-]>", -- i: Alt+], the next suggestion in place
				prev = "<M-[>", -- i: Alt+[, the previous one
				dismiss = "<M-e>", -- i: Alt+e hides the suggestion; <C-]> stays the built-in abbreviation trigger
			},
		},
		panel = { enabled = false }, -- <M-]>/<M-[> cycle suggestions in place; the panel's <M-CR> is markdown-plus's <A-CR>
		filetypes = {
			markdown = true,
			help = true,
		},
	},
	config = function(_, opts)
		require("copilot").setup(opts)
		for _, group in ipairs({ "CopilotSuggestion", "CopilotAnnotation" }) do
			vim.api.nvim_set_hl(0, group, { link = "Comment", default = true }) -- copilot links them only while empty, once; as a default, utils/themes.lua restores them after a theme switch
		end
	end,
}
