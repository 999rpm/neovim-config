-- dominic-righthere/markdown-pipetable.nvim: markdown pipe tables drawn to fit the window, with cell navigation and
-- spreadsheet-style row and column edits. The file stays plain markdown. It owns table drawing, so render-markdown.lua
-- sets pipe_table.enabled = false; with both on, the two renderers paint over each other.
-- Keys: <leader>oT toggle table mode (it also starts by itself when the cursor lands on a table).
-- In a table: h/j/k/l move between cells, _ 0 ^ first column, $ last column, gg/G first/last row, <CR> open the cell,
-- i/a edit it (<CR> commit, <Tab> commit and edit the next column, <Esc> back), u/<C-r> undo/redo, <Esc> or q leave.
-- o/O insert a row below/above, dd delete the row, yy yank it, p/P paste. v cells, V rows, <C-v> columns select; d, y, x
-- act on the selection. <localleader>T group (table only): ir/iR insert row below/above, ic/iC insert column right/left,
-- dr/dc delete row/column, mj/mk move row, mh/ml move column, cr/cc duplicate row/column, al/ac/ar/ad align, s/S sort.
-- Commands: :TableFromCSV (on selected lines), :TablePasteCSV, :TableToCSV, :TableSort, :TableAlign, :checkhealth pipetable.
-- Overlaps markdown-plus.lua's <localleader>t table keys; the group sits on T so both stay available.
return {
	"dominic-righthere/markdown-pipetable.nvim",
	main = "pipetable",
	ft = "markdown",
	keys = {
		{ "<leader>oT", "<cmd>Pipetable<cr>", ft = "markdown", desc = "Toggle table mode" },
	},
	opts = {
		cursor = { column_highlight = true }, -- active row and column tinted, as a spreadsheet crosshair
		keys = {
			leader = "<localleader>T", -- <localleader>t is markdown-plus's table group
		},
	},
}
