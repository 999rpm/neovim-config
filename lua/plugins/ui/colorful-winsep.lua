-- nvim-zh/colorful-winsep.nvim: briefly highlights and animates the window separator nearest
-- whichever split was just entered — visual feedback for config/mappings.lua's own
-- `<M-w/a/s/d>` window navigation, which otherwise gives no cue beyond the cursor itself moving.
-- A low-priority candidate from the smaller aesthetic group (AUDIT_SUMMARY.md), added now that a
-- plugin addition is an explicit ask. `border = "rounded"` matches options.lua's global
-- `winborder` default; `excluded_ft` extends upstream's own default three entries
-- (`packer`/`TelescopePrompt`/`mason`) with this config's other single-window utility surfaces
-- (a plain single line/column separator flashing around a dashboard or a picker reads as
-- visual noise, not useful feedback, the same reasoning lualine.lua/hardtime.lua's own
-- `disabled_filetypes` lists already apply elsewhere).
return {
	"nvim-zh/colorful-winsep.nvim",
	event = "WinLeave",
	opts = {
		border = "rounded",
		excluded_ft = { "packer", "TelescopePrompt", "mason", "neo-tree", "alpha", "Trouble", "trouble", "lazy" },
	},
}
