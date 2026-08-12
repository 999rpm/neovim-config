-- Explicitly imports every category folder below by name. This file's existence is load-bearing,
-- not decorative — confirmed by reading lazy.nvim's own source directly rather than assuming:
-- lazy/core/util.lua's `lsmod` (the function behind `{ import = "plugins" }` in config/lazy.lua)
-- scans one directory level at a time via `vim.uv.fs_scandir`, and only descends into a
-- subfolder if THAT subfolder has its own init.lua. None of the category folders below have one
-- by design (see init.lua's own file-layout comment for why), so without this file, a bare
-- `{ import = "plugins" }` finds nothing inside any of them — every plugin spec in this whole
-- tree would silently never load, with no error to point at why.
--
-- This file has gone missing from delivered project knowledge twice before (see
-- AUDIT_SUMMARY.md) — both times because it and the root init.lua are literally both named
-- "init.lua", and whatever sync step prepares files for a chat session only kept one. If this
-- file is ever missing again, this is why, and this is what it should contain.
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
