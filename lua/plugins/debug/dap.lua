-- mfussenegger/nvim-dap: debugger client, adapters and launch configurations under <leader>D.
-- Adapters come from Mason: codelldb (C, C++, Rust), js-debug-adapter (JS, TS), haskell-debug-adapter; python is dap-python.lua.
return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",

	dependencies = {
		"rcarriga/nvim-dap-ui", -- full config in plugins/debug/dap-ui.lua; listed here for install/load ordering only
		"mfussenegger/nvim-dap-python", -- full config in plugins/debug/dap-python.lua; same reasoning
	},

	keys = {
		{
			"<leader>Db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle breakpoint",
		},
		{
			"<leader>DB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Conditional breakpoint",
		},
		{
			"<leader>DL",
			function()
				require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: "))
			end,
			desc = "Log point",
		},
		{
			"<leader>Dx",
			function()
				require("dap").clear_breakpoints()
			end,
			desc = "Clear breakpoints",
		},
		{
			"<leader>Dp",
			function()
				require("dap").list_breakpoints(true)
			end,
			desc = "List breakpoints (quickfix)",
		},
		{
			"<leader>Dc",
			function()
				require("dap").continue()
			end,
			desc = "Continue or start",
		},
		{
			"<leader>DC",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Run to cursor",
		},
		{
			"<leader>Dl",
			function()
				require("dap").run_last()
			end,
			desc = "Run last configuration",
		},
		{
			"<leader>Di",
			function()
				require("dap").step_into()
			end,
			desc = "Step into",
		},
		{
			"<leader>Do",
			function()
				require("dap").step_over()
			end,
			desc = "Step over",
		},
		{
			"<leader>DO",
			function()
				require("dap").step_out()
			end,
			desc = "Step out",
		},
		{
			"<leader>DP",
			function()
				require("dap").pause()
			end,
			desc = "Pause",
		},
		{
			"<leader>Dt",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate",
		},
		{
			"<leader>Dr",
			function()
				require("dap").repl.toggle()
			end,
			desc = "REPL",
		},
		{
			"<leader>Dh",
			function()
				require("dap.ui.widgets").hover()
			end,
			mode = { "n", "x" },
			desc = "Hover value",
		},
		{
			"<leader>Ds",
			function()
				require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes)
			end,
			desc = "Scopes",
		},
		{
			"<leader>De",
			function()
				require("dapui").eval()
			end,
			mode = { "n", "x" },
			desc = "Evaluate",
		},
		{
			"<leader>Du",
			function()
				require("dapui").toggle()
			end,
			desc = "Toggle UI",
		},
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "Debug: continue or start",
		}, -- desc so which-key and <leader>sk name them
		{
			"<F10>",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: step over",
		},
		{
			"<F11>",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: step into",
		},
		{
			"<F12>",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: step out",
		},
	},
	config = function()
		local dap = require("dap")
		local utils = require("utils")

		local signs = {
			DapBreakpoint = { text = "", texthl = "DapBreakpoint" },
			DapBreakpointCondition = { text = "", texthl = "DapBreakpointCondition" },
			DapLogPoint = { text = "", texthl = "DapLogPoint" },
			DapStopped = {
				text = " ",
				texthl = "DapStopped",
				linehl = "DapStoppedLine",
			},
			DapBreakpointRejected = { text = "", texthl = "DapBreakpointRejected" },
		}

		for name, sign in pairs(signs) do
			vim.fn.sign_define(name, sign)
		end

		local function set_dap_highlights()
			vim.api.nvim_set_hl(0, "DapBreakpoint", { link = "DiagnosticError" })
			vim.api.nvim_set_hl(0, "DapBreakpointCondition", { link = "DiagnosticWarn" })
			vim.api.nvim_set_hl(0, "DapLogPoint", { link = "DiagnosticInfo" })
			vim.api.nvim_set_hl(0, "DapStopped", { link = "DiagnosticOk" })
			vim.api.nvim_set_hl(0, "DapStoppedLine", { link = "CursorLine" })
			vim.api.nvim_set_hl(0, "DapBreakpointRejected", { link = "DiagnosticHint" })
		end
		set_dap_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", {
			desc = "999rpm: re-link Dap* sign highlights after a theme switch",
			group = require("utils").augroup("dap-highlights"),
			callback = set_dap_highlights,
		})

		local js_debug_server = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
		utils.warn_if_missing_mason_bin(js_debug_server, "js-debug-adapter")

		dap.adapters["pwa-node"] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				args = {
					js_debug_server,
					"${port}",
				},
			},
		}

		for _, ft in ipairs({
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
		}) do
			dap.configurations[ft] = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch Node",
					program = "${file}",
					cwd = "${workspaceFolder}",
					runtimeExecutable = "node",
				},
			}
		end

		local codelldb_bin = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
		utils.warn_if_missing_mason_bin(codelldb_bin, "codelldb")

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = codelldb_bin,
				args = { "--port", "${port}" },
			},
		}

		dap.configurations.cpp = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
			},
		}
		dap.configurations.c = vim.deepcopy(dap.configurations.cpp) -- deepcopy, not assignment: a shared table makes one language's discovered runnables appear in the other's picker
		dap.configurations.rust = vim.deepcopy(dap.configurations.cpp)

		local haskell_debug_bin = vim.fn.stdpath("data") .. "/mason/bin/haskell-debug-adapter"
		utils.warn_if_missing_mason_bin(haskell_debug_bin, "haskell-debug-adapter")

		dap.adapters.haskell = {
			type = "executable",
			command = haskell_debug_bin,
			args = { "--hackage-version=0.0.33.0" },
		}
		dap.configurations.haskell = {
			{
				type = "haskell",
				request = "launch",
				name = "Debug",
				workspace = "${workspaceFolder}",
				startup = "${file}",
				stopOnEntry = true,
				logFile = vim.fn.stdpath("data") .. "/haskell-dap.log",
				logLevel = "WARNING",
				ghciEnv = vim.empty_dict(),
				ghciPrompt = "λ: ",
				ghciInitialPrompt = "λ: ",
				ghciCmd = "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show",
			},
		}
	end,
}
