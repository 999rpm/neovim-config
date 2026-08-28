-- s1n7ax/nvim-window-picker: overlay a letter on every window and jump straight to whichever
-- one is pressed — useful once more than two splits are open, where the directional
-- `<M-w/a/s/d>` window-nav in config/mappings.lua stops being a one-press affair. A
-- previously-open candidate (AUDIT_SUMMARY.md), added now that a plugin addition is an
-- explicit ask.
--
-- `filter_rules.bo.filetype` below is upstream's own default four entries
-- (`NvimTree`/`neo-tree`/`notify`/`snacks_notif` — verified against lua/window-picker/
-- config.lua) plus this config's own other utility surfaces, written out in full rather than
-- passed as a shorter "just the additions" table: `setup()`'s own merge is a genuine
-- `vim.tbl_deep_extend`, confirmed by reading lua/window-picker/init.lua directly, but that
-- function matches nested list-like tables by numeric index, not by appending — a shorter list
-- here would silently overwrite upstream's entries at the matching indices instead of adding to
-- them. `buftype = {"terminal"}` (also upstream default) already excludes toggleterm.lua's
-- windows without needing a restated entry here.
return {
	"s1n7ax/nvim-window-picker",
	event = "VeryLazy",
	opts = {
		filter_rules = {
			bo = {
				filetype = {
					"NvimTree",
					"neo-tree",
					"notify",
					"snacks_notif",
					"Trouble",
					"trouble",
					"qf",
					"lazy",
					"mason",
					"alpha",
					"TelescopePrompt",
				},
			},
		},
	},
	keys = {
		{
			"<leader>ew",
			function()
				local picked = require("window-picker").pick_window()
				if picked then
					vim.api.nvim_set_current_win(picked)
				end
			end,
			desc = "Pick Window",
		},
	},
}
