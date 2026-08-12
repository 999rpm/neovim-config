-- folke/which-key.nvim: popup showing available keymaps as you type a prefix. `spec` below is
-- purely group labels/icons for `<leader>*` prefixes — the actual keymaps live in whichever
-- file owns that feature (see each group's matching plugin file). A bare, non-prefix command
-- like `<leader>a`/`<leader>A` (plugins/editor/textobjects.lua's parameter swap) doesn't need
-- a group entry here — only prefixes with further children do; its own `desc` from
-- vim.keymap.set is picked up automatically.
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
			{ "<leader>b", group = "Buffers", icon = "󱟱 " },
			{ "<leader>c", group = "Code", icon = "󰅨 " },
			{ "<leader>d", group = "Trouble (diagnostics UI)", icon = "󰓙 " },
			{ "<leader>D", group = "Debug", icon = "󰃤 " },
			{ "<leader>e", group = "Explore", icon = "󰉋 " },
			{ "<leader>f", group = "Find (fzf)", icon = "󰍉 " },
			{ "<leader>g", group = "Git", icon = "󰊢 " },
			{ "<leader>G", group = "Diffview", icon = "󰊢 " },
			{ "<leader>h", group = "Harpoon", icon = "󱡀 " },
			{ "<leader>n", group = "Registers", icon = "󰅍 " },
			{ "<leader>o", group = "Options", icon = "󰘮 " },
			{ "<leader>s", group = "Search (Telescope)", icon = "󰍉 " },
			{ "<leader>t", group = "Toggle", icon = "󰔡 " },
			{ "<leader>T", group = "Test", icon = "󰙨 " },
			{ "<leader>u", group = "UI", icon = "󰏘 " },
			{ "<leader>w", group = "Workspaces", icon = "󰕮 " },
			{ "<leader>x", group = "Diagnostics (LSP actions)", icon = "󰓙 " },
		},
	},
}
