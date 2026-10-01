-- mfussenegger/nvim-lint: linters without a language server, run on write and on leaving insert mode. Missing binaries are skipped,
-- and so is any buffer with b:disable_lint set.
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
			go = { "golangcilint" }, -- nvim-lint's actual linter module name (one word, no separator); "golangci-lint" is not a valid key and silently resolves to nothing
			bash = { "shellcheck" },
			sh = { "shellcheck" },
			yaml = { "yamllint", "actionlint" },
			["yaml.github"] = { "actionlint" },
		}

		local always = { "typos" } -- every filetype; linters_by_ft has no wildcard key

		local function installed(linter) -- nvim-lint raises on a missing binary, so only linters on $PATH run
			local cmd = linter.cmd
			if type(cmd) == "function" then
				cmd = cmd()
			end
			return type(cmd) == "string" and utils.executable(cmd)
		end

		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
			group = utils.augroup("lint"),
			desc = "999rpm: run nvim-lint on write and on leaving insert mode",
			callback = function(ev)
				if vim.b[ev.buf].disable_lint then
					return -- notes/logseq.lua sets it in graph buffers, where markdownlint would flag every outline line
				end
				lint.try_lint(nil, { filter = installed }) -- nil: nvim-lint resolves the filetype itself, compound ones like yaml.github included
				lint.try_lint(always, { filter = installed })
			end,
		})
	end,
}
