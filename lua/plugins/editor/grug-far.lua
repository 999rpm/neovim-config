-- MagicDuck/grug-far.nvim: project-wide search and replace in a buffer. Needs ripgrep. Owns <leader>r.
return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	opts = {},
	-- grug-far's own keys in its buffer (\ is <localleader>): (n) \r replace all, \s write edited result lines back to
	-- the files, \l only this line, \q results to the quickfix list, \t history, \b abort, \c close, <CR> open the
	-- location, <Up>/<Down> previous/next location, <Tab>/<S-Tab> next/previous input field, g? help.
	keys = {
		{
			"<leader>rr",
			function()
				require("grug-far").open({})
			end,
			mode = { "n", "x" },
			desc = "Search and replace",
		}, -- n/x: an empty search, or the selected text as the search (r for replace)
		{
			"<leader>rw",
			function()
				require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
			end,
			desc = "Word under cursor",
		}, -- n: the search starts as the word under the cursor
		{
			"<leader>rf",
			function()
				local ext = vim.bo.buftype == "" and vim.fn.expand("%:e") or nil
				require("grug-far").open({
					prefills = { filesFilter = ext and ext ~= "" and ("*." .. ext) or nil },
				})
			end,
			desc = "Limit to this file type",
		}, -- n: only files with this buffer's extension, such as *.lua
	},
}
