-- folke/which-key.nvim: shows what follows a prefix. Groups here name the prefixes used across the config.
-- Press <leader> and wait, or ? for buffer-local keys; <PageUp>/<PageDown> scroll a long popup.
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
			{ "<leader>c", group = "Code", icon = "󰅨 " },
			{ "<leader>cs", group = "Snippets", icon = "󰩫 " }, -- plugins/editor/nvim-scissors.lua
			{ "<leader>m", group = "Multicursor", icon = "󰇀 " },
			{ "<leader>n", group = "No-yank / Paths / Registers", icon = "󰅍 " },
			{ "<leader>r", group = "Replace (grug-far)", icon = "󰛔 " },

			{ "<leader>b", group = "Buffers", icon = "󱟱 " },
			{ "<leader>e", group = "Explore", icon = "󰉋 " },
			{ "<leader>h", group = "Harpoon", icon = "󱡀 " },
			{ "<leader>f", group = "Find files", icon = "󰍉 " },
			{ "<leader>s", group = "Search", icon = "󰍉 " },
			{ "<leader>l", group = "LSP pickers", icon = "󰌵 " },
			{ "<leader>q", group = "Session", icon = "󰆓 " },
			{ "<leader><Tab>", group = "Tabs", icon = "󰓩 " }, -- config/mappings.lua; moved off a bare `t` so the native t{char} motion works again

			{ "<leader>g", group = "Git (hunks & repo)", icon = "󰊢 " },
			{ "<leader>go", group = "GitHub (Octo)", icon = "󰊤 " }, -- plugins/git/octo.lua
			{ "<leader>G", group = "Review (CodeDiff)", icon = "󰦒 " }, -- plugins/git/codediff.lua

			{ "<leader>d", group = "Trouble (diagnostics UI)", icon = "󰓙 " },
			{ "<leader>x", group = "Diagnostics (LSP actions)", icon = "󰓙 " },
			{ "<leader>D", group = "Debug", icon = "󰃤 " },
			{ "<leader>T", group = "Test", icon = "󰙨 " },

			{ "<leader>o", group = "Options & Toggles", icon = "󰘮 " },
			{ "<leader>t", group = "Terminal", icon = "󰆍 " },
			{ "<leader>u", group = "UI / Workspace", icon = "󰏘 " },
			{ "<leader>w", group = "Workspaces (LSP)", icon = "󰕮 " },
			{ "<leader>i", group = "AI", icon = "󰧑 " },

			{ "<localleader>", group = "Buffer-local (CodeDiff review)", icon = "󰦒 " },

			{ "[", group = "Prev (jump backward)", icon = "󰒮 ", mode = { "n", "x", "o" } },
			{ "]", group = "Next (jump forward)", icon = "󰒭 ", mode = { "n", "x", "o" } },
			{ "g", group = "Goto / operators", icon = "󰆾 ", mode = { "n", "x", "o" } },
			{ "z", group = "Folds / view / spell", icon = "󰘖 ", mode = { "n", "x" } },
			{ "gr", group = "LSP (rename/refs/actions)", icon = "󰌵 ", mode = { "n", "x" } },
			{ "gA", group = "Case conversion (text-case)", icon = "󰬴 ", mode = { "n", "x" } }, -- moved off native `ga`; see plugins/editor/text-case.lua
		},
	},
}
