-- Mason: installs LSP servers + CLI tools (formatters/linters/debug adapters) and keeps them
-- updated. Companion piece to plugins/lsp/lspconfig.lua <jdhao/nvim-config credit + full
-- feature list live there>. Not adapted from jdhao — his repo manages Mason-installed binaries
-- by hand rather than through mason-lspconfig.nvim/mason-tool-installer.nvim, so there's no
-- equivalent file of his to diff this against.
--
-- How the four blocks below relate to lspconfig.lua (and, for the fourth, plugins/debug/dap.lua):
--   • automatic_enable = false — mason-lspconfig.nvim would otherwise call vim.lsp.enable()
--     itself for every server it installs. Off because lspconfig.lua already calls
--     vim.lsp.config()/vim.lsp.enable() explicitly per server, next to that server's settings.
--   • ensure_installed (mason-lspconfig block) MUST stay in sync with lspconfig.lua's `servers`
--     table — that table assumes every server in it is already on $PATH because Mason
--     installed it, unlike `external_servers`, which executable-checks itself. Add or remove a
--     server in both lists together, or move it to `external_servers` instead if you'd rather
--     install it outside Mason.
--   • mason-tool-installer.nvim (third block) installs formatters/linters for standalone CLI
--     use; unrelated to LSP servers and not gated by lspconfig.lua at all.
--   • mason-nvim-dap.nvim (fourth block) is the same idea as the first bullet but for debug
--     adapters — plugins/debug/dap.lua defines its own dap.adapters/dap.configurations by hand,
--     so this block exists purely to keep those adapter binaries installed, not to
--     auto-register anything.
--
-- 2026-08-06: config-wide audit (full scope in init.lua). Re-verified `automatic_enable`
-- against mason-lspconfig.nvim's current README — still a real, current option, still `false`
-- disables it outright, nothing to change. ensure_installed vs. lspconfig.lua's `servers`
-- table: still an exact match (18 servers each, diffed programmatically, not by eye). No other
-- changes needed here this pass.
return {
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
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
				"rust_analyzer",
				"basedpyright",
				"ruff",
				"dockerls",
				"docker_compose_language_service",
				"markdown_oxide",
				"mdx_analyzer",
				-- If you enable `ltex` or `codebook` in lspconfig.lua's external_servers,
				-- they can move here instead once you'd rather have Mason install/update
				-- them for you (both are Mason packages) than manage them by hand.
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
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
				"selene",
				"luacheck",
				"typos",
			},
		},
	},
	{
		-- Same job mason-lspconfig.nvim and mason-tool-installer.nvim above do, but for debug
		-- adapter binaries: plugins/debug/dap.lua defines dap.adapters/dap.configurations by
		-- hand (it never uses this plugin's optional `handlers` auto-registration feature), so
		-- this block is only responsible for keeping the adapters themselves installed.
		-- Requires mason.nvim to be set up first, hence the explicit `dependencies` below —
		-- lazy.nvim doesn't guarantee load order from table position alone.
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
