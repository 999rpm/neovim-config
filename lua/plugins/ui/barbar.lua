-- romgrk/barbar.nvim: buffer tabline. Mouse: click to open, click the button to close, drag to reorder.
-- Keys: <M-h>/<M-l> previous/next buffer in tabline order (H and L stay the built-in window top/bottom; ]b/[b also
-- cycle buffers), <leader>b* pick, pin, move, close and reopen.
return {
	"romgrk/barbar.nvim",
	lazy = false,
	dependencies = { "nvim-mini/mini.nvim", "lewis6991/gitsigns.nvim" },
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
			preset = "slanted", -- supplies the separator glyphs, so none are written in this file
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
}
