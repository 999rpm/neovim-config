-- nvim-neotest/neotest: run tests and see results inline, without leaving the buffer. Uses the
-- jest adapter (nvim-neotest/neotest-jest, listed as a dependency below).
return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-neotest/neotest-jest",
	},
	keys = {
		{
			"<leader>Tr",
			function()
				require("neotest").run.run()
			end,
			desc = "Run Nearest Test",
		},
		{
			"<leader>Tf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Run File Tests",
		},
		{
			"<leader>Ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Toggle Summary",
		},
		{
			"<leader>To",
			function()
				require("neotest").output.open({ enter = true })
			end,
			desc = "Show Test Output",
		},
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-jest")({
					jestCommand = "npm test --",
				}),
			},
		})
	end,
}
