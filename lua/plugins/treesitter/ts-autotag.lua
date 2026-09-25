-- windwp/nvim-ts-autotag: renames the matching HTML/JSX tag and closes a tag typed as "</".
return {
	"windwp/nvim-ts-autotag",
	ft = { "html", "xml", "javascriptreact", "typescriptreact", "vue", "svelte", "astro", "markdown", "mdx" }, -- tag languages only
	config = function()
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = false, -- Don't auto-insert a closing tag right after the opening tag
				enable_rename = true, -- Renaming one side of a tag pair renames the other automatically
				enable_close_on_slash = true, -- Complete the tag on a manually typed "</"
			},
		})
	end,
}
