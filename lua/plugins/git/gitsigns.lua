-- lewis6991/gitsigns.nvim: signs, hunk actions and inline blame.
-- Keys: ]c/[c next/previous hunk, <leader>gs stage, <leader>gr reset, <leader>gp preview, <leader>gf blame line, ih hunk text object.
-- Toggles: <leader>og inline blame, <leader>oG line highlights. Staged hunks reuse the same glyphs in their own highlight.
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "┃" },
			changedelete = { text = "║" },
			topdelete = { text = "│" },
			untracked = { text = "┆" },
		},
		signs_staged = { -- gitsigns ships a different glyph set for staged hunks; matching them keeps one shape per column
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "┃" },
			changedelete = { text = "║" },
			topdelete = { text = "│" },
		},
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 500,
			virt_text_pos = "eol",
		},
		current_line_blame_formatter = "󰜘 <author>, <author_time:%R> • <summary>",
		on_attach = function(bufnr)
			local gs = require("gitsigns")

			local function map(mode, lhs, rhs, opts)
				opts = opts or {}
				opts.buf = bufnr
				vim.keymap.set(mode, lhs, rhs, opts)
			end

			map("n", "]c", function()
				if vim.wo.diff then
					return "]c" -- diff mode: fall through to Nvim's own diff-change motion
				end
				vim.schedule(function()
					gs.nav_hunk("next")
				end)
				return "<Ignore>"
			end, { expr = true, desc = "Next git hunk" })

			map("n", "[c", function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(function()
					gs.nav_hunk("prev")
				end)
				return "<Ignore>"
			end, { expr = true, desc = "Previous git hunk" })

			map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
			map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
			map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
			map("n", "<leader>gf", function()
				gs.blame_line({ full = true })
			end, { desc = "Blame line (popup)" })
			map("n", "<leader>og", gs.toggle_current_line_blame, { desc = "Toggle inline blame" })
			map("n", "<leader>oG", gs.toggle_linehl, { desc = "Toggle line highlights" })
			map({ "o", "x" }, "ih", gs.select_hunk, { desc = "Select hunk" })
		end,
	},
}
