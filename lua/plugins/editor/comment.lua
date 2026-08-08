-- numToStr/Comment.nvim + JoosepAlviste/nvim-ts-context-commentstring: gcc/gc-family comment
-- toggling, with per-language commentstring detection inside mixed-syntax files (JSX in .js,
-- <script> in .vue, etc.) via treesitter.
return {
	{
		"numToStr/Comment.nvim",
		lazy = false,
		dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
		config = function()
			require("ts_context_commentstring").setup()

			require("Comment").setup({
				---Add a space b/w comment and the line
				---@type boolean
				padding = true,

				---Lines to be ignored while comment/uncomment.
				---Could be a regex string or a function that returns a regex string.
				---@type string|function
				ignore = nil,

				---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
				---@type table
				mappings = {
					---operator-pending mapping: `gcc`, `gcb`, `gc[count]{motion}`, `gb[count]{motion}`
					basic = true,
					---extra mapping: `gco`, `gcO`, `gcA`
					extra = true,
					---extended mapping: `g>`, `g<`, `g>[count]{motion}`, `g<[count]{motion}`
					extended = false,
				},

				---LHS of toggle mapping in NORMAL + VISUAL mode
				---@type table
				toggler = {
					line = "gcc",
					block = "gbc",
				},

				---LHS of operator-pending mapping in NORMAL + VISUAL mode
				---@type table
				opleader = {
					line = "gc",
					block = "gb",
				},

				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),

				---Post-hook, called after commenting is done
				---@type function|nil
				post_hook = nil,
			})
		end,
	},
}
