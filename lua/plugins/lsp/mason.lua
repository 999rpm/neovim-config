-- Mason plus two installer bridges: mason-lspconfig for servers, mason-tool-installer for formatters, linters and debug adapters.
-- :Mason or <leader>pm opens the UI, :MasonUpdate refreshes the registry. In the UI: i install, u update, U update all,
-- X uninstall, c/C check versions, <CR> expand, <C-f> language filter, g? help.
-- Both bridges wait for VeryLazy: installing a tool is never on the critical path of opening a file.
return {
	{
		"mason-org/mason.nvim",
		lazy = false, -- setup() puts $MASON/bin on $PATH, which servers, formatters and debug adapters all look through
		build = ":MasonUpdate",
		keys = { { "<leader>pm", "<cmd>Mason<cr>", desc = "Mason" } },
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
		dependencies = { "mason-org/mason.nvim" }, -- no nvim-lspconfig: v2 carries its own package mappings, and listing it would undo lspconfig.lua's lazy event
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
				"debugpy", -- debug adapters for dap.lua and dap-python.lua; installing them here keeps nvim-dap out of startup
				"codelldb",
				"js-debug-adapter",
				"haskell-debug-adapter",
			}
			if require("utils").executable("go") then
				table.insert(tools, "gofumpt") -- Mason builds it with `go install`, which fails without a Go toolchain
			end
			return { ensure_installed = tools }
		end,
	},
}
