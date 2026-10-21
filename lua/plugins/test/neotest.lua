-- nvim-neotest/neotest: run tests from the editor. Adapters: jest (JS/TS), pytest through neotest-python (debugging
-- runs through dap-python.lua) and rustaceanvim's own cargo adapter when rustaceanvim.lua is installed. Owns <leader>T
-- except Tc (rustaceanvim.lua).
return {
	"nvim-neotest/neotest",
	-- neotest's own keys in the summary window: <CR> expand, e expand all, r run, d debug, o output, O short output, i
	-- jump to the test, a attach, u stop, m mark, R run the marked, w watch, J/K next/previous failure, ? help.
	keys = {
		{
			"<leader>Tr",
			function()
				require("neotest").run.run()
			end,
			desc = "Run nearest test",
		}, -- n: the test around the cursor (r for run)
		{
			"<leader>Tf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Run tests in file",
		}, -- n: every test of this file
		{
			"<leader>Td",
			function()
				require("neotest").run.run({ strategy = "dap" })
			end,
			desc = "Debug nearest test",
		}, -- n: the nearest test under nvim-dap, breakpoints active
		{
			"<leader>Ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Toggle summary",
		}, -- n: the test tree with pass and fail marks
		{
			"<leader>To",
			function()
				require("neotest").output.open({ enter = true })
			end,
			desc = "Show output",
		}, -- n: the last run's output for the test under the cursor
	},
	config = function()
		local adapters = {
			require("neotest-jest")({
				jestCommand = "npm test --",
			}),
			require("neotest-python")({
				runner = "pytest",
				dap = { justMyCode = false },
			}), -- interpreter: $VIRTUAL_ENV, else a venv folder in the project (uv's .venv), else python3 on $PATH
		}
		local has_rust, rust = pcall(require, "rustaceanvim.neotest") -- rustaceanvim.lua may be removed; neotest works without it
		if has_rust then
			adapters[#adapters + 1] = rust
		end
		require("neotest").setup({ adapters = adapters })
	end,
}
