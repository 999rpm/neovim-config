-- mfussenegger/nvim-dap: debug adapter protocol client — adapters, language configurations,
-- the `<leader>D*` keymap namespace, breakpoint signs, and the fzf/telescope picker bridge.
-- The UI (nvim-dap-ui) and Python support (nvim-dap-python) live in their own
-- plugins/debug/dap-ui.lua / dap-python.lua; debug-adapter *binaries* are kept installed via
-- mason-nvim-dap.nvim, configured in plugins/lsp/mason.lua alongside the other Mason installers.
return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",

	dependencies = {
		"rcarriga/nvim-dap-ui", -- full config in plugins/debug/dap-ui.lua; listed here for install/load ordering only
		"mfussenegger/nvim-dap-python", -- full config in plugins/debug/dap-python.lua; same reasoning
	},

	------------------------------------------------------------------
	-- Keymaps (<leader>D — Debug Namespace)
	------------------------------------------------------------------
	keys = {
		{ "<leader>Db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle Breakpoint" },
		{ "<leader>Dc", "<cmd>DapContinue<cr>", desc = "Continue / Start" },
		{ "<leader>Di", "<cmd>DapStepInto<cr>", desc = "Step Into" },
		{ "<leader>Do", "<cmd>DapStepOver<cr>", desc = "Step Over" },
		{ "<leader>DO", "<cmd>DapStepOut<cr>", desc = "Step Out" },
		{ "<leader>Dt", "<cmd>DapTerminate<cr>", desc = "Terminate" },
		{ "<leader>Du", "<cmd>lua require('dapui').toggle()<cr>", desc = "Toggle UI" },
		{
			"<leader>Dr",
			function()
				require("dap").repl.open()
			end,
			desc = "Open DAP REPL",
		},

		{ "<leader>Dp", "<cmd>lua require('dap').extensions.pick()<cr>", desc = "Pickers" },

		-- Muscle memory
		{ "<F5>", "<cmd>DapContinue<cr>" },
		{ "<F10>", "<cmd>DapStepOver<cr>" },
		{ "<F11>", "<cmd>DapStepInto<cr>" },
		{ "<F12>", "<cmd>DapStepOut<cr>" },
	},

	config = function()
		local dap = require("dap")

		------------------------------------------------------------------
		-- Signs (nf-fa, color-linked via highlights)
		------------------------------------------------------------------
		local signs = {
			DapBreakpoint = { text = "", texthl = "DapBreakpoint" },
			DapBreakpointCondition = { text = "", texthl = "DapBreakpointCondition" },
			DapLogPoint = { text = "", texthl = "DapLogPoint" },
			DapStopped = {
				text = "",
				texthl = "DapStopped",
				linehl = "DapStoppedLine",
			},
			DapBreakpointRejected = { text = "", texthl = "DapBreakpointRejected" },
		}

		for name, sign in pairs(signs) do
			vim.fn.sign_define(name, sign)
		end

		------------------------------------------------------------------
		-- JavaScript / TypeScript / React (Node)
		------------------------------------------------------------------
		dap.adapters["pwa-node"] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				args = {
					vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
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

		------------------------------------------------------------------
		-- C / C++ / Rust
		------------------------------------------------------------------
		-- Standard codelldb server-mode adapter: Mason exposes the installed binary as a
		-- `codelldb` shim under its own bin dir, matching debugpy_path's/js-debug-adapter's own
		-- `stdpath("data") .. "/mason/..."` pattern elsewhere in this config.
		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
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
		dap.configurations.c = dap.configurations.cpp
		dap.configurations.rust = dap.configurations.cpp

		------------------------------------------------------------------
		-- Pickers (FZF primary, Telescope fallback)
		------------------------------------------------------------------
		dap.extensions = {}
		dap.extensions.pick = function()
			if pcall(require, "fzf-lua") then
				require("fzf-lua").dap_breakpoints()
			elseif pcall(require, "telescope") then
				require("telescope").extensions.dap.commands()
			end
		end
	end,
}
