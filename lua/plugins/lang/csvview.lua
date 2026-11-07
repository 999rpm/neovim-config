-- hat0uma/csvview.nvim: CSV and TSV files drawn as aligned columns with virtual text; the file stays plain text.
-- :CsvViewEnable, :CsvViewDisable and :CsvViewToggle accept options (:CsvViewToggle display_mode=highlight), and
-- :CsvViewInfo shows the delimiter, header and size. The header row sticks to the top of the window; the delimiter is
-- detected. Upstream's Excel-style <Tab>/<CR> jumps stay off, so the built-in <Tab> (jump list) and <CR> keep their
-- jobs. Owns <leader>oC, and ]v/[v and iF/aF while the view is on.
return {
	"hat0uma/csvview.nvim",
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
	keys = {
		{ "<leader>oC", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV view" }, -- n: aligned columns on or off for this buffer
	},
	opts = {
		view = {
			display_mode = "border", -- a │ between columns instead of a dimmed comma
			spacing = { left = 1, right = 1 }, -- one space on each side of the border
		},
		keymaps = {
			textobject_field_inner = { "iF", mode = { "o", "x" } }, -- o/x: the field under the cursor (ciF); if/af are textobjects.lua's function objects
			textobject_field_outer = { "aF", mode = { "o", "x" } }, -- o/x: the field with its delimiter (daF)
			jump_next_field_end = { "]v", mode = { "n", "x" } }, -- n/x: the end of the next field (v for value)
			jump_prev_field_end = { "[v", mode = { "n", "x" } }, -- n/x: the end of the previous field
		},
	},
}
