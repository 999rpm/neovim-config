-- Explicitly imports each plugin category folder below by name (`{ import = "plugins.lsp" }`,
-- etc.) — lazy.nvim's own module discovery (lazy/core/util.lua's `lsmod`) only descends into a
-- subfolder on its own if that subfolder has its own init.lua, which none of the categories below
-- do, by design (confirmed by reading lazy.nvim's source directly: `lsmod` calls `fn()` for a
-- child directory only when `<dir>/init.lua` exists). Add a category folder without adding it
-- here and every spec inside it silently never loads.
--
-- Named `loader.lua`, not `init.lua`: this file is a plain top-level import list, so it could
-- have lived at `lua/plugins/init.lua` (config/lazy.lua would then say `{ import = "plugins" }`).
-- That name repeatedly collided with the root `init.lua` when this tree got flattened to a single
-- directory (both files share the basename "init.lua"; whichever one a given tool processes last
-- silently wins, dropping the other) — hit and re-fixed seven times before this rename. Since
-- lazy.nvim's import spec works identically for a plain file or a package (confirmed above:
-- `lsmod`'s file-match branch fires the same way either way), giving this file a distinct
-- basename removes the collision permanently instead of reconstructing it after every recurrence.
-- config/lazy.lua points at it via `{ import = "plugins.loader" }`.
return {
	{ import = "plugins.lsp" },
	{ import = "plugins.completion" },
	{ import = "plugins.treesitter" },
	{ import = "plugins.editor" },
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
