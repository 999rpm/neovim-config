-- romgrk/barbar.nvim: buffer tabline. Mouse: click to open, click the button to close, drag to reorder.
-- Keys: <M-h>/<M-l> previous/next buffer in tabline order (H and L stay the built-in window top/bottom; ]b/[b also
-- cycle buffers), <leader>b* pick, pin, move, close and reopen.
-- Slanted tabs: every buffer sits between U+E0BC and U+E0BA, so both edges lean the same way (the "slanted" preset pairs
-- U+E0BC with U+E0BE, a trapezoid). The corner triangles take the tabline fill colour and the glyph background the tab's
-- own colour, derived from the active theme after every switch, the way lualine colours its section edges.
-- Themes that bring no barbar colours of their own (kanagawa: lotus, wave, dragon) underline the current tab instead,
-- edge to edge in the tab's text colour; tokyonight, catppuccin and monokai-pro keep their own current-tab colours.
local slant = { left = "\u{e0bc}", right = "\u{e0ba}" } -- escapes: private-use glyphs do not survive every copy of this file
local underline_themes = { kanagawa = true } -- vim.g.colors_name values; add a theme here to underline its current tab
local current_parts =
	{ "", "Index", "Number", "Mod", "ModBtn", "Btn", "Pin", "PinBtn", "ADDED", "CHANGED", "DELETED", "ERROR", "WARN", "INFO", "HINT" }

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
			vim.api.nvim_set_hl(0, "Buffer" .. state .. suffix, { fg = fill, bg = body, underline = mark ~= nil, sp = mark })
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
		require("utils").on_colorscheme("barbar-tabs", paint_tabs)
	end,
}
