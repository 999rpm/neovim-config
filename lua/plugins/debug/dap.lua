-- mfussenegger/nvim-dap: debug adapter protocol client — adapters, language configurations,
-- the `<leader>D*` keymap namespace, breakpoint signs, and the fzf/telescope picker bridge.
-- The UI (nvim-dap-ui) and Python support (nvim-dap-python) live in their own
-- plugins/debug/dap-ui.lua / dap-python.lua; debug-adapter *binaries* are kept installed via
-- mason-nvim-dap.nvim, configured in plugins/lsp/mason.lua alongside the other Mason installers.
-- Every adapter below points at its Mason-installed binary under stdpath("data")/mason/... —
-- same pattern for JS, C/C++/Rust, and Haskell, so none of them depend on the binary being on
-- the shell's own $PATH.
--
-- ╭──────────────────────────────────────────────────────────────────╮
-- │ TUTORIAL — debugging a Python file end to end, first time        │
-- │                                                                  │
-- │  1. Open a .py file, put the cursor on a line, press <leader>Db. │
-- │     A sign appears in the gutter at that line (colours: see the  │
-- │     `signs`/`set_dap_highlights` below — red circle = normal     │
-- │     breakpoint). No sign appearing = the breakpoint wasn't set;  │
-- │     don't go to step 2 yet, see "If nothing shows up" below.     │
-- │  2. Press <leader>Dc (Continue). This STARTS the session and     │
-- │     runs until the FIRST breakpoint it hits — if no breakpoint   │
-- │     is in the code path actually executed, the program just      │
-- │     runs to completion and the UI closes as fast as it opened.   │
-- │     That's correct behaviour, not a bug: Continue resumes/runs,  │
-- │     it doesn't pause on its own without something to stop it.    │
-- │  3. When it stops, nvim-dap-ui (dap-ui.lua) opens automatically: │
-- │     Scopes (current variables), Breakpoints, Stacks (call        │
-- │     stack), Watches, and a REPL panel — no manual toggle needed, │
-- │     it's wired to open on session-start/close on session-end.    │
-- │  4. Step through with <leader>Di (Into a function call),         │
-- │     <leader>Do (Over — run the line without diving into calls),  │
-- │     <leader>DO (Out — finish the current function, return to     │
-- │     caller). <F5>/<F10>/<F11>/<F12> do the same four things, if  │
-- │     that muscle memory is more familiar from another editor.     │
-- │  5. <leader>Dt (Terminate) ends the session early; otherwise it  │
-- │     ends on its own when the program finishes.                   │
-- │  6. <leader>Du toggles the dap-ui panels without touching the    │
-- │     session; <leader>Dr opens the REPL alone to evaluate         │
-- │     expressions in the current paused context.                   │
-- │                                                                  │
-- │  If nothing shows up at step 1: this was a real, confirmed bug   │
-- │  in this exact config until this pass (breakpoint sign `text`    │
-- │  fields were empty strings — fixed below, with colour added).    │
-- │  If it's happening again, check `:sign list` for `DapBreakpoint` │
-- │  — an empty `text=` there means the icon itself is the problem,  │
-- │  not the breakpoint logic.                                       │
-- │                                                                  │
-- │  If <leader>Dc itself errors with "Executable ... not found":    │
-- │  that's Mason, not this file — see utils.warn_if_missing_mason_  │
-- │  bin()'s call sites below and in dap-python.lua for what to      │
-- │  check (`:Mason`, `:MasonLog`, `:MasonInstall <name>`).          │
-- ╰──────────────────────────────────────────────────────────────────╯
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
		local utils = require("utils")

		------------------------------------------------------------------
		-- Signs (nf-fa, color-linked via highlights)
		------------------------------------------------------------------
		-- nvim-dap ships no default signs at all (confirmed against its own source: sign_define
		-- is entirely the user's responsibility) - each one below gets its own highlight group,
		-- defined right after, so breakpoint states are colour-coded rather than all one colour.
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

		-- Colours for the signs above - nvim-dap defines no default highlights for these group
		-- names either (same as the signs themselves), so without this every glyph would render
		-- in whatever "Normal"-ish colour happens to be nearby, defeating the point of having
		-- distinct signs per state. Linked (not hardcoded hex) so they follow the active theme;
		-- re-applied on every colorscheme switch by the ColorScheme autocmd in autocmds.lua.
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
			group = require("utils").augroup("dap-highlights"),
			callback = set_dap_highlights,
		})

		------------------------------------------------------------------
		-- JavaScript / TypeScript / React (Node)
		------------------------------------------------------------------
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

		------------------------------------------------------------------
		-- C / C++ / Rust
		------------------------------------------------------------------
		-- Standard codelldb server-mode adapter: Mason exposes the installed binary as a
		-- `codelldb` shim under its own bin dir, matching debugpy_path's/js-debug-adapter's own
		-- `stdpath("data") .. "/mason/..."` pattern elsewhere in this config.
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
		dap.configurations.c = dap.configurations.cpp
		dap.configurations.rust = dap.configurations.cpp

		------------------------------------------------------------------
		-- Haskell
		------------------------------------------------------------------
		-- Adapter/config shape is mfussenegger/nvim-dap's own documented example (its wiki's
		-- "Debug Adapter installation" page) verbatim, with `command` pointed at the
		-- Mason-installed binary instead of assuming it's on $PATH, matching codelldb above.
		-- `ghciCmd` assumes a Stack project -- for cabal, change it to something like
		-- `"cabal repl TARGET --repl-options=-fprint-evld-with-show"` and replace TARGET with
		-- the actual executable/library/test-suite stanza name from the .cabal file; this is
		-- inherently per-project, the same way dap.configurations.cpp's `program` above
		-- prompts per-run rather than hardcoding a path.
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
