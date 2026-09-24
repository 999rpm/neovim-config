-- pwntester/octo.nvim: GitHub issues and pull requests. Needs an authenticated `gh` (gh auth login).
-- Keys: <leader>goi issues, gop pull requests, goc create a pull request, gos search. Octo's own buffer keys sit on
-- <localleader> (\); <C-b> opens the item in the browser, <C-y> copies its URL.
return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-mini/mini.nvim" },
	keys = {
		{ "<leader>goi", "<cmd>Octo issue list<cr>", desc = "Issues" },
		{ "<leader>gop", "<cmd>Octo pr list<cr>", desc = "Pull requests" },
		{ "<leader>goc", "<cmd>Octo pr create<cr>", desc = "Create pull request" },
		{ "<leader>gos", "<cmd>Octo search<cr>", desc = "Search" },
	},
	opts = {
		use_local_fs = true, -- read files of a checked-out PR from disk
		picker = "snacks",
	},
	config = function(_, opts)
		require("utils").warn_if_missing_exec("gh", "Octo", "Install GitHub CLI and run 'gh auth login'.")
		require("octo").setup(opts)
	end,
}
