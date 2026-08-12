-- config/lazy.lua's `{ import = "plugins" }` resolves to this file. lazy.nvim's own module
-- discovery (`lazy/core/util.lua`'s `lsmod`) scans one directory level at a time and only
-- descends into a subfolder that has its own init.lua — it does not walk arbitrary nesting on
-- its own (confirmed by reading that source directly, not assumed). None of the category
-- folders below has its own init.lua, so this file exists purely to import each one by name;
-- each import target IS a flat folder of .lua files, which lsmod finds correctly with no
-- further nesting to resolve. See AUDIT_SUMMARY.md for how this was diagnosed.
--
-- Add a category here the moment you add its folder under lua/plugins/ — otherwise every spec
-- inside it is silently never loaded, with no error of any kind.
return {
	{ import = "plugins.completion" },
	{ import = "plugins.debug" },
	{ import = "plugins.editor" },
	{ import = "plugins.explorer" },
	{ import = "plugins.git" },
	{ import = "plugins.lang-tools" },
	{ import = "plugins.lsp" },
	{ import = "plugins.search" },
	{ import = "plugins.terminal" },
	{ import = "plugins.test" },
	{ import = "plugins.treesitter" },
	{ import = "plugins.ui" },
}
