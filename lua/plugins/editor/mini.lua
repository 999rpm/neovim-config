-- echasnovski/mini.nvim: only mini.ai (textobjects) lives here now.
--
-- 2026-08-06: config-wide audit (full scope in init.lua). Extracted mini.bufremove and
-- mini.hipatterns out to standalone, single-purpose plugins — plugins/ui/bufdelete.lua and
-- plugins/ui/colorizer.lua respectively — rather than pulling in the whole mini.nvim bundle
-- for two small features. mini.ai stays: unlike those two, it's a genuinely feature-rich
-- textobject engine actively used for brackets/quotes/tag/argument objects throughout normal
-- editing, not a single narrow feature with an equally-capable standalone alternative — there
-- isn't a clearly-better dedicated replacement for what it does here, so swapping it out
-- wouldn't reduce dependency weight for a real gain the way the other two did.
--
-- mini.ai ships a builtin `f` textobject id meaning "function call" (e.g. `daf` deletes
-- `foo(...)` including the name). plugins/editor/textobjects.lua ALSO maps `af`/`if` directly,
-- via nvim-treesitter-textobjects, meaning "function DEFINITION" (treesitter's
-- `@function.outer`). Both are real, both fire on the literal keys `af`/`if`, and because Nvim
-- treats a mapped `a` (mini.ai's own prefix key) as ambiguous with the longer, separately-
-- mapped `af`, which one you actually get depends on typing speed relative to 'timeoutlen'.
-- Fixed by telling mini.ai to not register `f` at all, leaving nvim-treesitter-textobjects as
-- the single, unambiguous owner of `af`/`if`. Everything else mini.ai provides by default
-- (brackets, quotes, tag, argument, etc.) is untouched and doesn't collide with anything else.
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
