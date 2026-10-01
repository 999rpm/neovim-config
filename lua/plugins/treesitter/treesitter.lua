-- nvim-treesitter/nvim-treesitter (main branch): parser installs and highlighting through Neovim's own treesitter. Parsers build with the
-- tree-sitter CLI (mason.lua installs it); :TSUpdate refreshes them, :TSInstall {lang} adds one.
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		event = { "BufReadPost", "BufNewFile" },
		cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
		build = ":TSUpdate",
		config = function()
			local utils = require("utils")
			local ensure_installed = {
				"lua",
				"luadoc",
				"luap", -- Lua patterns inside strings
				"vim",
				"vimdoc",
				"query",
				"regex", -- noice.lua's cmdline highlighting and snacks.picker
				"printf", -- format strings inside Lua, C and Python
				"markdown",
				"markdown_inline",
				"latex", -- snacks.image's inline math
				"yaml",
				"toml",
				"json", -- also serves jsonc: main ships no jsonc parser
				"json5",
				"xml",
				"ini",
				"html",
				"css",
				"jsdoc",
				"javascript",
				"typescript",
				"tsx",
				"python",
				"c",
				"cpp",
				"rust",
				"haskell",
				"sql",
				"bash",
				"zsh",
				"nu",
				"kitty", -- kitty.conf
				"dockerfile",
				"make",
				"cmake",
				"just",
				"diff",
				"git_rebase",
				"git_config",
				"gitignore",
			}

			local ts = require("nvim-treesitter")
			ts.setup({})
			if utils.executable("tree-sitter") then
				ts.install(ensure_installed)
			else
				utils.warn_if_missing_exec(
					"tree-sitter",
					"nvim-treesitter",
					"Parsers install once Mason has tree-sitter-cli, or an OS package provides it; then run :TSUpdate."
				)
			end

			vim.treesitter.language.register("markdown", { "mdx", "quarto" }) -- neither has a parser of its own

			local function start(buf, ft)
				local lang = vim.treesitter.language.get_lang(ft) or ft
				if pcall(vim.treesitter.language.add, lang) then
					pcall(vim.treesitter.start, buf, lang)
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = utils.augroup("treesitter-highlight"),
				desc = "999rpm: start the treesitter highlighter for each new filetype",
				callback = function(ev)
					start(ev.buf, ev.match)
				end,
			})

			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				local ft = vim.bo[buf].filetype
				if vim.api.nvim_buf_is_loaded(buf) and ft ~= "" then
					start(buf, ft)
				end
			end
		end,
	},
}
