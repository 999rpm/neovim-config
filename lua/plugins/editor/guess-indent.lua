-- nmac427/guess-indent.nvim: detects indentation from the file and sets the buffer options to match.
return {
	"nmac427/guess-indent.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {},
}
