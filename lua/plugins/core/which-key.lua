-- folke/which-key.nvim: lists what follows a prefix. Press <leader> and wait, or ? for buffer-local keys;
-- <PageUp>/<PageDown> scroll a long popup.
-- Grouping: a prefix holds one kind of thing, and the lowercase key is the common action, its uppercase twin the wider
-- or rarer one (d/D diagnostics/debug, t/T terminal/test, g/G hunks/review). Every on/off switch sits under <leader>o
-- and nothing else does; the snacks toggles there show their current state. <leader>n is the notes graph, <leader>k
-- the Jupyter kernel, <leader>y yank and register helpers; markdown buffers add \m \l \t \h.
-- An entry with only a desc is a label, not a mapping: which-key sets a keymap only for entries with an rhs, so the g*
-- and gr* labels below name built-in keys without taking them over.
local function markdown()
	return vim.bo.filetype == "markdown"
end

return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		delay = 0,
		keys = {
			scroll_down = "<PageDown>",
			scroll_up = "<PageUp>",
		},
		icons = {
			breadcrumb = "󰔰",
			separator = "󱦰",
			group = "󱡠 ",
		},
		spec = {
			{ "<leader>f", group = "Find files", icon = "󰍉 " }, -- snacks.lua
			{ "<leader>s", group = "Search contents", icon = "󰺯 " },
			{ "<leader>e", group = "Explore", icon = "󰉋 " },
			{ "<leader>b", group = "Buffers", icon = "󱟱 " },
			{ "<leader>h", group = "Harpoon", icon = "󱡀 " },
			{ "<leader>q", group = "Sessions & quit", icon = "󰆓 " },
			{ "<leader><Tab>", group = "Tabs", icon = "󰓩 " }, -- mappings.lua

			{ "<leader>n", group = "Notes (Logseq graph)", icon = "󰠮 " }, -- notes/logseq.lua
			{ "<leader>c", group = "Code", icon = "󰅨 " },
			{ "<leader>cs", group = "Snippets", icon = "󰩫 " },
			{ "<leader>m", group = "Multicursor", icon = "󰇀 " },
			{ "<leader>y", group = "Yank & registers", icon = "󰅍 " }, -- mappings.lua
			{ "<leader>r", group = "Replace across files", icon = "󰛔 " },
			{ "<leader>a", desc = "Swap parameter with next", icon = "󰓡 " }, -- textobjects.lua
			{ "<leader>A", desc = "Swap parameter with previous", icon = "󰓡 " },

			{ "<leader>l", group = "LSP lists & workspace", icon = "󰌵 " }, -- snacks.lua, lspconfig.lua
			{ "<leader>lw", group = "Workspace folders", icon = "󰕮 " },
			{ "<leader>d", group = "Diagnostics (float, quickfix, Trouble)", icon = "󰦪 " }, -- mappings.lua, trouble.lua

			{ "<leader>g", group = "Git", icon = "󰊢 " },
			{ "<leader>go", group = "GitHub (Octo)", icon = "󰊤 " },
			{ "<leader>G", group = "Review (CodeDiff)", icon = "󰦒 " },

			{ "<leader>D", group = "Debug", icon = "󰃤 " },
			{ "<leader>T", group = "Test", icon = "󰙨 " },
			{ "<leader>t", group = "Terminal", icon = "󰆍 " },
			{ "<leader>i", group = "AI", icon = "󰧑 " },
			{ "<leader>k", group = "Kernel & notebook (Jupyter)", icon = "󰘚 " }, -- notebook/molten.lua

			{ "<leader>u", group = "UI & theme", icon = "󰏘 " },
			{ "<leader>o", group = "Toggles (on/off)", icon = "󰔡 " },
			{ "<leader>p", group = "Plugins & tools", icon = "󰏖 " },

			{ "<localleader>", group = "Buffer-local (markdown, review, grug-far, Octo)", icon = "󰦒 " },
			{ "<localleader>m", group = "Markdown: format, links, checkbox", icon = "󰍔 ", cond = markdown }, -- markdown-plus.lua
			{ "<localleader>l", group = "Markdown: list", icon = "󰉹 ", cond = markdown },
			{ "<localleader>t", group = "Markdown: table", icon = "󰓫 ", cond = markdown },
			{ "<localleader>h", group = "Markdown: headings", icon = "󰉷 ", cond = markdown },

			{ "[", group = "Previous", icon = "󰒮 ", mode = { "n", "x", "o" } },
			{ "]", group = "Next", icon = "󰒭 ", mode = { "n", "x", "o" } },
			{ "g", group = "Goto & operators", icon = "󰆾 ", mode = { "n", "x", "o" } },
			{ "z", group = "Folds, view & spell", icon = "󰘖 ", mode = { "n", "x" } },
			{ "gr", group = "LSP (rename, refs, actions)", icon = "󰌵 ", mode = { "n", "x" } },
			{ "gA", desc = "Change case (then a case key)", icon = "󰬴 ", mode = { "n", "x" } }, -- coerce.lua; ga stays native
			{ "ys", group = "Surround add", icon = "󰅲 " },
			{ "<C-w>", group = "Windows (native)", icon = "󰖮 " },
			{ "Z", group = "Write, quit & restart", icon = "󰗼 " },
			{ "ZZ", desc = "Write if changed and close the window" },
			{ "ZQ", desc = "Close the window without writing" },
			{ "ZR", desc = "Restart Neovim, session kept (0.12)" },
			{ "%", desc = "Matching pair or word (matchup)", mode = { "n", "x", "o" }, icon = "󰅪 " }, -- matchup.lua
			{ "g%", desc = "Previous matching word", mode = { "n", "x", "o" }, icon = "󰅪 " },
			{ "[%", desc = "Enclosing open word", mode = { "n", "x", "o" }, icon = "󰅪 " },
			{ "]%", desc = "Enclosing close word", mode = { "n", "x", "o" }, icon = "󰅪 " },
			{ "z%", desc = "Into the next pair", mode = { "n", "x", "o" }, icon = "󰅪 " },

			{ "grn", desc = "Rename symbol (inc-rename)", icon = "󰑕 " }, -- Nvim's own gr* descs are raw function names
			{ "gra", desc = "Code action", mode = { "n", "x" }, icon = "󰌵 " },
			{ "grr", desc = "References", icon = "󰈇 " },
			{ "gri", desc = "Implementations", icon = "󰡱 " },
			{ "grt", desc = "Type definition", icon = "󰆩 " },
			{ "grx", desc = "Run code lens", icon = "󰅱 " },
			{ "gO", desc = "Document symbols (headings in markdown)", icon = "󰙅 " },

			{ "gd", desc = "Definition (LSP), else local declaration", icon = "󰳦 " }, -- built-in commands from here on: no keymap table or which-key preset lists them
			{ "gD", desc = "Declaration (LSP), else file-global declaration", icon = "󰳦 " },
			{ "ga", desc = "Character code under cursor", icon = "󰬴 " },
			{ "gJ", desc = "Join lines, no space added", icon = "󰌷 " },
			{ "gq", desc = "Format lines (operator, cursor on the last line)", mode = { "n", "x" }, icon = "󰉼 " },
			{ "gw", desc = "Format lines (operator, cursor stays)", mode = { "n", "x" }, icon = "󰉼 " },
			{ "gp", desc = "Paste after, cursor after the text", icon = "󰆒 " },
			{ "gP", desc = "Paste before, cursor after the text", icon = "󰆒 " },
			{ "g&", desc = "Repeat last :s across the file", icon = "󰛔 " },
			{ "gF", desc = "Open file under cursor at its line", icon = "󰈔 " },
			{ "g?", desc = "Rot13 (operator)", mode = { "n", "x" }, icon = "󰅱 " },
		},
	},
}
