-- folke/which-key.nvim: shows what follows a prefix. Groups here name the prefixes used across the config.
-- Press <leader> and wait, or ? for buffer-local keys; <PageUp>/<PageDown> scroll a long popup.
-- Grouping rule: lowercase prefix is the common action, the uppercase twin is its wider or rarer form
-- (d/D lists vs debug, g/G hunks vs review, t/T terminal vs test).
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
			-- Files and navigation
			{ "<leader>f", group = "Find files", icon = "󰍉 " },
			{ "<leader>s", group = "Search contents", icon = "󰺯 " },
			{ "<leader>e", group = "Explore", icon = "󰉋 " },
			{ "<leader>b", group = "Buffers", icon = "󱟱 " },
			{ "<leader>h", group = "Harpoon", icon = "󱡀 " },
			{ "<leader>q", group = "Session", icon = "󰆓 " },
			{ "<leader><Tab>", group = "Tabs", icon = "󰓩 " }, -- config/mappings.lua; moved off a bare `t` so the native t{char} motion works again

			-- Editing
			{ "<leader>c", group = "Code", icon = "󰅨 " },
			{ "<leader>cs", group = "Snippets", icon = "󰩫 " }, -- plugins/editor/nvim-scissors.lua
			{ "<leader>m", group = "Multicursor", icon = "󰇀 " },
			{ "<leader>n", group = "No-yank / Paths / Registers", icon = "󰅍 " },
			{ "<leader>r", group = "Replace (grug-far)", icon = "󰛔 " },
			{ "<leader>a", desc = "Swap parameter with next", icon = "󰓡 " }, -- plugins/treesitter/textobjects.lua
			{ "<leader>A", desc = "Swap parameter with previous", icon = "󰓡 " },

			-- Language servers
			{ "<leader>l", group = "LSP pickers", icon = "󰌵 " },
			{ "<leader>w", group = "Workspace folders (LSP)", icon = "󰕮 " },
			{ "<leader>x", group = "Diagnostics (float & quickfix)", icon = "󰓙 " },
			{ "<leader>d", group = "Diagnostic lists (Trouble)", icon = "󰦪 " },

			-- Version control
			{ "<leader>g", group = "Git (hunks & repo)", icon = "󰊢 " },
			{ "<leader>go", group = "GitHub (Octo)", icon = "󰊤 " }, -- plugins/git/octo.lua
			{ "<leader>G", group = "Review (CodeDiff)", icon = "󰦒 " }, -- plugins/git/codediff.lua

			-- Run and inspect
			{ "<leader>D", group = "Debug", icon = "󰃤 " },
			{ "<leader>T", group = "Test", icon = "󰙨 " },
			{ "<leader>t", group = "Terminal", icon = "󰆍 " },
			{ "<leader>i", group = "AI", icon = "󰧑 " },

			-- Appearance and state
			{ "<leader>u", group = "UI / Workspace", icon = "󰏘 " },
			{ "<leader>o", group = "Options & Toggles", icon = "󰘮 " },
			{ "<leader>of", desc = "Format on save (buffer)", icon = "󰉼 " }, -- neighbours oF; both live in plugins/lang-tools/conform.lua
			{ "<leader>ot", desc = "Switch theme", icon = "󰔎 " },

			{ "<localleader>", group = "Buffer-local (CodeDiff review)", icon = "󰦒 " },

			-- Non-leader prefixes
			{ "[", group = "Prev (jump backward)", icon = "󰒮 ", mode = { "n", "x", "o" } },
			{ "]", group = "Next (jump forward)", icon = "󰒭 ", mode = { "n", "x", "o" } },
			{ "g", group = "Goto / operators", icon = "󰆾 ", mode = { "n", "x", "o" } },
			{ "z", group = "Folds / view / spell", icon = "󰘖 ", mode = { "n", "x" } },
			{ "gr", group = "LSP (rename/refs/actions)", icon = "󰌵 ", mode = { "n", "x" } },
			{ "gA", group = "Case conversion (text-case)", icon = "󰬴 ", mode = { "n", "x" } }, -- moved off native `ga`; see plugins/editor/text-case.lua
			{ "ys", group = "Surround add (nvim-surround)", icon = "󰅲 " },
			{ "<C-w>", group = "Windows (native)", icon = "󰖮 " },
		},
	},
}
