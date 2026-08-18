-- MaximilianLloyd/tw-values.nvim: preview the actual resolved CSS values behind the Tailwind
-- classes on the current line (`<leader>cv`) — complements the class-literal colour highlighting
-- plugins/ui/colorizer.lua already does (`tailwind = { enable = true }` there), which shows
-- colour but not the underlying px/rem/etc values.
--
-- `<leader>cv`, not the plugin's own suggested `<leader>sv`: nests under this config's existing
-- Code group instead of adding a 17th entry to the already-large Search group — a better
-- organizational fit for a code-inspection tool, and `<leader>cv` was free either way.
return {
	"MaximilianLloyd/tw-values.nvim",
	ft = { "typescriptreact", "javascriptreact", "html", "css" },
	keys = {
		{ "<leader>cv", "<cmd>TWValues<cr>", desc = "Show Tailwind Values" },
	},
	opts = {
		border = "rounded", -- matches options.lua's global winborder default
	},
}
