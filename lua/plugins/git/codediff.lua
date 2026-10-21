-- esmuellert/codediff.nvim: review workspace for working tree, staged changes, history, pull requests and merge
-- conflicts. Its buffer keys below sit on <localleader> (\), so they never shadow global prefixes. Owns <leader>G.
local function pick(source, build)
	return function()
		Snacks.picker[source]({
			confirm = function(picker, item)
				picker:close()
				local args = item and build(item)
				if args then
					vim.cmd("CodeDiff " .. args)
				end
			end,
		})
	end
end

return {
	"esmuellert/codediff.nvim",
	cmd = "CodeDiff",
	-- codediff's own keys in its tab: (n) q close, ]c/[c next/previous hunk, ]f/[f next/previous file, ]x/[x
	-- next/previous conflict, do/dp take/give a change, gf open the file in the previous tab, gS staged or unstaged
	-- side, ih the hunk as a text object, g? help; in the file list <CR> open, K details, R refresh, i list or tree, S/U
	-- stage/unstage all, X discard a file's changes, z folds.
	keys = {
		{ "<leader>Gd", "<cmd>CodeDiff<cr>", desc = "Working tree" }, -- n: every unstaged change, file by file (d for diff)
		{ "<leader>Gs", "<cmd>CodeDiff --staged<cr>", desc = "Staged changes" }, -- n: what the next commit would record
		{ "<leader>Gh", "<cmd>CodeDiff history %<cr>", desc = "File history" }, -- n: the commits that touched this file, each with its diff
		{ "<leader>GH", "<cmd>CodeDiff history<cr>", desc = "Repo history" }, -- n: every commit of the repository, uppercase twin of Gh
		{ "<leader>Gx", "<cmd>CodeDiff close<cr>", desc = "Close review" }, -- n: close the review tab
		{
			"<leader>Gp",
			function()
				vim.ui.input({ prompt = "Pull request number: " }, function(nr)
					if nr and nr:match("^%d+$") then
						vim.cmd("CodeDiff pr " .. nr)
					end
				end)
			end,
			desc = "Pull request",
		}, -- n: type a pull request number to review its changes
		{ "<leader>Gb", pick("git_branches", function(item)
			return item.branch
		end), desc = "Compare branch" }, -- n: pick a branch; its difference from the working tree
		{
			"<leader>Gc",
			pick("git_log", function(item)
				return item.commit and (item.commit .. "~ " .. item.commit)
			end),
			desc = "Review commit",
		}, -- n: pick a commit from the log and see what it changed
	},
	opts = {
		diff = { gutter_signs = true },
		explorer = { view_mode = "tree" },
		keymaps = {
			view = {
				toggle_explorer = "<localleader>e", -- n: \e the file list on or off
				focus_explorer = "<localleader>E", -- n: \E into the file list
				stage_hunk = "<localleader>s", -- n: \s stage the hunk under the cursor
				unstage_hunk = "<localleader>u", -- n: \u take it out of the index again
				discard_hunk = "<localleader>r", -- n: \r throw the hunk's changes away (r for reset)
				toggle_stage = "<localleader>g", -- n: \g stage or unstage the whole file
				toggle_layout = "<localleader>l", -- n: \l side by side or one above the other
				toggle_compact = "<localleader>c", -- n: \c only the hunks, the unchanged lines folded
				align_move = "<localleader>m", -- n: \m line up moved code in the other pane
			},
			conflict = {
				accept_incoming = "<localleader>t", -- n: \t keep the incoming side (the branch being merged in)
				accept_current = "<localleader>o", -- n: \o keep the current side (the checked-out branch)
				accept_both = "<localleader>b", -- n: \b keep both sides
				discard = "<localleader>x", -- n: \x drop both sides
				accept_all_incoming = "<localleader>T", -- n: \T the incoming side in every conflict of the file
				accept_all_current = "<localleader>O", -- n: \O the current side in every conflict
				accept_all_both = "<localleader>B", -- n: \B both sides in every conflict
				discard_all = "<localleader>X", -- n: \X drop both sides of every conflict
			},
		},
	},
}
