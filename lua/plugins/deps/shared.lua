-- Library and adapter plugins with no setup of their own. Consumers list them by name in `dependencies`.
return {
	{ "nvim-lua/plenary.nvim", lazy = true }, -- neo-tree, harpoon, todo-comments, neotest, octo, avante, mcphub, yazi
	{ "MunifTanjim/nui.nvim", lazy = true }, -- neo-tree, noice, hardtime, avante
	{ "nvim-neotest/nvim-nio", lazy = true }, -- dap-ui, neotest
	{ "kevinhwang91/promise-async", lazy = true }, -- ufo
	{ "b0o/schemastore.nvim", lazy = true }, -- lspconfig (jsonls, yamlls)
	{ "rafamadriz/friendly-snippets", lazy = true }, -- blink
	{ "antoinemadec/FixCursorHold.nvim", lazy = true }, -- neotest (its README still lists it)
	{ "nvim-neotest/neotest-jest", lazy = true }, -- neotest
	{
		"nvim-telescope/telescope-fzf-native.nvim", -- dropbar fuzzy search; the fzf library only, not telescope
		lazy = true,
		build = "make",
		cond = function()
			return vim.fn.executable("make") == 1
		end,
	},
}
