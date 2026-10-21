-- mason-org/mason.nvim: installs language servers, formatters, linters and debug adapters into stdpath("data")/mason,
-- with two bridges that keep the lists below installed: mason-org/mason-lspconfig.nvim for servers and
-- WhoIsSethDaniel/mason-tool-installer.nvim for the rest. Both bridges wait for VeryLazy, after mason itself loaded at
-- startup, so installing a tool is never on the path of opening a file. :MasonUpdate refreshes the registry.
-- Owns <leader>pm.
return {
	{
		"mason-org/mason.nvim",
		lazy = false, -- setup() puts $MASON/bin on $PATH, which servers, formatters and debug adapters all look through
		build = ":MasonUpdate",
		-- mason's own keys in its window: i install, u update, U update all, X uninstall, c/C check versions, <CR>
		-- expand, <C-f> language filter, g? help.
		keys = { { "<leader>pm", "<cmd>Mason<cr>", desc = "Mason" } }, -- n: the installer window (p for plugins and tools)
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
		event = "VeryLazy",
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
		event = "VeryLazy",
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
				"debugpy", -- debug adapters for dap.lua and dap-python.lua; installing them here keeps nvim-dap out of startup
				"codelldb",
				"js-debug-adapter",
			}
			local core = require("utils.core")
			if core.executable("stack") then
				table.insert(tools, "haskell-debug-adapter") -- dap.lua launches it through `stack ghci`; without stack it has nothing to run
			end
			if core.executable("go") then
				table.insert(tools, "gofumpt") -- Mason builds it with `go install`, which fails without a Go toolchain
			end
			return { ensure_installed = tools }
		end,
	},
}
