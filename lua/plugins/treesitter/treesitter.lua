-- nvim-treesitter (main branch): parser installs and highlighting.
-- Parsers install through the tree-sitter CLI (mason.lua installs it). :TSUpdate refreshes them.
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
				"vim",
				"vimdoc",
				"query",
				"yaml",
				"toml",
				"markdown",
				"markdown_inline",
				"html",
				"css",
				"jsdoc",
				"javascript",
				"typescript",
				"json", -- also serves the jsonc filetype: core maps ft jsonc -> lang json, and `main` ships no separate jsonc parser
				"json5",
				"tsx",
				"bash",
				"nu",
				"python",
				"c",
				"cpp",
				"rust",
				"haskell",
				"regex", -- noice.lua's cmdline highlighting and snacks.picker
				"latex", -- snacks.image's inline math and render-markdown's LaTeX blocks
			}

			local ts = require("nvim-treesitter")
			ts.setup({})
			if utils.executable("tree-sitter") then
				ts.install(ensure_installed)
			else
				utils.warn_if_missing_exec(
					"tree-sitter",
					"nvim-treesitter",
					"Parsers cannot auto-install until Mason finishes installing tree-sitter-cli, or "
						.. "until it is installed directly (an OS package, or `cargo install "
						.. "tree-sitter-cli`, which upstream's README prefers over npm). Run "
						.. ":TSUpdate once it is on $PATH."
				)
			end

			vim.treesitter.language.register("markdown", "mdx") -- mdx has no parser of its own

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
