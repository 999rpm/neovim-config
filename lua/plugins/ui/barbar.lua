-- romgrk/barbar.nvim: buffer tabline. Mouse: click to open, click the button to close, drag to reorder.
-- Keys: <M-h>/<M-l> previous/next buffer in tabline order (H and L stay the built-in window top/bottom; ]b/[b also
-- cycle buffers), <leader>b* pick, pin, move, close and reopen.
-- Slanted tabs: every buffer sits between U+E0BC and U+E0BA, so both edges lean the same way (the "slanted" preset pairs
-- U+E0BC with U+E0BE, a trapezoid). The corner triangles take the tabline fill colour and the glyph background the tab's
-- own colour, derived from the active theme after every switch, the way lualine colours its section edges.
local slant = { left = "\u{e0bc}", right = "\u{e0ba}" } -- escapes: private-use glyphs do not survive every copy of this file

---Separator colours per buffer state: corner = tabline fill, body = the tab. Without a fill colour (transparent mode)
---the theme's own separator highlights stay.
local function paint_slants()
	local function bg(name)
		return vim.api.nvim_get_hl(0, { name = name, link = false }).bg
	end
	local fill = bg("BufferTabpageFill") or bg("TabLineFill")
	if not fill then
		return
	end
	for _, state in ipairs({ "Current", "Visible", "Inactive", "Alternate" }) do
		local body = bg("Buffer" .. state) or fill
		for _, suffix in ipairs({ "Sign", "SignRight" }) do
			vim.api.nvim_set_hl(0, "Buffer" .. state .. suffix, { fg = fill, bg = body })
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
		{ "<M-h>", "<Cmd>BufferPrevious<CR>", desc = "Previous buffer" },
		{ "<M-l>", "<Cmd>BufferNext<CR>", desc = "Next buffer" },
		{ "<leader>bH", "<Cmd>BufferMovePrevious<CR>", desc = "Move buffer left" },
		{ "<leader>bL", "<Cmd>BufferMoveNext<CR>", desc = "Move buffer right" },
		{ "<leader>bp", "<Cmd>BufferPin<CR>", desc = "Toggle pin" },
		{ "<leader>bg", "<Cmd>BufferPick<CR>", desc = "Pick buffer" },
		{ "<leader>bx", "<Cmd>BufferPickDelete<CR>", desc = "Pick buffer to close" },
		{ "<leader>bd", "<Cmd>BufferClose<CR>", desc = "Close buffer" },
		{ "<leader>bo", "<Cmd>BufferCloseAllButCurrentOrPinned<CR>", desc = "Close other buffers" },
		{ "<leader>bh", "<Cmd>BufferCloseBuffersLeft<CR>", desc = "Close buffers to the left" },
		{ "<leader>bl", "<Cmd>BufferCloseBuffersRight<CR>", desc = "Close buffers to the right" },
		{ "<leader>br", "<Cmd>BufferRestore<CR>", desc = "Reopen closed buffer" },
		{ "<leader>bs", "<Cmd>BufferOrderByDirectory<CR>", desc = "Sort by directory" },
	},
	opts = {
		animation = false,
		auto_hide = false,
		focus_on_close = "previous",
		insert_at_end = false, -- new buffers open next to the current one
		maximum_padding = 1,
		minimum_padding = 1,
		no_name_title = "[No Name]",
		sidebar_filetypes = {
			["neo-tree"] = { event = "BufWipeout", text = "󰙅 Explorer", align = "center" },
		},
		icons = {
			separator = slant, -- every state; barbar's states are current, visible, inactive and alternate (there is no "active")
			inactive = { separator = slant }, -- barbar's defaults give inactive buffers a separator of their own
			separator_at_end = false,
			button = "󰅖",
			modified = { button = "●" },
			pinned = { button = "󰐃", filename = true },
			diagnostics = {
				[vim.diagnostic.severity.ERROR] = { enabled = true, icon = "󰃤 " },
				[vim.diagnostic.severity.WARN] = { enabled = true, icon = "󰀦 " },
			},
		},
	},
	config = function(_, opts)
		require("barbar").setup(opts)
		require("utils").on_colorscheme("barbar-slants", paint_slants)
	end,
}
