-- ravsii/tree-sitter-d2: d2 parser and queries, so .d2 files and ```d2 blocks in markdown are highlighted. d2 itself is one
-- static binary that draws PNG and text natively, with no browser engine behind it.
-- Keys in d2 and markdown buffers: <leader>ud render the diagram under the cursor to PNG in a split (kitty draws it through
-- snacks.image), <leader>uD render it as text in a split, which works in any terminal; q closes the text split.
-- In a d2 file the whole file is the diagram; in markdown it is the ```d2 block holding the cursor. conform.lua runs `d2 fmt`.
return {
	"ravsii/tree-sitter-d2",
	version = "*", -- tagged releases, as upstream recommends
	ft = { "d2", "markdown" },
	dependencies = { "nvim-treesitter/nvim-treesitter" }, -- the plugin registers its parser with nvim-treesitter on load
	build = "make nvim-install", -- copies the queries into queries/d2/, where Neovim looks for them
	keys = {
		{
			"<leader>ud",
			function()
				require("utils").d2_render()
			end,
			ft = { "d2", "markdown" },
			desc = "d2 diagram as image",
		},
		{
			"<leader>uD",
			function()
				require("utils").d2_text()
			end,
			ft = { "d2", "markdown" },
			desc = "d2 diagram as text",
		},
	},
	config = function()
		local ts = require("nvim-treesitter")
		if not vim.list_contains(ts.get_installed(), "d2") and require("utils").executable("tree-sitter") then
			ts.install({ "d2" }) -- built from this plugin's own checkout, like the parsers in treesitter.lua
		end
	end,
}
