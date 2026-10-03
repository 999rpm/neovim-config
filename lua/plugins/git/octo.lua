-- pwntester/octo.nvim: GitHub issues and pull requests. Needs an authenticated `gh` (gh auth login).
-- Keys: <leader>goi issues, gop pull requests, goc create a pull request, gos search. Octo's own buffer keys sit on
-- <localleader> (\); which-key lists them. Moved off Ctrl keys that hide built-ins (<C-r> redo, <C-y>/<C-e> scroll,
-- <C-o> jump back, <C-f> page down, <C-x>/<C-a> decrement/increment) or tmux's prefix <C-b>: \B open in the browser,
-- \y copy the URL, \Y copy the commit SHA, \R reload; workflow runs \rr rerun, \rf rerun failed, \x cancel; review
-- submit window \a approve, \m comment, \r request changes, <C-c> close. Octo's pickers: <A-b> browser, <A-y> URL,
-- <A-e> SHA, <A-o> check out, <A-M> merge (shifted, so a merge takes a deliberate chord).
local function keys(map) -- { action = lhs } to octo's { action = { lhs = lhs } }; deep merge keeps octo's own descs
	local out = {}
	for action, lhs in pairs(map) do
		out[action] = { lhs = lhs }
	end
	return out
end

local browse = { open_in_browser = "<localleader>B", copy_url = "<localleader>y" }
return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<leader>goi", "<cmd>Octo issue list<cr>", desc = "Issues" },
		{ "<leader>gop", "<cmd>Octo pr list<cr>", desc = "Pull requests" },
		{ "<leader>goc", "<cmd>Octo pr create<cr>", desc = "Create pull request" },
		{ "<leader>gos", "<cmd>Octo search<cr>", desc = "Search" },
	},
	opts = {
		use_local_fs = true, -- read files of a checked-out PR from disk
		picker = "snacks",
		picker_config = {
			mappings = keys({
				open_in_browser = "<A-b>",
				copy_url = "<A-y>",
				copy_sha = "<A-e>",
				checkout_pr = "<A-o>",
				merge_pr = "<A-M>",
			}),
		},
		mappings = {
			issue = keys(vim.tbl_extend("force", browse, { reload = "<localleader>R" })),
			pull_request = keys(
				vim.tbl_extend("force", browse, { reload = "<localleader>R", copy_sha = "<localleader>Y" })
			),
			discussion = keys(browse),
			release = keys({ open_in_browser = "<localleader>B" }),
			repo = keys({ open_in_browser = "<localleader>B" }),
			review_diff = keys({ copy_sha = "<localleader>Y" }),
			runs = keys(vim.tbl_extend("force", browse, {
				refresh = "<localleader>R",
				rerun = "<localleader>rr",
				rerun_failed = "<localleader>rf",
				cancel = "<localleader>x",
			})),
			submit_win = keys({
				approve_review = "<localleader>a",
				comment_review = "<localleader>m",
				request_changes = "<localleader>r",
			}),
		},
	},
	config = function(_, opts)
		if require("utils.core").warn_if_missing_exec("gh", "Octo", "Install GitHub CLI and run 'gh auth login'.") then
			require("octo").setup(opts) -- setup spawns gh at once and raises when it is missing
		end
	end,
}
