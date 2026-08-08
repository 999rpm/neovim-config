-- mfussenegger/nvim-lint: async linting via each linter's own CLI (separate from conform.lua's
-- format-on-save — this only ever adds diagnostics, never rewrites a buffer).
return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local utils = require("utils")

		lint.linters_by_ft = {
			sql = { "sqlfluff" },
			markdown = { "markdownlint" },
			dockerfile = { "hadolint" },
			go = { "golangcilint" }, -- nvim-lint's actual linter module name (one word, no separator) — "golangci-lint" is not a valid key and silently resolves to nothing
			bash = { "shellcheck" },
			sh = { "shellcheck" },
			yaml = { "yamllint", "actionlint" },
			["yaml.github"] = { "actionlint" },
			["*"] = { "typos" },
		}

		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
			group = utils.augroup("lint"),
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
