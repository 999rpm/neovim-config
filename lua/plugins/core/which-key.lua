-- folke/which-key.nvim: shows what follows a prefix. Groups here name the prefixes used across the config.
-- Press <leader> and wait, or ? for buffer-local keys; <PageUp>/<PageDown> scroll a long popup.
-- Grouping rule: lowercase prefix is the common action, the uppercase twin is its wider or rarer form
-- (d/D lists vs debug, g/G hunks vs review, t/T terminal vs test).
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
			{ "<leader>f", group = "Find files", icon = "󰍉 " },
			{ "<leader>s", group = "Search contents", icon = "󰺯 " },
			{ "<leader>e", group = "Explore", icon = "󰉋 " },
			{ "<leader>b", group = "Buffers", icon = "󱟱 " },
			{ "<leader>h", group = "Harpoon", icon = "󱡀 " },
			{ "<leader>q", group = "Session / Quit", icon = "󰆓 " },
			{ "<leader><Tab>", group = "Tabs", icon = "󰓩 " }, -- mappings.lua

			{ "<leader>c", group = "Code", icon = "󰅨 " },
			{ "<leader>cs", group = "Snippets", icon = "󰩫 " },
			{ "<leader>m", group = "Multicursor", icon = "󰇀 " },
			{ "<leader>n", group = "No-yank / Paths / Registers", icon = "󰅍 " },
			{ "<leader>r", group = "Replace (grug-far)", icon = "󰛔 " },
			{ "<leader>a", desc = "Swap parameter with next", icon = "󰓡 " }, -- textobjects.lua
			{ "<leader>A", desc = "Swap parameter with previous", icon = "󰓡 " },

			{ "<leader>l", group = "LSP pickers", icon = "󰌵 " },
			{ "<leader>w", group = "Workspace folders (LSP)", icon = "󰕮 " },
			{ "<leader>x", group = "Diagnostics (float & quickfix)", icon = "󰓙 " },
			{ "<leader>d", group = "Diagnostic lists (Trouble)", icon = "󰦪 " },

			{ "<leader>g", group = "Git (hunks & repo)", icon = "󰊢 " },
			{ "<leader>go", group = "GitHub (Octo)", icon = "󰊤 " },
			{ "<leader>G", group = "Review (CodeDiff)", icon = "󰦒 " },

			{ "<leader>D", group = "Debug", icon = "󰃤 " },
			{ "<leader>T", group = "Test", icon = "󰙨 " },
			{ "<leader>t", group = "Terminal", icon = "󰆍 " },
			{ "<leader>i", group = "AI", icon = "󰧑 " },

			{ "<leader>u", group = "UI", icon = "󰏘 " },
			{ "<leader>o", group = "Options & Toggles", icon = "󰘮 " },

			{ "<localleader>", group = "Buffer-local (review, grug-far, Octo)", icon = "󰦒 " },

			{ "[", group = "Prev (jump backward)", icon = "󰒮 ", mode = { "n", "x", "o" } },
			{ "]", group = "Next (jump forward)", icon = "󰒭 ", mode = { "n", "x", "o" } },
			{ "g", group = "Goto / operators", icon = "󰆾 ", mode = { "n", "x", "o" } },
			{ "z", group = "Folds / view / spell", icon = "󰘖 ", mode = { "n", "x" } },
			{ "gr", group = "LSP (rename/refs/actions)", icon = "󰌵 ", mode = { "n", "x" } },
			{ "gA", desc = "Change case (then a case key)", icon = "󰬴 ", mode = { "n", "x" } }, -- coerce.lua; ga stays native
			{ "ys", group = "Surround add (nvim-surround)", icon = "󰅲 " },
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
