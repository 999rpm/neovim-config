-- hat0uma/csvview.nvim: CSV and TSV files drawn as aligned columns with virtual text; the file stays plain text.
-- Keys: <leader>oC toggle the view. While it is on: ]v/[v next/previous field (end of the field), iF/aF field text object,
-- j/k move between rows. Commands: :CsvViewEnable/:CsvViewDisable/:CsvViewToggle accept options (:CsvViewToggle display_mode=highlight),
-- :CsvViewInfo shows the delimiter, header and size. The header sticks to the top of the window; the delimiter is detected.
-- The built-in <Tab> (jump list) and <CR> stay untouched, which is why upstream's Excel-style jump keys are not used.
return {
	"hat0uma/csvview.nvim",
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
	keys = {
		{ "<leader>oC", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV view" },
	},
	opts = {
		view = {
			display_mode = "border", -- a │ between columns instead of a dimmed comma
			spacing = { left = 1, right = 1 }, -- one space on each side of the border
		},
		keymaps = {
			textobject_field_inner = { "iF", mode = { "o", "x" } }, -- if/af are textobjects.lua's function objects
			textobject_field_outer = { "aF", mode = { "o", "x" } },
			jump_next_field_end = { "]v", mode = { "n", "x" } },
			jump_prev_field_end = { "[v", mode = { "n", "x" } },
		},
	},
}
