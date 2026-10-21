-- Imports every category folder; lazy.nvim does not descend into sub-folders on its own, so a new folder is added here.
-- A folder with no file left is skipped (lazy.nvim honours `enabled` on an import), since an empty import fails the
-- whole start. Named loader.lua rather than init.lua, so it never shares a basename with the root init.lua.
local root = vim.fn.stdpath("config") .. "/lua/plugins/"

---@param name string folder under lua/plugins/
local function group(name)
	return { import = "plugins." .. name, enabled = #vim.fn.glob(root .. name .. "/*.lua", false, true) > 0 }
end

return {
	group("core"), -- snacks, mini, which-key, colour schemes
	group("lsp"), -- servers, mason, rustaceanvim
	group("completion"), -- blink, copilot, autopairs
	group("treesitter"), -- parsers, textobjects, context
	group("editor"), -- motions, text editing, sessions
	group("ui"), -- tabline, statusline, folds, messages
	group("git"), -- gitsigns, review, links, GitHub
	group("explorer"), -- neo-tree, oil, yazi
	group("debug"), -- nvim-dap and its panels
	group("test"), -- neotest
	group("projects"), -- new-project wizard, project picker, overseer tasks
	group("lang"), -- formatters, linters and per-language helpers
	group("notes"), -- Logseq-style notes: journals, pages, tasks, markdown editing and rendering
	group("notebook"), -- Jupyter: kernels, .ipynb notebooks, language servers inside code cells
	group("ai"), -- avante, opencode, mcphub
	group("deps"), -- libraries other files reference by name
}
