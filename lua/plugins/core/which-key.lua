-- folke/which-key.nvim: shows what follows a prefix. Groups here name every prefix used across the config.
-- Press <leader> and wait, or ? for buffer-local keys; <PageUp>/<PageDown> scroll a long popup.
-- Grouping rules, applied throughout: a prefix collects one kind of thing, the lowercase key is the common action and
-- its uppercase twin the wider or rarer form (f/F file, s/S scope, t/T terminal vs test, d/D lists vs debug,
-- g/G hunks vs review). Nothing that only turns something on or off lives outside <leader>o.
-- A spec entry carrying only `desc` is a label, not a mapping: which-key calls vim.keymap.set only for entries that
-- also carry an rhs, so the gr* and g* entries at the end name Nvim's own keys and commands without taking them over.
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

			{ "<leader>c", group = "Code", icon = "󰅨 " },
			{ "<leader>cs", group = "Snippets", icon = "󰩫 " },
			{ "<leader>m", group = "Multicursor", icon = "󰇀 " },
			{ "<leader>n", group = "No-yank edits & paths", icon = "󰅍 " },
			{ "<leader>r", group = "Replace across files", icon = "󰛔 " },
			{ "<leader>a", desc = "Swap parameter with next", icon = "󰓡 " }, -- textobjects.lua
			{ "<leader>A", desc = "Swap parameter with previous", icon = "󰓡 " },

			{ "<leader>l", group = "LSP pickers", icon = "󰌵 " },
			{ "<leader>w", group = "LSP workspace folders", icon = "󰕮 " },
			{ "<leader>x", group = "Diagnostics to float & quickfix", icon = "󰓙 " },
			{ "<leader>d", group = "Diagnostic lists (Trouble)", icon = "󰦪 " },

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

			{ "<localleader>", group = "Buffer-local (review, grug-far, Octo)", icon = "󰦒 " },

			{ "[", group = "Previous", icon = "󰒮 ", mode = { "n", "x", "o" } },
			{ "]", group = "Next", icon = "󰒭 ", mode = { "n", "x", "o" } },
			{ "g", group = "Goto & operators", icon = "󰆾 ", mode = { "n", "x", "o" } },
			{ "z", group = "Folds, view & spell", icon = "󰘖 ", mode = { "n", "x" } },
			{ "gr", group = "LSP (rename, refs, actions)", icon = "󰌵 ", mode = { "n", "x" } },
			{ "gA", desc = "Change case (then a case key)", icon = "󰬴 ", mode = { "n", "x" } }, -- coerce.lua; ga stays native
			{ "ys", group = "Surround add", icon = "󰅲 " },
			{ "<C-w>", group = "Windows (native)", icon = "󰖮 " },

			{ "grn", desc = "Rename symbol (inc-rename)", icon = "󰑕 " }, -- Nvim's own gr* descs are raw function names
			{ "gra", desc = "Code action", mode = { "n", "x" }, icon = "󰌵 " },
			{ "grr", desc = "References", icon = "󰈇 " },
			{ "gri", desc = "Implementations", icon = "󰡱 " },
			{ "grt", desc = "Type definition", icon = "󰆩 " },
			{ "grx", desc = "Run code lens", icon = "󰅱 " },
			{ "gO", desc = "Document symbols", icon = "󰙅 " },

			{ "gd", desc = "Definition (LSP), else local declaration", icon = "󰳦 " }, -- built-in commands from here on: no keymap table or which-key preset lists them
			{ "gD", desc = "Declaration (LSP), else file-global declaration", icon = "󰳦 " },
			{ "ga", desc = "Character code under cursor", icon = "󰬴 " },
			{ "gJ", desc = "Join lines, no space added", icon = "󰌷 " },
			{ "gq", desc = "Format lines (operator, cursor stays)", mode = { "n", "x" }, icon = "󰉼 " },
			{ "gp", desc = "Paste after, cursor after the text", icon = "󰆒 " },
			{ "gP", desc = "Paste before, cursor after the text", icon = "󰆒 " },
			{ "g&", desc = "Repeat last :s across the file", icon = "󰛔 " },
			{ "gF", desc = "Open file under cursor at its line", icon = "󰈔 " },
			{ "g?", desc = "Rot13 (operator)", mode = { "n", "x" }, icon = "󰅱 " },
		},
	},
}
