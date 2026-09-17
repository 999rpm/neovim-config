-- linrongbin16/gitlinker.nvim: permalink to the current line on the remote host (<leader>gy copies, <leader>gY opens).
return {
	"linrongbin16/gitlinker.nvim",
	cmd = "GitLink",
	opts = {},
	keys = {
		{ "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "x" }, desc = "Copy Git Link" },
		{ "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "x" }, desc = "Open Git Link" },
	},
}
