-- folke/which-key.nvim: popup showing available keymaps as you type a prefix. `spec` below is
-- purely group labels/icons for `<leader>*` prefixes — the actual keymaps live in whichever
-- file owns that feature (see each group's matching plugin file).
--
-- 2026-08-06: config-wide audit (full scope in init.lua). plugins/editor/textobjects.lua's
-- parameter-swap keys moved off `]p`/`[p` (which collided with Neovim's own built-in
-- indent-adjusted paste) onto `<leader>a`/`<leader>A` — see that file's note. No group entry
-- needed for it here: `<leader>a` and `<leader>A` are two standalone, case-differentiated
-- commands, not a prefix with further children the way `<leader>b`/`<leader>c`/etc. are below
-- (which-key's own `group` entries are specifically for that latter case — a bare command
-- doesn't need one, its own `desc` from vim.keymap.set is picked up automatically). Nothing
-- else needed changing — the rest of this file's grouping was already audited (Trouble vs
-- Debug, Harpoon pointed at real keys, Diffview/Registers/Test groups added, Find/Search
-- relabeled to name which tool each belongs to) and still matches where every keymap actually
-- lives.
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
