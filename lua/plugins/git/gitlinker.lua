-- linrongbin16/gitlinker.nvim: permalink to the current line on the remote host. Owns <leader>gy and <leader>gY.
return {
	"linrongbin16/gitlinker.nvim",
	cmd = "GitLink",
	opts = {},
	keys = {
		{ "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "x" }, desc = "Copy permalink" }, -- n/x: the web address of this line or the selected lines, to the clipboard (y for yank)
		{ "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "x" }, desc = "Open permalink" }, -- n/x: the same address opened in the browser
	},
}
