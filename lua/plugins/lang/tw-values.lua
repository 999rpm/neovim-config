-- MaximilianLloyd/tw-values.nvim: shows the CSS behind the Tailwind classes under the cursor. Owns <leader>cv in jsx,
-- tsx, html and css buffers.
return {
	"MaximilianLloyd/tw-values.nvim",
	cmd = "TWValues",
	keys = {
		{
			"<leader>cv",
			"<cmd>TWValues<cr>",
			ft = { "typescriptreact", "javascriptreact", "html", "css" },
			desc = "Show Tailwind values",
		}, -- n: a float with the CSS each class under the cursor stands for (v for values)
	},
	opts = {},
}
