-- folke/flash.nvim: jump to any visible position by typing the label shown there. f/F/t/T and their ;/, repeats stay
-- built-in. Owns <leader>j and <leader>J, r and R after an operator, and <C-s> while a / or ? search is typed.
return {
	"folke/flash.nvim",
	opts = {
		modes = {
			char = { enabled = false }, -- f/F/t/T stay the built-in character search
		},
	},
	-- flash's own keys while it shows labels: (n/x/o) type a label to jump there, <CR> the first match, <Esc> cancel.
	keys = {
		{
			"<leader>j",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Jump (flash)",
		}, -- n/x/o: type a few letters of the target, then the label shown on it (j for jump)
		{
			"<leader>J",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Select node (flash)",
		}, -- n/x/o: labels on the treesitter nodes around the cursor; a label selects that node
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote flash",
		}, -- o: after an operator (yr, dr), jump to text elsewhere, act on it, and come back
		{
			"R",
			mode = "o",
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter search",
		}, -- o: after an operator, search for text, then pick the treesitter node around a match
		{
			"<C-s>",
			mode = "c",
			function()
				require("flash").toggle()
			end,
			desc = "Toggle flash search",
		}, -- c: while a / or ? search is typed, labels on the matches on or off
	},
}
