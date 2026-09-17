-- stevearc/conform.nvim: formatting on save with per-filetype formatters, LSP as fallback.
-- Keys: <leader>cf format now, <leader>of buffer toggle, <leader>oF global toggle, <leader>ci :ConformInfo.
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
			"<leader>of",
			function()
				vim.b.disable_autoformat = not vim.b.disable_autoformat
				vim.notify("Buffer Autoformat: " .. (vim.b.disable_autoformat and "OFF" or "ON"), vim.log.levels.INFO)
			end,
			desc = "Toggle format on save (buffer)",
		},
		{
			"<leader>oF",
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
			c = { "clang-format" }, -- hyphenated: the live formatter name in conform's registry; "clang_format" (underscored) is an explicit deprecated alias, the reverse of the usual convention
			cpp = { "clang-format" },
			haskell = { "ormolu" },
			sql = { "sqlfluff" },
			go = { "gofumpt" },
			cmake = { "cmake_format" },
			rust = { lsp_format = "fallback" }, -- an option key, not a formatter name; conform's own allowed_default_opts is { timeout_ms, lsp_format, quiet, stop_after_first }
			toml = { lsp_format = "fallback" },
		},
	},
}
