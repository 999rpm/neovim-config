-- folke/which-key.nvim: popup showing available keymaps as you type a prefix. `spec` below is
-- purely group labels/icons for `<leader>*` prefixes — the actual keymaps live in whichever
-- file owns that feature (see each group's matching plugin file). A bare, non-prefix command
-- like `<leader>a`/`<leader>A` (plugins/editor/textobjects.lua's parameter swap) doesn't need
-- a group entry here — only prefixes with further children do; its own `desc` from
-- vim.keymap.set is picked up automatically.
--
-- Verified against every `<leader>*` mapping actually defined anywhere in this config (grepped
-- the whole tree rather than eyeballing it): every prefix with two or more children has an
-- entry below, and no entry here is stale (pointing at a group that no longer has that shape).
-- One rename this pass: `<leader>n` covers more than registers — `<leader>ny`/`<leader>nY`
-- (mappings.lua) yank a relative/absolute *path* to the clipboard, not a register operation in
-- the vim-registers sense the way `np`/`nc`/`nd`/etc. are — so the label now says both.
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
			{ "<leader>i", group = "AI", icon = "󰧑 " },
			{ "<leader>m", group = "Multicursor", icon = "󰇀 " },
			{ "<leader>n", group = "No-yank / Paths / Registers", icon = "󰅍 " },
			{ "<leader>o", group = "Options", icon = "󰘮 " },
			{ "<leader>q", group = "Session", icon = "󰆓 " },
			{ "<leader>r", group = "Replace (grug-far)", icon = "󰛔 " },
			{ "<leader>s", group = "Search (Telescope)", icon = "󰍉 " },
			{ "<leader>t", group = "Toggle", icon = "󰔡 " },
			{ "<leader>T", group = "Test", icon = "󰙨 " },
			{ "<leader>u", group = "UI", icon = "󰏘 " },
			{ "<leader>w", group = "Workspaces", icon = "󰕮 " },
			{ "<leader>x", group = "Diagnostics (LSP actions)", icon = "󰓙 " },
		},
	},
}
