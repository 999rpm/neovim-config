-- linrongbin16/gitlinker.nvim: generate a permalink (pinned to the current commit SHA) to the
-- line/selection under the cursor on the repo's host (GitHub/GitLab/etc). Different from
-- autocmds.lua's right-click "Open in Web Browser" (`gx`, opens the file's CURRENT-branch page,
-- no line anchor) and plugins/ui/snacks.lua's `<leader>gb` (Snacks.gitbrowse, same "current
-- branch, no specific line" scope) — this one's for sharing a specific, permanent line link.
return {
	"linrongbin16/gitlinker.nvim",
	cmd = "GitLink",
	opts = {},
	keys = {
		{ "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "x" }, desc = "Copy Git Link" },
		{ "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "x" }, desc = "Open Git Link" },
	},
}
