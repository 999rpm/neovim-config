-- Imports every category folder. lazy.nvim does not descend into sub-folders on its own, so a new folder must be added here.
return {
	{ import = "plugins.core" },
	{ import = "plugins.lsp" },
	{ import = "plugins.completion" },
	{ import = "plugins.treesitter" },
	{ import = "plugins.editor" },
	{ import = "plugins.ui" },
	{ import = "plugins.git" },
	{ import = "plugins.explorer" },
	{ import = "plugins.debug" },
	{ import = "plugins.test" },
	{ import = "plugins.lang-tools" },
	{ import = "plugins.ai" },
	{ import = "plugins.frontend" },
	{ import = "plugins.deps" },
}
