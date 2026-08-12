-- Explicitly imports every category folder below by name. lazy.nvim's own module discovery
-- (lazy/core/util.lua's `lsmod`) scans one directory level at a time and only descends into a
-- subfolder if that subfolder has its own init.lua — none of the category folders below have
-- one, by design (confirmed by reading lazy.nvim's source directly, not assumed). A bare
-- `{ import = "plugins" }` in config/lazy.lua therefore finds this file and nothing else; this
-- file is what actually reaches every spec in every category folder. Add a new category folder
-- without adding a line here and every spec inside it silently never loads — see init.lua's own
-- file-layout note for the full folder list this is expected to stay in sync with.
return {
	{ import = "plugins.lsp" },
	{ import = "plugins.completion" },
	{ import = "plugins.editor" },
	{ import = "plugins.treesitter" },
	{ import = "plugins.ui" },
	{ import = "plugins.git" },
	{ import = "plugins.explorer" },
	{ import = "plugins.search" },
	{ import = "plugins.debug" },
	{ import = "plugins.test" },
	{ import = "plugins.lang-tools" },
	{ import = "plugins.terminal" },
	{ import = "plugins.deps" },
}
