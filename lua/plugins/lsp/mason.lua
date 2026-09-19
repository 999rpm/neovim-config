-- Mason plus the installer bridges: servers for lspconfig, tools for conform/nvim-lint, adapters for nvim-dap.
-- :Mason opens the UI (<leader>om); :MasonUpdate refreshes the registry.
return {
	{
		"mason-org/mason.nvim",
		lazy = false, -- setup() puts $MASON/bin on $PATH, which servers, formatters and debug adapters all look through
		build = ":MasonUpdate",
		opts = {
			ui = {
				icons = {
					package_pending = "󰚰 ",
					package_installed = "󱧕 ",
					package_uninstalled = "󱧖 ",
				},
			},
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
		opts = {
			automatic_enable = false, -- lspconfig.lua calls vim.lsp.enable() per server instead
			ensure_installed = {
				"lua_ls",
				"taplo",
				"neocmake",
				"bashls",
				"jsonls",
				"yamlls",
				"ts_ls",
				"eslint",
				"html",
				"cssls",
				"tailwindcss",
				"emmet_language_server",
				"rust_analyzer", -- binary only: plugins/lsp/rustaceanvim.lua, not lspconfig.lua's `servers` table, starts this client; Mason's job here is unaffected either way
				"basedpyright",
				"ruff",
				"dockerls",
				"docker_compose_language_service",
				"markdown_oxide",
				"mdx_analyzer",
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"stylua",
				"prettier",
				"shfmt",
				"clang-format",
				"ormolu",
				"cmakelang",
				"ruff",
				"shellcheck",
				"hadolint",
				"actionlint",
				"markdownlint",
				"sqlfluff",
				"golangci-lint",
				"yamllint",
				"typos",
				"gofumpt", -- plugins/lang-tools/conform.lua's `go = {"gofumpt"}` formatter; wasn't actually guaranteed installed anywhere before this
				"tree-sitter-cli", -- plugins/treesitter/treesitter.lua's `main`-branch parser installs need this on $PATH; see that file's own note
			},
		},
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
		opts = {
			ensure_installed = {
				"debugpy",
				"codelldb",
				"js-debug-adapter",
				"haskell-debug-adapter",
			},
		},
	},
}
