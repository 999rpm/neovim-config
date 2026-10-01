-- folke/ts-comments.nvim: gc picks the comment style of the treesitter node under the cursor, so JSX inside a tsx file
-- gets {/* */} rather than //. The built-in gc, gcc and mappings.lua's gco/gcO/gcA keep their keys.
return {
	"folke/ts-comments.nvim",
	event = "VeryLazy",
	opts = {},
}
