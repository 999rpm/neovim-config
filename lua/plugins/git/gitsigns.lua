-- lewis6991/gitsigns.nvim: signs, hunk actions and inline blame. Staged hunks reuse the same glyphs in their own
-- highlight; a notebook (.ipynb) gets no signs, since its buffer holds jupytext markdown, not the JSON git tracks.
-- Keys are set per buffer in on_attach; gitsigns maps none itself. Owns <leader>gs/gr/gp/gf, <leader>og/oG, ]c/[c, ih.
return {
	"lewis6991/gitsigns.nvim",
	cond = function()
		return require("utils.core").executable("git") -- without git its setup aborts with a message on every start
	end,
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			delete = { text = "┃" },
			changedelete = { text = "║" },
			topdelete = { text = "│" },
		},
		signs_staged = { -- staged hunks read a table of their own; the same three keep one shape per column
			delete = { text = "┃" },
			changedelete = { text = "║" },
			topdelete = { text = "│" },
		},
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 500,
		},
		current_line_blame_formatter = "󰜘 <author>, <author_time:%R> • <summary>",
		on_attach = function(bufnr)
			if vim.b[bufnr]._999rpm_notebook then
				return false -- the buffer holds jupytext markdown, not the JSON git tracks
			end
			local gs = require("gitsigns")

			local function map(mode, lhs, rhs, opts)
				opts = opts or {}
				opts.buf = bufnr
				vim.keymap.set(mode, lhs, rhs, opts)
			end

			local function hunk(direction, builtin)
				return function()
					if vim.wo.diff then
						return builtin -- diff mode: Nvim's own diff-change motion, count included
					end
					local count = vim.v.count1 -- read now: v:count is reset by the time the scheduled call runs
					vim.schedule(function()
						gs.nav_hunk(direction, { count = count })
					end)
					return "<Ignore>"
				end
			end
			map("n", "]c", hunk("next", "]c"), { expr = true, desc = "Next git hunk" }) -- n: upgrades built-in ]c: in diff mode the built-in, elsewhere (where it does nothing) the next hunk, counts kept
			map("n", "[c", hunk("prev", "[c"), { expr = true, desc = "Previous git hunk" }) -- n: upgrades built-in [c the same way

			map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" }) -- n: git add for the hunk under the cursor only
			map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" }) -- n: throw the hunk's changes away
			map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" }) -- n: the hunk's diff in a float
			map("n", "<leader>gf", function()
				gs.blame_line({ full = true })
			end, { desc = "Blame line (popup)" }) -- n: who changed this line, with the full commit message
			map("n", "<leader>og", gs.toggle_current_line_blame, { desc = "Toggle inline blame" }) -- n: the author note at the end of the cursor line
			map("n", "<leader>oG", gs.toggle_linehl, { desc = "Toggle line highlights" }) -- n: tint whole changed lines, uppercase twin of og
			map({ "o", "x" }, "ih", gs.select_hunk, { desc = "Select hunk" }) -- o/x: the hunk as a text object (dih, vih)
		end,
	},
}
