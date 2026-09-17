-- esmuellert/codediff.nvim: review workspace for working tree, staged changes, history, pull requests and merge conflicts.
-- Review keys live on <localleader> (\) so they never shadow global prefixes. Conflicts: ]x/[x next/previous.
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
	keys = {
		{ "<leader>Gd", "<cmd>CodeDiff<cr>", desc = "Working tree" },
		{ "<leader>Gs", "<cmd>CodeDiff --staged<cr>", desc = "Staged changes" },
		{ "<leader>Gh", "<cmd>CodeDiff history %<cr>", desc = "File history" },
		{ "<leader>GH", "<cmd>CodeDiff history<cr>", desc = "Repo history" },
		{ "<leader>Gx", "<cmd>CodeDiff close<cr>", desc = "Close review" },
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
		},
		{ "<leader>Gb", pick("git_branches", function(item)
			return item.branch
		end), desc = "Compare branch" }, -- branch vs working tree
		{
			"<leader>Gc",
			pick("git_log", function(item)
				return item.commit and (item.commit .. "~ " .. item.commit)
			end),
			desc = "Review commit",
		},
	},
	opts = {
		diff = {
			disable_inlay_hints = true, -- inlay hints shift columns between panes
			gutter_signs = true,
			jump_to_first_change = true,
		},
		explorer = {
			position = "left",
			width = 40,
			view_mode = "tree",
			indent_markers = true,
		},
		keymaps = {
			view = {
				toggle_explorer = "<localleader>e",
				focus_explorer = "<localleader>E",
				stage_hunk = "<localleader>s",
				unstage_hunk = "<localleader>u",
				discard_hunk = "<localleader>r",
				toggle_stage = "<localleader>g",
				toggle_layout = "<localleader>l",
				toggle_compact = "<localleader>c",
				align_move = "<localleader>m",
			},
			conflict = {
				accept_incoming = "<localleader>t",
				accept_current = "<localleader>o",
				accept_both = "<localleader>b",
				discard = "<localleader>x",
				accept_all_incoming = "<localleader>T",
				accept_all_current = "<localleader>O",
				accept_all_both = "<localleader>B",
				discard_all = "<localleader>X",
			},
		},
	},
}
