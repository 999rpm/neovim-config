-- akinsho/bufferline.nvim: tab-style buffer line along the top, with git/diagnostic status
-- per buffer. `separator_style = "slope"` (below) gives the skewed/parallelogram tab look,
-- sloped to the right — bufferline's own doc/bufferline.txt lists this as distinct from
-- `"slant"` (same shape, no rightward slope). `smart_close` calls
-- famiu/bufdelete.nvim (plugins/ui/bufdelete.lua) rather than mini.bufremove — a standalone,
-- single-purpose plugin doing the exact same job (delete a buffer without disturbing window
-- layout) without pulling in the rest of the mini.nvim bundle for one function; see
-- plugins/editor/mini.lua's own note for the same reasoning applied to mini.hipatterns.
--
-- Highlight refresh on theme change: bufferline.nvim registers its OWN native `ColorScheme`
-- autocmd internally (confirmed by reading lua/bufferline.lua's `setup_autocommands` directly)
-- that recomputes every derived colour, including the `separator*` group below, from the
-- ORIGINAL opts this file passes to `setup()` — not from this config's own custom "ThemeChanged"
-- User event. No extra listener needed here for that; themes.lua's own comment crediting this
-- file with a "ThemeChanged" hook was imprecise (the mechanism is bufferline's own, not
-- ThemeChanged-driven) and has been corrected there.
return {
	"akinsho/bufferline.nvim",
	version = "*",
	event = "UIEnter",

	dependencies = {
		"echasnovski/mini.nvim",
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
				-- "slope" gives the skewed/parallelogram tab look, sloped to the right. If it
				-- renders oddly in your terminal (some emulators need full-height glyphs
				-- padded), try "padded_slope" instead — bufferline's own docs call this out
				-- as terminal-dependent.
				separator_style = "slope",
				always_show_bufferline = true,
				sort_by = "insert_after_current",
				diagnostics = "nvim_lsp",
				-- Same codepoints as plugins/ui/lualine.lua's/plugins/lsp/lspconfig.lua's error/warn
				-- diagnostic icons, so a red/yellow glyph means the same severity everywhere.
				diagnostics_indicator = function(_, _, diagnostics_dict)
					local icons = {
						error = "󰃤 ",
						warning = "󰀦 ",
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
			-- Explicit colour for the tab separators (previously left at bufferline's own
			-- default, a subtle tint of the background - barely visible against most of this
			-- config's themes). `link`, not `fg`/`bg`, so this tracks whichever colour the
			-- active theme gives these semantic groups rather than a hardcoded hex that would
			-- only look right in one of the three themes themes.lua switches between.
			-- Confirmed via bufferline's own update_highlights() (lua/bufferline/config.lua)
			-- that this survives every subsequent theme switch, not just the first setup() call.
			highlights = {
				separator_selected = { link = "Function" }, -- the active tab's divider: stands out
				separator = { link = "Comment" }, -- inactive tabs: present, but not competing for attention
				separator_visible = { link = "Comment" },
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
