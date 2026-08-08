-- Manifest for the category folders below. Needed because lazy.nvim's own module discovery
-- (lazy/core/util.lua's `lsmod`) only scans ONE level deep from whatever module you `import`:
-- it collects direct `.lua` files in that directory, and only descends into a SUBdirectory if
-- that subdirectory has its own `init.lua`. It does not recursively walk arbitrarily-nested
-- folders on its own — confirmed by reading its actual source after this two-level layout
-- (`plugins/<category>/<plugin>.lua`, no `init.lua` in each category folder) produced
-- "No specs found for module 'plugins'" on a real install: `lua/plugins/` itself had no direct
-- `.lua` files and none of its subfolders had an `init.lua`, so lsmod found nothing at all.
--
-- This file *is* `plugins/init.lua`, so lazy.lua's `{ import = "plugins" }` loads it directly;
-- each line below then imports one category folder, and since every plugin file sits directly
-- inside its category folder (e.g. `plugins/lsp/lspconfig.lua`), lsmod finds those correctly
-- with no further nesting to worry about. Add a line here when adding a new category folder —
-- individual plugin files inside an already-listed category still need nothing extra.
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
}
