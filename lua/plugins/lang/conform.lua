-- stevearc/conform.nvim: formatting on save with per-filetype formatters, LSP as fallback. In a notebook (.ipynb) the
-- injected formatter runs each code cell through its language's formatters (ruff for Python) and leaves the markdown
-- alone; utils/notebook.lua fires the BufWritePre a notebook write would otherwise skip. Owns <leader>cf, <leader>of,
-- <leader>oF and <leader>pc; conform maps no keys itself.
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
			mode = { "n", "x" }, -- not "", which would also bind the key in operator-pending mode
			desc = "Format buffer",
		}, -- n/x: format now, the whole buffer or only the selected lines
		{
			"<leader>of",
			function()
				vim.b.disable_autoformat = not vim.b.disable_autoformat
				vim.notify("Autoformat (buffer): " .. (vim.b.disable_autoformat and "off" or "on"), vim.log.levels.INFO)
			end,
			desc = "Toggle format on save (buffer)",
		}, -- n: this buffer only; the notification says which state it is in now
		{
			"<leader>oF",
			function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify("Autoformat (global): " .. (vim.g.disable_autoformat and "off" or "on"), vim.log.levels.INFO)
			end,
			desc = "Toggle format on save (global)",
		}, -- n: every buffer, uppercase twin of of
		{
			"<leader>pc",
			"<cmd>ConformInfo<CR>",
			desc = "Conform info",
		}, -- n: which formatters this buffer gets and whether they are installed
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
			markdown = function(bufnr) -- a notebook formats its code cells only: prettier would reflow the jupytext markdown
				return vim.b[bufnr]._999rpm_notebook and { "injected" } or { "prettier" }
			end,
			mdx = { "prettier" },
			bash = { "shfmt" },
			sh = { "shfmt" },
			zsh = { "shfmt" },
			c = { "clang-format" }, -- conform's own name; clang_format is a deprecated alias
			cpp = { "clang-format" },
			haskell = { "ormolu" },
			sql = { "sqlfluff" },
			go = { "gofumpt" },
			cmake = { "cmake_format" },
			d2 = { "d2" }, -- d2 fmt
			rust = { lsp_format = "fallback" }, -- no formatter listed: rust-analyzer runs rustfmt
			toml = { lsp_format = "fallback" }, -- taplo
		},
		formatters = {
			injected = { -- each code block through its language's formatters above
				options = {
					ignore_errors = true, -- a cell ruff cannot parse (IPython magics such as %timeit) stays as written
					lang_to_formatters = { yaml = {} }, -- the jupytext header at the top stays as jupytext writes it
				},
			},
		},
	},
}
