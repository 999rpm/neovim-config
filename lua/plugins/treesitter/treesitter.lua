-- nvim-treesitter/nvim-treesitter: parser install + highlighting, on the "main" branch API
-- (a full rewrite of the old, now-frozen "master" branch — confirmed against the project's own
-- README). `main` requires Neovim 0.12+ (stated in its own README's Requirements section) —
-- if `:checkhealth nvim-treesitter` or startup complains, check `:version` first; this is a
-- hard requirement of the plugin itself, not something this config can degrade around. `main`'s
-- setup() takes no `highlight`/`indent`/`ensure_installed`/`incremental_selection` table the
-- way `master` did:
--   • ensure_installed          -> require("nvim-treesitter").install({...}) (called below)
--   • highlight.enable          -> manual `vim.treesitter.start()` on FileType (see autocmd below)
--   • indent.enable             -> not set; no `indentexpr` is configured
--   • incremental_selection     -> removed outright in `main`, no replacement key. The closest
--     overlapping functionality already in this config: `as`/`is` (treesitter local-scope
--     select, plugins/editor/textobjects.lua) and mini.ai's own objects (plugins/editor/mini.lua).
--   • folding (foldmethod/foldexpr) — deliberately absent here: nvim-ufo (plugins/ui/ufo.lua)
--     needs foldmethod to stay "manual" (its own default) to manage folds itself.
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		event = { "BufReadPost", "BufNewFile" },
		cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
		build = ":TSUpdate",
		config = function()
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
				"json",
				"json5",
				"jsonc",
				"tsx",
				"bash",
				"nu",
				"python",
				"c",
				"cpp",
				"rust",
				"mdx",
				"haskell",
			}

			local ts = require("nvim-treesitter")
			ts.setup({})
			-- install() is a genuine no-op for anything already installed — confirmed by reading
			-- nvim-treesitter's own install_lang(): it returns immediately with zero I/O when
			-- `vim.list_contains(config.get_installed(), lang)`, so calling this unconditionally
			-- on every startup costs nothing once parsers exist, and fetches whatever's missing
			-- in the background otherwise. Async — does not block startup.
			ts.install(ensure_installed)

			vim.g.skip_ts_context_commentstring_module = true -- plugins/editor/comment.lua wires ts_context_commentstring manually
			vim.treesitter.language.register("markdown", "mdx")

			-- Start the highlighter per-buffer. Wrapped in pcall since `main` no longer treats
			-- "no parser for this filetype" as something to silently skip on its own — you're
			-- expected to guard it yourself now that `setup()` doesn't take a `highlight` table.
			vim.api.nvim_create_autocmd("FileType", {
				group = require("utils").augroup("treesitter-highlight"),
				callback = function(ev)
					local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
					if pcall(vim.treesitter.language.add, lang) then
						pcall(vim.treesitter.start, ev.buf, lang)
					end
				end,
			})
		end,
	},
}
