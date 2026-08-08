-- windwp/nvim-ts-autotag: auto-close/-rename HTML/JSX/TSX tags via treesitter.
-- Kept values: close tags only when you type "</" yourself, not automatically the instant an
-- opening tag finishes. Flip `enable_close` to true for immediate auto-close instead.
return {
	"windwp/nvim-ts-autotag",
	event = "BufReadPre",
	config = function()
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = false, -- Don't auto-insert a closing tag right after the opening tag
				enable_rename = true, -- Renaming one side of a tag pair renames the other automatically
				enable_close_on_slash = true, -- Do auto-complete the tag when you type the "</" yourself
			},
		})
	end,
}
