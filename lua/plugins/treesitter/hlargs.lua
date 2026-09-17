-- m-demare/hlargs.nvim: gives function parameters their own colour.
return {
	"m-demare/hlargs.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {},
}
