-- lewis6991/gitsigns.nvim: inline hunk signs, current-line blame, and per-hunk stage/reset/
-- preview — the inline, buffer-local complement to plugins/git/diffview.lua's full-repo
-- diff/history views and plugins/ui/snacks.lua's LazyGit/gitbrowse launchers (`<leader>g*`
-- below is shared with those two; snacks.lua's own keys live under the same group without
-- colliding on a specific key).
--
-- 2026-08-06: config-wide audit (full scope in init.lua). Hunk navigation moved from `]g`/`[g`
-- back to gitsigns.nvim's own documented convention, `]c`/`[c` — freed up by moving
-- plugins/editor/textobjects.lua's class navigation off those same keys (see that file's
-- note). This isn't just a cosmetic swap: `]c`/`[c` are also Neovim's *native* diff-mode
-- navigation keys, and the `if vim.wo.diff then return ... end` escape hatch below only
-- actually works when the returned key is a real native command. On `]g`/`[g`, that fallback
-- was quietly dead — nothing native is bound to `]g` — so inside an actual diff view it just
-- did nothing. On `]c`/`[c` it now falls through to genuine native diff-hunk navigation, e.g.
-- inside plugins/git/diffview.lua's windows, matching gitsigns.nvim's own README example.
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
				opts.buffer = bufnr
				vim.keymap.set(mode, lhs, rhs, opts)
			end

			map("n", "]c", function()
				if vim.wo.diff then
					return "]c" -- inside a real diff window (e.g. diffview.lua): fall through to native diff-hunk nav
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
			map("n", "<leader>tg", gs.toggle_current_line_blame, { desc = "Toggle Cursor Blame" })
			map("n", "<leader>tG", gs.toggle_linehl, { desc = "Toggle Line Highlights" })
			map({ "o", "x" }, "ih", gs.select_hunk, { desc = "Select Hunk" })
		end,
	},
}
