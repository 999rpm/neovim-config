-- mfussenegger/nvim-lint: linters without a language server, run on open, on write and on leaving insert mode. Missing
-- binaries are skipped, and so is any buffer with b:disable_lint set (notes graph pages, notebooks).
-- actionlint runs only on GitHub workflow files: on any other YAML it reports a missing "on" and "jobs" section.
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
			go = { "golangcilint" }, -- nvim-lint's module name; "golangci-lint" resolves to nothing
			bash = { "shellcheck" },
			sh = { "shellcheck" },
			yaml = { "yamllint" },
		}

		local always = { "typos" } -- every filetype; linters_by_ft has no wildcard key

		local function installed(linter) -- nvim-lint raises on a missing binary, so only linters on $PATH run
			local cmd = linter.cmd
			if type(cmd) == "function" then
				cmd = cmd()
			end
			return type(cmd) == "string" and utils.executable(cmd)
		end

		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = utils.augroup("lint"),
			desc = "999rpm: run nvim-lint on open, on write and on leaving insert mode",
			callback = function(ev)
				if vim.b[ev.buf].disable_lint or ev.buf ~= vim.api.nvim_get_current_buf() then
					return -- try_lint works on the current buffer only
				end
				lint.try_lint(nil, { filter = installed }) -- nil: nvim-lint resolves the filetype itself, compound ones included
				lint.try_lint(always, { filter = installed })
				if vim.api.nvim_buf_get_name(ev.buf):find("/%.github/workflows/[^/]+%.ya?ml$") then
					lint.try_lint("actionlint", { filter = installed })
				end
			end,
		})
	end,
}
