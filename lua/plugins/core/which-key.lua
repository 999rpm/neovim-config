-- folke/which-key.nvim: shows what follows a prefix. Groups here name every prefix used across the config.
-- Press <leader> and wait, or ? for buffer-local keys; <PageUp>/<PageDown> scroll a long popup.
-- Grouping rules, applied throughout: a prefix collects one kind of thing, the lowercase key is the common action and
-- its uppercase twin the wider or rarer form (f/F file, s/S scope, t/T terminal vs test, d/D diagnostics vs debug,
-- g/G hunks vs review). Nothing that only turns something on or off lives outside <leader>o. One kind of thing, one
-- group: every diagnostic view is under <leader>d, every LSP list and workspace folder under <leader>l. <leader>n is the
-- notes graph, <leader>y the yank and register helpers; markdown buffers add their own \m \l \t \h groups.
-- A spec entry carrying only `desc` is a label, not a mapping: which-key calls vim.keymap.set only for entries that
-- also carry an rhs, so the gr* and g* entries at the end name Nvim's own keys and commands without taking them over.
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
