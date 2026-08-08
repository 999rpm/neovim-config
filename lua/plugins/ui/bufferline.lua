-- akinsho/bufferline.nvim: tab-style buffer line along the top, with git/diagnostic status
-- per buffer.
--
-- 2026-08-06: config-wide audit (full scope in init.lua). Removed the custom `highlights`
-- override and its `User ThemeChanged` refresh listener. Both existed only to consume a
-- `_G.TokyoColors()` global that a prior pass already flagged as suspicious and, after this
-- pass's full read of every file in the config, is confirmed to be defined nowhere at all —
-- so `colors()` always returned nil, the `highlights = c and {...} or nil` branch always took
-- the `nil` side, and the listener that re-ran it on every theme change had nothing real to
-- refresh either. Removed both rather than keep carrying a "maybe you have this elsewhere"
-- branch plus a listener whose only job was refreshing that same dead branch. Nothing is lost:
-- bufferline's own default highlight groups already derive from the active colorscheme
-- automatically on every `:colorscheme` call, same as any other plugin's default highlights.
-- If you want bufferline's selected/modified/duplicate/pick colors pulled from the palette on
-- purpose later, tokyonight/catppuccin/kanagawa each expose their own palette module you could
-- read from directly, the way plugins/ui/indent-blankline.lua and plugins/treesitter/
-- rainbow-delimiters.lua do via shared highlight-group names instead of copied hex values.
--
-- Also this pass: `smart_close` now calls famiu/bufdelete.nvim (plugins/ui/bufdelete.lua)
-- instead of mini.bufremove — a standalone, single-purpose plugin doing the exact same job
-- (delete a buffer without disturbing window layout) without pulling in the rest of the
-- mini.nvim bundle for one function. See plugins/editor/mini.lua's own note for the same
-- reasoning applied to mini.hipatterns.
return {
	"akinsho/bufferline.nvim",
	version = "*",
	event = "UIEnter",

	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"famiu/bufdelete.nvim", -- full spec in plugins/ui/bufdelete.lua; listed here for install/load ordering only
	},

	config = function()
		local bufferline = require("bufferline")

		local function smart_close(bufnr)
			local ft = vim.bo[bufnr].filetype

			-- Special buffers should not use bufdelete
			if ft == "neo-tree" or ft == "terminal" then
				vim.cmd("bd " .. bufnr)
				return
			end

			require("bufdelete").bufdelete(bufnr, false)
		end

		bufferline.setup({
			options = {
				mode = "buffers",
				numbers = "none",
				separator_style = "thin",
				always_show_bufferline = true,
				sort_by = "insert_after_current",
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(_, _, diagnostics_dict)
					local icons = {
						error = " ",
						warning = " ",
					}
					local s = ""
					for severity, count in pairs(diagnostics_dict) do
						if icons[severity] and count > 0 then
							s = s .. icons[severity] .. count .. " "
						end
					end
					return vim.trim(s)
				end,
				close_command = smart_close,
				right_mouse_command = smart_close,
				offsets = {
					{
						filetype = "neo-tree",
						text = "󰙅 Explorer",
						text_align = "center",
						separator = true,
					},
				},
				hover = {
					enabled = false,
				},
			},
		})

		local map = vim.keymap.set

		-- Power-user navigation (non-leader, intentional). Overrides Nvim's native `H`/`L`
		-- ("move cursor to top/bottom of the visible window", i.e. High/Low) — deliberate
		-- trade: fast buffer-cycling on two bare keys, at the cost of those two native cursor
		-- jumps. `H`/`L` have no other mapping elsewhere in this config, so nothing else
		-- depends on getting the native behavior back.
		map("n", "L", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
		map("n", "H", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })

		-- Reorder buffers
		map("n", "<leader>bL", "<cmd>BufferLineMoveNext<CR>", { desc = "Move Buffer Right" })
		map("n", "<leader>bH", "<cmd>BufferLineMovePrev<CR>", { desc = "Move Buffer Left" })

		-- Pin / Pick
		map("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "Toggle Pin" })
		map("n", "<leader>bg", "<cmd>BufferLinePick<CR>", { desc = "Pick Buffer" })

		-- Close actions
		map("n", "<leader>bx", "<cmd>BufferLinePickClose<CR>", { desc = "Pick & Close Buffer" })
		map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close Other Buffers" })
		map("n", "<leader>bl", "<cmd>BufferLineCloseRight<CR>", { desc = "Close Buffers to Right" })
		map("n", "<leader>bh", "<cmd>BufferLineCloseLeft<CR>", { desc = "Close Buffers to Left" })
	end,
}
