-- Library and adapter plugins with no setup of their own, each loaded on the first require of one of its modules
-- (lazy.nvim loads a lazy plugin when its Lua module is required), so no consumer names them in `dependencies`. The
-- two `dependencies` lists left in this config, in blink.lua and dap.lua, name plugins nothing requires. The comment
-- on each entry names its consumers.
return {
	{ "nvim-lua/plenary.nvim", lazy = true }, -- neo-tree, harpoon, todo-comments, neotest, octo, avante, mcphub, yazi
	{ "MunifTanjim/nui.nvim", lazy = true }, -- neo-tree, noice, hardtime, avante, package-info
	{ "ColinKennedy/mega.cmdparse", lazy = true }, -- avante's commands
	{ "ColinKennedy/mega.logging", lazy = true }, -- mega.cmdparse
	{ "nvim-neotest/nvim-nio", lazy = true }, -- dap-ui, neotest
	{ "gregorias/coop.nvim", lazy = true }, -- coerce
	{ "kevinhwang91/promise-async", lazy = true }, -- ufo
	{ "b0o/schemastore.nvim", lazy = true }, -- lspconfig (jsonls, yamlls)
	{ "rafamadriz/friendly-snippets", lazy = true }, -- blink
	{ "nvim-neotest/neotest-jest", lazy = true }, -- neotest
	{ "nvim-neotest/neotest-python", lazy = true }, -- neotest
	{
		"nvim-telescope/telescope-fzf-native.nvim", -- dropbar menus; the fzf library only, not telescope
		lazy = true,
		build = "make",
		cond = function()
			return require("utils.core").executable("make")
		end,
	},
}
