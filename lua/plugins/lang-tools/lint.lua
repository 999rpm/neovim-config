-- mfussenegger/nvim-lint: linters that have no language server, run on write and on leaving insert mode.
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

		local always = { "typos" } -- filetype-independent linters; see header note on why these can't live above

		local function runnable(names)
			local found = {}
			for _, name in ipairs(names or {}) do
				local linter = lint.linters[name]
				if type(linter) == "function" then
					linter = linter()
				end
				local cmd = type(linter) == "table" and linter.cmd or nil
				if type(cmd) == "function" then
					cmd = cmd()
				end
				if cmd and utils.executable(cmd) then
					table.insert(found, name)
				end
			end
			return found
		end

		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
			group = utils.augroup("lint"),
			desc = "999rpm: run nvim-lint on write and on leaving insert mode",
			callback = function()
				local names = runnable(lint._resolve_linter_by_ft(vim.bo.filetype)) -- nvim-lint's own resolver, so compound filetypes ("yaml.github") keep splitting correctly
				vim.list_extend(names, runnable(always))
				if #names > 0 then
					lint.try_lint(names)
				end
			end,
		})
	end,
}
