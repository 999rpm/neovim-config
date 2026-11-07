-- romgrk/barbar.nvim: buffer tabline. Mouse: click to open, click the button to close, drag to reorder. Sessions keep
-- the buffer order and pins ('globals' in 'sessionoptions', options.lua; SessionSavePre from persistence.lua). Above
-- neo-tree's window the tabline shows "Explorer" instead of tabs, on the side where the window sits. Owns <M-h>/<M-l>
-- and <leader>b.
-- Slanted tabs: every buffer sits between U+E0BC and U+E0BA, so both edges lean the same way (the "slanted" preset
-- pairs U+E0BC with U+E0BE, a trapezoid). The corner triangles take the tabline fill colour and the glyph background
-- the tab's own colour, derived from the active theme after every switch, the way lualine colours its section edges.
-- Themes that bring no barbar colours of their own (kanagawa: lotus, wave, dragon) underline the current tab instead,
-- edge to edge in the tab's text colour; tokyonight, catppuccin and monokai-pro keep their own current-tab colours.
local slant = { left = "\u{e0bc}", right = "\u{e0ba}" } -- escapes: private-use glyphs do not survive every copy of this file
local underline_themes = { kanagawa = true } -- vim.g.colors_name values; add a theme here to underline its current tab
local current_parts = {
	"",
	"Index",
	"Number",
	"Mod",
	"ModBtn",
	"Btn",
	"Pin",
	"PinBtn",
	"ADDED",
	"CHANGED",
	"DELETED",
	"ERROR",
	"WARN",
	"INFO",
	"HINT",
}

---Separator colours per buffer state (corner = tabline fill, body = the tab) and the current tab's underline. Without a
---fill colour (transparent mode) the theme's own separator highlights stay.
local function paint_tabs()
	local function get(name)
		return vim.api.nvim_get_hl(0, { name = name, link = false })
	end
	local sp = underline_themes[vim.g.colors_name] and get("BufferDefaultCurrent").fg or nil
	if sp then
		for _, part in ipairs(current_parts) do
			local def = get("BufferDefaultCurrent" .. part) -- barbar's fresh colours; BufferCurrent* may still hold the last theme's
			def.underline, def.sp = true, sp
			vim.api.nvim_set_hl(0, "BufferCurrent" .. part, def)
		end
		pcall(function()
			require("barbar.icons").set_highlights() -- icon groups copy BufferCurrent, underline included
		end)
	end
	local fill = get("BufferTabpageFill").bg or get("TabLineFill").bg
	if not fill then
		return
	end
	for _, state in ipairs({ "Current", "Visible", "Inactive", "Alternate" }) do
		local body = get("Buffer" .. state).bg or fill
		local mark = state == "Current" and sp or nil
		for _, suffix in ipairs({ "Sign", "SignRight" }) do
			vim.api.nvim_set_hl(
				0,
				"Buffer" .. state .. suffix,
				{ fg = fill, bg = body, underline = mark ~= nil, sp = mark }
			)
		end
	end
end

local tree_offsets = { left = 0, right = 0 } -- the widths last handed to barbar

---Tabline offset over neo-tree's window, on the screen edge the window touches. barbar's sidebar_filetypes took the
---side from the middle of the screen and kept the side a tree had left once its window crossed it (<C-w>| in the
---tree, a dragged separator, a narrow screen), so "Explorer" stayed over the editing window too, and after the tree
---had closed.
local function offset_for_tree()
	local widths = { left = 0, right = 0 }
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "neo-tree" and vim.api.nvim_win_get_config(win).relative == "" then -- floats (P preview) take no room
			local col, width = vim.api.nvim_win_get_position(win)[2], vim.api.nvim_win_get_width(win)
			if col == 0 then
				widths.left = width
			elseif col + width >= vim.o.columns then
				widths.right = width + 1 -- and the separator column on its left
			end
		end
	end
	for side, width in pairs(widths) do
		if tree_offsets[side] ~= width then
			tree_offsets[side] = width
			require("barbar.api").set_offset(
				width,
				width > 0 and "󰙅 Explorer" or "",
				nil,
				side,
				{ align = "center" }
			)
		end
	end
end

return {
	"romgrk/barbar.nvim",
	lazy = false,
	init = function()
		vim.g.barbar_auto_setup = false
	end,
	keys = {
		{ "<M-h>", "<Cmd>BufferPrevious<CR>", desc = "Previous buffer" }, -- n: Alt+h, the tab to the left; H stays the built-in window top, [b the previous buffer by number
		{ "<M-l>", "<Cmd>BufferNext<CR>", desc = "Next buffer" }, -- n: Alt+l, the tab to the right; L stays the built-in window bottom
		{ "<leader>bH", "<Cmd>BufferMovePrevious<CR>", desc = "Move buffer left" }, -- n: this buffer's tab one place to the left
		{ "<leader>bL", "<Cmd>BufferMoveNext<CR>", desc = "Move buffer right" }, -- n: one place to the right
		{ "<leader>bp", "<Cmd>BufferPin<CR>", desc = "Toggle pin" }, -- n: a pinned tab stays at the left and survives bo
		{ "<leader>bg", "<Cmd>BufferPick<CR>", desc = "Pick buffer" }, -- n: each tab shows a letter; typing it opens that buffer (g for go)
		{ "<leader>bx", "<Cmd>BufferPickDelete<CR>", desc = "Pick buffer to close" }, -- n: the same letters, closing the buffer instead
		{ "<leader>bd", "<Cmd>BufferClose<CR>", desc = "Close buffer" }, -- n: this buffer goes, the window stays
		{ "<leader>bo", "<Cmd>BufferCloseAllButCurrentOrPinned<CR>", desc = "Close other buffers" }, -- n: every buffer but this one and the pinned ones
		{ "<leader>bh", "<Cmd>BufferCloseBuffersLeft<CR>", desc = "Close buffers to the left" }, -- n: every tab left of this one
		{ "<leader>bl", "<Cmd>BufferCloseBuffersRight<CR>", desc = "Close buffers to the right" }, -- n: every tab right of this one
		{ "<leader>br", "<Cmd>BufferRestore<CR>", desc = "Reopen closed buffer" }, -- n: the buffer closed last comes back
		{ "<leader>bs", "<Cmd>BufferOrderByDirectory<CR>", desc = "Sort by directory" }, -- n: the tabs ordered by folder, then name
	},
	opts = {
		animation = false,
		maximum_padding = 1,
		no_name_title = "[No Name]",
		icons = {
			separator = slant, -- every state; barbar's states are current, visible, inactive and alternate (there is no "active")
			inactive = { separator = slant }, -- barbar's defaults give inactive buffers a separator of their own
			separator_at_end = false,
			button = "󰅖",
			pinned = { button = "󰐃", filename = true },
			diagnostics = {
				[vim.diagnostic.severity.ERROR] = { enabled = true, icon = "󰃤 " },
				[vim.diagnostic.severity.WARN] = { enabled = true, icon = "󰀦 " },
			},
		},
	},
	config = function(_, opts)
		opts.icons.filetype = { enabled = (pcall(require, "nvim-web-devicons")) } -- mini.lua's mini.icons stands in for it; without either, plain names rather than barbar's startup warning
		require("barbar").setup(opts)
		require("utils.core").on_colorscheme("barbar-tabs", paint_tabs)
		vim.api.nvim_create_autocmd({ "BufWinEnter", "WinClosed", "WinResized", "VimResized", "TabEnter" }, {
			group = require("utils.core").augroup("barbar-tree-offset"),
			desc = "999rpm: tabline offset over neo-tree's window, from the current layout",
			callback = function()
				vim.schedule(offset_for_tree) -- WinClosed runs while the window still exists
			end,
		})
	end,
}
