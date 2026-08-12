-- nvim-neotest/neotest: run tests and see results inline, without leaving the buffer. Uses the
-- jest adapter (nvim-neotest/neotest-jest, listed as a dependency below).
--
-- antoinemadec/FixCursorHold.nvim (below) looks like it should be obsolete — the performance
-- bug it originally patched (small CursorHold delays writing the swap file 10x/sec) really was
-- fixed in Neovim core years ago. Checked rather than assumed, though: per the plugin author's
-- own clarification (antoinemadec/FixCursorHold.nvim#13, referenced from nvim-neotest/neotest's
-- own README), it still does a second, unrelated job core has no equivalent for — decoupling
-- CursorHold's delay from the single global 'updatetime', which neotest needs so its own
-- polling frequency doesn't also drag every other updatetime-driven thing (swap-file writes
-- included) along with it. Still a real dependency, not legacy cruft.
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
