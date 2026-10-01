-- nvim-neotest/neotest: run tests from the editor. Adapters: jest (JS/TS), pytest through neotest-python (debugging runs
-- through dap-python.lua) and rustaceanvim's own cargo adapter.
-- Keys: <leader>Tr nearest test, Tf this file, Td debug the nearest test, Ts summary, To output.
-- Summary window: r run, o output, m mark, i expand, d debug, w watch.
return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"nvim-neotest/neotest-jest",
		"nvim-neotest/neotest-python",
	},
	keys = {
		{
			"<leader>Tr",
			function()
				require("neotest").run.run()
			end,
			desc = "Run nearest test",
		},
		{
			"<leader>Tf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Run tests in file",
		},
		{
			"<leader>Td",
			function()
				require("neotest").run.run({ strategy = "dap" })
			end,
			desc = "Debug nearest test",
		},
		{
			"<leader>Ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Toggle summary",
		},
		{
			"<leader>To",
			function()
				require("neotest").output.open({ enter = true })
			end,
			desc = "Show output",
		},
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-jest")({
					jestCommand = "npm test --",
				}),
				require("neotest-python")({
					runner = "pytest",
					dap = { justMyCode = false },
				}), -- interpreter: $VIRTUAL_ENV, else a venv folder in the project (uv's .venv), else python3 on $PATH
				require("rustaceanvim.neotest"),
			},
		})
	end,
}
