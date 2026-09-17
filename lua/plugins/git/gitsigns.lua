-- lewis6991/gitsigns.nvim: signs, hunk actions and inline blame.
-- Keys: ]c/[c next/previous hunk, <leader>gs stage, <leader>gr reset, <leader>gp preview, <leader>gf blame line, ih hunk text object.
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
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 500,
			virt_text_pos = "eol",
		},
		current_line_blame_formatter = " <author>, <author_time:%R> • <summary>",
		on_attach = function(bufnr)
			local gs = require("gitsigns")

			local function map(mode, lhs, rhs, opts)
				opts = opts or {}
				opts.buf = bufnr -- `buf`, not `buffer`: 0.12's canonical field name for both vim.keymap.set and nvim_create_autocmd
				vim.keymap.set(mode, lhs, rhs, opts)
			end

			map("n", "]c", function()
				if vim.wo.diff then
					return "]c" -- native diff mode: fall through to Nvim's own diff-hunk nav
				end
				vim.schedule(function()
					gs.nav_hunk("next")
				end)
				return "<Ignore>"
			end, { expr = true, desc = "Next Git Hunk" })

			map("n", "[c", function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(function()
					gs.nav_hunk("prev")
				end)
				return "<Ignore>"
			end, { expr = true, desc = "Prev Git Hunk" })

			map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage Hunk" })
			map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset Hunk" })
			map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview Hunk" })
			map("n", "<leader>gf", function()
				gs.blame_line({ full = true })
			end, { desc = "Blame Line (Popup)" })
			map("n", "<leader>og", gs.toggle_current_line_blame, { desc = "Toggle Cursor Blame" })
			map("n", "<leader>oG", gs.toggle_linehl, { desc = "Toggle Line Highlights" })
			map({ "o", "x" }, "ih", gs.select_hunk, { desc = "Select Hunk" })
		end,
	},
}
