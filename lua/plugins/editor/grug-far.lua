-- MagicDuck/grug-far.nvim: project-wide search and replace in a buffer. Needs ripgrep.
-- Keys: <leader>rr open (visual: prefilled with the selection), rw word under the cursor, rf limited to this file type.
-- In the buffer: <localleader>r replace all, <localleader>s sync lines, <localleader>c abort, q close.
return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	opts = {
		headerMaxWidth = 80,
	},
	keys = {
		{
			"<leader>rr",
			function()
				require("grug-far").open({})
			end,
			mode = { "n", "x" },
			desc = "Search & Replace",
		},
		{
			"<leader>rw",
			function()
				require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
			end,
			desc = "Replace Word Under Cursor",
		},
		{
			"<leader>rf",
			function()
				local ext = vim.bo.buftype == "" and vim.fn.expand("%:e") or nil
				require("grug-far").open({
					prefills = { filesFilter = ext and ext ~= "" and ("*." .. ext) or nil },
				})
			end,
			desc = "Replace In Current File Type",
		},
	},
}
