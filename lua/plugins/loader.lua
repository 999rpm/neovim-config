-- Imports every category folder; lazy.nvim does not descend into sub-folders on its own, so a new folder is added here.
-- Named loader.lua rather than init.lua, so it never shares a basename with the root init.lua.
return {
	{ import = "plugins.core" }, -- snacks, mini, which-key, themes
	{ import = "plugins.lsp" }, -- servers, mason, rustaceanvim
	{ import = "plugins.completion" }, -- blink, copilot, autopairs
	{ import = "plugins.treesitter" }, -- parsers, textobjects, context
	{ import = "plugins.editor" }, -- motions, text editing, sessions
	{ import = "plugins.ui" }, -- tabline, statusline, folds, messages
	{ import = "plugins.git" }, -- gitsigns, review, links, GitHub
	{ import = "plugins.explorer" }, -- neo-tree, oil, yazi
	{ import = "plugins.debug" }, -- nvim-dap and its panels
	{ import = "plugins.test" }, -- neotest
	{ import = "plugins.lang" }, -- formatters, linters and per-language helpers
	{ import = "plugins.notes" }, -- Logseq-style notes: journals, pages, tasks, markdown editing and rendering
	{ import = "plugins.notebook" }, -- Jupyter: kernels, .ipynb notebooks, language servers inside code cells
	{ import = "plugins.ai" }, -- avante, opencode, mcphub
	{ import = "plugins.deps" }, -- libraries other files reference by name
}
