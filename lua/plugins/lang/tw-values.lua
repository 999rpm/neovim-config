-- MaximilianLloyd/tw-values.nvim: shows the CSS behind the Tailwind classes under the cursor (<leader>cv in jsx, tsx,
-- html and css buffers; elsewhere the key does nothing).
return {
	"MaximilianLloyd/tw-values.nvim",
	cmd = "TWValues",
	keys = {
		{
			"<leader>cv",
			"<cmd>TWValues<cr>",
			ft = { "typescriptreact", "javascriptreact", "html", "css" },
			desc = "Show Tailwind values",
		},
	},
	opts = {
		border = "rounded",
	},
}
