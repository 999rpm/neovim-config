-- Mason plus the installer bridges: servers for lspconfig, tools for conform/nvim-lint, adapters for nvim-dap.
-- :Mason opens the UI (<leader>om), :MasonUpdate refreshes the registry. In the UI: i install, u update, U update all,
-- X uninstall, c/C check versions, <CR> expand, <C-f> language filter, g? help.
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
				"rust_analyzer", -- binary only; rustaceanvim.lua starts the client
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
		opts = function()
			local tools = {
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
				"tree-sitter-cli", -- nvim-treesitter's main branch builds parsers with it
			}
			if vim.fn.executable("go") == 1 then
				table.insert(tools, "gofumpt") -- Mason builds it with `go install`, which fails without a Go toolchain
			end
			return { ensure_installed = tools }
		end,
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
