-- pwntester/octo.nvim: GitHub issues and pull requests. Needs an authenticated `gh` (gh auth login). Octo's buffer
-- keys sit on <localleader> (\) and which-key lists them there. Moved here off keys that do another job: Ctrl keys
-- (<C-r> redo, <C-y>/<C-e> scroll, <C-o> jump back, <C-f> page down, <C-x>/<C-a> decrement/increment, <C-m> Enter,
-- tmux's prefix <C-b>), the PR buffer's <leader>qa (this config's quit all) and its ]s/[s (next/previous misspelling).
-- Owns <leader>go.
local function keys(map) -- { action = lhs } to octo's { action = { lhs = lhs } }; deep merge keeps octo's own descs
	local out = {}
	for action, lhs in pairs(map) do
		out[action] = { lhs = lhs }
	end
	return out
end

local browse = { open_in_browser = "<localleader>B", copy_url = "<localleader>y" } -- n: \B open the item in the browser, \y copy its URL

return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	-- octo's own keys, in its buffers only: (n) <CR> the issue's or PR's actions, ]c/[c next/previous comment, gf open
	-- the file under the cursor, \ca add a comment, \ic close an issue, \pm merge a PR, \va add a reviewer, and the
	-- rest of the \ list; in the review tab ]q/[q next/previous changed file, ]Q/[Q last/first, ]t/[t next/previous
	-- thread, ]u/[u next/previous unviewed file, <C-c> close the tab; in the file panel j/k move, <CR> show the diff,
	-- R refresh; in a workflow run ]j/[j next/previous job, ]s/[s next/previous step, o expand a step.
	keys = {
		{ "<leader>goi", "<cmd>Octo issue list<cr>", desc = "Issues" }, -- n: the repository's open issues in a picker
		{ "<leader>gop", "<cmd>Octo pr list<cr>", desc = "Pull requests" }, -- n: open pull requests in a picker
		{ "<leader>goc", "<cmd>Octo pr create<cr>", desc = "Create pull request" }, -- n: from the current branch
		{ "<leader>gos", "<cmd>Octo search<cr>", desc = "Search" }, -- n: GitHub search across issues and PRs
	},
	opts = {
		use_local_fs = true, -- read files of a checked-out PR from disk
		picker = "snacks",
		picker_config = {
			mappings = keys({
				open_in_browser = "<A-b>", -- picker i/n: Alt+b open the item in the browser
				copy_url = "<A-y>", -- picker: Alt+y copy its URL
				copy_sha = "<A-e>", -- picker: Alt+e copy the commit SHA
				checkout_pr = "<A-o>", -- picker: Alt+o check the PR out
				merge_pr = "<A-M>", -- picker: Alt+Shift+m merge, shifted so a merge takes a deliberate chord
			}),
		},
		mappings = {
			issue = keys(vim.tbl_extend("force", browse, { reload = "<localleader>R" })), -- n: \B, \y, and \R reload the issue
			pull_request = keys(vim.tbl_extend("force", browse, {
				reload = "<localleader>R", -- n: \R reload the PR
				copy_sha = "<localleader>Y", -- n: \Y copy the head commit's SHA
				approve_pr = "<localleader>pa", -- n: \pa approve, beside octo's own \p PR keys
				stack_up = "<localleader>p]", -- n: \p] the next PR up the stack
				stack_down = "<localleader>p[", -- n: \p[ the next PR down the stack
			})),
			discussion = keys(browse), -- n: \B and \y in a discussion
			release = keys({ open_in_browser = "<localleader>B" }), -- n: \B the release page
			repo = keys({ open_in_browser = "<localleader>B" }), -- n: \B the repository page
			review_diff = keys({ copy_sha = "<localleader>Y" }), -- n: \Y copy the reviewed commit's SHA
			runs = keys(vim.tbl_extend("force", browse, {
				refresh = "<localleader>R", -- n: \R reload the workflow run
				rerun = "<localleader>rr", -- n: \rr run it again
				rerun_failed = "<localleader>rf", -- n: \rf rerun only the failed jobs
				cancel = "<localleader>x", -- n: \x cancel the run
			})),
			submit_win = keys({
				approve_review = "<localleader>a", -- n: \a submit the review as an approval
				comment_review = "<localleader>m", -- n: \m submit it as a comment (m for message)
				request_changes = "<localleader>r", -- n: \r submit it as a change request; <C-c> closes the window
			}),
		},
	},
	config = function(_, opts)
		if require("utils.core").warn_if_missing_exec("gh", "Octo", "Install GitHub CLI and run 'gh auth login'.") then
			require("octo").setup(opts) -- setup spawns gh at once and raises when it is missing
		end
	end,
}
