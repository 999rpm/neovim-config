-- dominic-righthere/markdown-pipetable.nvim: markdown pipe tables drawn to fit the window, with cell navigation and
-- spreadsheet-style row and column edits. The file stays plain markdown. It owns table drawing, so render-markdown.lua
-- sets pipe_table.enabled = false; with both on, the two renderers paint over each other.
-- Table mode starts only from <leader>oT or :Pipetable: started by itself (upstream's auto_enter), it would give h j k
-- l, i, u, dd, p and the other edit keys table jobs as soon as the cursor touched a table. Commands: :TableFromCSV (on
-- selected lines), :TablePasteCSV, :TableToCSV, :TableSort, :TableAlign, :checkhealth pipetable. Owns <leader>oT and
-- the <localleader>T table group, beside markdown-plus.lua's <localleader>t.
return {
	"dominic-righthere/markdown-pipetable.nvim",
	main = "pipetable",
	ft = "markdown",
	-- markdown-pipetable's own keys while table mode is on: h/j/k/l move between cells, _ 0 ^ first column, $ last
	-- column, gg/G first/last row, <CR> open the cell, i/a edit it (<CR> commit, <Tab> commit and edit the next column,
	-- <Esc> back), u/<C-r> undo/redo, o/O insert a row below/above, dd delete the row, yy yank it, p/P paste, v cells,
	-- V rows, <C-v> columns, then d, y, x on the selection, <Esc> or q leave; \T then ir/iR insert a row below/above,
	-- ic/iC a column right/left, dr/dc delete a row/column, mj/mk/mh/ml move, cr/cc duplicate, al/ac/ar/ad align,
	-- s/S sort.
	keys = {
		{ "<leader>oT", "<cmd>Pipetable<cr>", ft = "markdown", desc = "Toggle table mode" }, -- n: spreadsheet-style editing of the table under the cursor, on or off
	},
	opts = {
		auto_enter = false, -- upstream enters table mode whenever the cursor lands on a table; <leader>oT does it on request
		cursor = { column_highlight = true }, -- active row and column tinted, as a spreadsheet crosshair
		keys = {
			leader = "<localleader>T", -- <localleader>t is markdown-plus's table group
		},
	},
}
