-- echasnovski/mini.nvim: only mini.ai (textobjects) lives here now — mini.bufremove and
-- mini.hipatterns were pulled out to standalone, single-purpose plugins (plugins/ui/
-- bufdelete.lua, plugins/ui/colorizer.lua) rather than keep the whole mini.nvim bundle
-- installed for two small features; mini.ai is a genuinely feature-rich textobject engine
-- with no equally-capable standalone alternative, so it stays.
--
-- mini.ai's builtin `f` textobject ("function call", e.g. `daf` deletes `foo(...)` including
-- the name) is disabled below: plugins/editor/textobjects.lua also maps `af`/`if` via
-- nvim-treesitter-textobjects, meaning "function DEFINITION" instead — both would otherwise
-- fire on the same keys, ambiguously, depending on typing speed relative to 'timeoutlen'.
-- Everything else mini.ai provides by default (brackets, quotes, tag, argument, etc.) is
-- untouched and doesn't collide with anything else.
return {
	"echasnovski/mini.nvim",
	version = "*",
	event = "VeryLazy",
	config = function()
		-- Examples: 'da(' deletes a function call, 'yi?' yanks inside a conditional
		require("mini.ai").setup({
			n_lines = 500,
			custom_textobjects = {
				f = false, -- disabled: collides with nvim-treesitter-textobjects' af/if (see note above)
			},
		})
	end,
}
