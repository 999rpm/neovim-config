-- MaximilianLloyd/tw-values.nvim: shows the CSS behind the Tailwind classes under the cursor (<leader>cv).
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
