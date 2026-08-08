-- stevearc/conform.nvim: format-on-save, per-filetype, with an LSP-formatting fallback
-- (`lsp_format = "fallback"`) for anything without a dedicated formatter. The sole owner of
-- format-on-save in this config — see plugins/lsp/lspconfig.lua's 2026-08-06 note for why a
-- second, LSP-only mechanism used to also live there and was removed.
--
-- 2026-08-06: config-wide audit (full scope in init.lua). No changes needed to the formatter
-- table itself — `"trim_whitespace"` was already dropped from the `["_"]` catch-all in a prior
-- pass (autocmds.lua's own `trim_whitespace` group already strips trailing whitespace on every
-- save, before this plugin even runs) and `"clang-format"`/`"cmake_format"` were already
-- verified against conform's actual formatter registry. Confirmed lspconfig.lua no longer
-- fights this file over the same BufWritePre event; that's the only cross-file change here.
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "Format buffer",
		},
		{
			"<leader>tc",
			function()
				vim.b.disable_autoformat = not vim.b.disable_autoformat
				vim.notify("Buffer Autoformat: " .. (vim.b.disable_autoformat and "OFF" or "ON"), vim.log.levels.INFO)
			end,
			desc = "Toggle format on save (buffer)",
		},
		{
			"<leader>tC",
			function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify("Global Autoformat: " .. (vim.g.disable_autoformat and "OFF" or "ON"), vim.log.levels.INFO)
			end,
			desc = "Toggle format on save (global)",
		},
		{
			"<leader>ci",
			"<cmd>ConformInfo<CR>",
			desc = "Conform info",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return {
				timeout_ms = 2500,
				lsp_format = "fallback",
			}
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_organize_imports", "ruff_format" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			json = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
			mdx = { "prettier" },
			dockerfile = { "prettier" },
			bash = { "shfmt" },
			zsh = { "shfmt" },
			c = { "clang-format" }, -- hyphenated: the live formatter name in conform's registry; "clang_format" (underscored) is an explicit deprecated alias, the reverse of what you'd guess
			cpp = { "clang-format" },
			haskell = { "ormolu" },
			sql = { "sqlfluff" },
			go = { "gofumpt" },
			cmake = { "cmake_format" },
			rust = { lsp_format = "fallback" },
			toml = { lsp_format = "fallback" },

			["_"] = { "lsp_format" }, -- catch-all: anything not listed above formats via its LSP client, if it has one
		},
	},
}
