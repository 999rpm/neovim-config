-- 999rpm-d2: d2 diagrams drawn by the d2 binary (utils/d2.lua), one static binary that writes PNG and text with no
-- browser engine behind it. treesitter.lua builds the d2 parser, so .d2 files and ```d2 blocks in markdown are
-- highlighted; conform.lua runs `d2 fmt` on write.
-- In a d2 file the whole file is the diagram; in markdown it is the ```d2 block holding the cursor. Owns <leader>ud and
-- <leader>uD in d2 and markdown buffers; q closes the text split.
return {
	"999rpm-d2", -- a name with no slash: lazy.nvim looks for no repository
	virtual = true, -- and adds no rtp entry; the code is utils/d2.lua
	keys = {
		{
			"<leader>ud",
			function()
				require("utils.d2").render()
			end,
			ft = { "d2", "markdown" },
			desc = "d2 diagram as image",
		}, -- n: the diagram as a PNG, in a split under kitty or the system's viewer under Neovide (d for diagram)
		{
			"<leader>uD",
			function()
				require("utils.d2").text()
			end,
			ft = { "d2", "markdown" },
			desc = "d2 diagram as text",
		}, -- n: the diagram in box-drawing characters in a split, for any terminal
	},
}
