-- Explicitly imports every plugins/<category>/ folder. Required because lazy.nvim's own module
-- discovery (lazy/core/util.lua's lsmod) only scans one directory level at a time and won't
-- descend into a category folder on its own unless that folder has its own init.lua (none of
-- them do, by design — see init.lua's own file-layout note for the full reasoning). Add a new
-- category folder without adding a line here and every spec inside it silently never loads.
--
-- NOTE: this file has gone missing from project-knowledge uploads to this chat multiple times
-- (see AUDIT_SUMMARY.md) because the upload step flattens this file's basename against the root
-- init.lua and keeps only one of the two. If you're reading this because it was just
-- reconstructed again: the fix is this file itself, not a deeper bug in the config — save it
-- back into lua/plugins/init.lua in the real tree and nothing else needs to change.
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
	{ import = "plugins.ai" },
	{ import = "plugins.frontend" },
	{ import = "plugins.deps" },
}
