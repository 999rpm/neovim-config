-- kevinhwang91/nvim-bqf: preview pane, fuzzy filter, and a scrollbar for the native quickfix
-- window — the raw `:copen` experience underneath both plugins/lsp/lspconfig.lua's `<leader>xw`/
-- `<leader>xb` (diagnostics to quickfix) and plugins/ui/trouble.lua's `<leader>dq` (Trouble's own
-- alternate view of the same list). The two don't compete: this only ever touches a real,
-- native `filetype=qf` window, which Trouble's own view is not. A low-priority candidate from
-- the smaller aesthetic group (AUDIT_SUMMARY.md), added now that a plugin addition is an
-- explicit ask. `border = "rounded"` below is already this plugin's own current default
-- (verified against source) — matches options.lua's global `winborder`, restated for the same
-- reason dap-ui.lua/neo-tree.lua restate their own current upstream defaults.
return {
	"kevinhwang91/nvim-bqf",
	ft = "qf",
	opts = {
		preview = {
			border = "rounded",
		},
	},
}
