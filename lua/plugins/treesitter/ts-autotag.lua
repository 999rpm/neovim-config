-- windwp/nvim-ts-autotag: renames the matching HTML/JSX tag and closes a tag typed as "</".
return {
	"windwp/nvim-ts-autotag",
	ft = { "html", "xml", "javascriptreact", "typescriptreact", "vue", "svelte", "astro", "markdown", "mdx" }, -- tag languages only
	config = function()
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = false, -- no closing tag right after an opening one
				enable_rename = true, -- renaming one tag of a pair renames the other
				enable_close_on_slash = true, -- typing "</" completes the tag
			},
		})
	end,
}
