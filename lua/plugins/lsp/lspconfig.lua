-- Language servers through vim.lsp.config/vim.lsp.enable. Mason installs the binaries (mason.lua); rust is rustaceanvim's.
-- Nvim 0.12's own LSP keys, kept as they are: K hover, grn rename (inc-rename preview), gra code action, grx code lens,
-- grr references, gri implementation, grt type definition, gO document symbols, <C-s> signature help in insert mode.
-- Nvim's own diagnostic keys, also kept: ]d/[d next/previous, ]D/[D last/first, <C-w>d float. Floats take 'winborder'.
-- Added here: gd definition, gD declaration, <C-k> signature help (normal), <leader>xf line diagnostics,
-- <leader>xb/<leader>xw diagnostics to quickfix (buffer/workspace), <leader>wa/wr/wf workspace folders.
-- Toggles for diagnostics (<leader>ox) and inlay hints (<leader>oh) live in snacks.lua.
return {
	"neovim/nvim-lspconfig",
	dependencies = { "b0o/schemastore.nvim" }, -- JSON/YAML schema catalog for jsonls and yamlls
	config = function()
		local utils = require("utils")

		utils.setup_rounded_virtual_lines() -- registers the virtual_lines_rounded handler used below

		vim.diagnostic.config({
			update_in_insert = false,
			severity_sort = true,
			float = {
				source = "if_many", -- show source only when multiple servers report on the same line
				max_height = 20, -- a long diagnostic message cannot take over the screen
				max_width = 120,
			},
			underline = {
				severity = vim.diagnostic.severity.ERROR, -- underline errors only, not warnings/hints
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰃤 ",
					[vim.diagnostic.severity.WARN] = "󰀦 ",
					[vim.diagnostic.severity.HINT] = "󰌵 ",
					[vim.diagnostic.severity.INFO] = "󰭷 ",
				},
			},
			virtual_lines = false, -- replaced by the rounded handler below
			virtual_lines_rounded = { current_line = true }, -- cursor line only, with a rounded corner (utils.lua)
			virtual_text = false, -- would double up with the lines above
		})

		vim.keymap.set(
			"n",
			"<leader>xw",
			vim.diagnostic.setqflist, -- every open buffer's diagnostics; opens the qf list by default
			{ desc = "Diagnostics to Quickfix (Workspace)" }
		)
		vim.keymap.set("n", "<leader>xb", function()
			local items = vim.diagnostic.toqflist(vim.diagnostic.get(0)) -- current buffer only
			vim.fn.setqflist({}, " ", { title = "Diagnostics", items = items })
			vim.cmd.copen()
		end, { desc = "Diagnostics to Quickfix (Buffer)" })

		vim.lsp.config("*", {
			capabilities = utils.get_lsp_capabilities(),
		}) -- no debounce_text_changes override: anything above the default delays every server's view of an edit, rustaceanvim included

		local hl_group = utils.augroup("lsp-highlight") -- one entry per buffer, so LspDetach can clear it even when no client asked for highlights

		vim.api.nvim_create_autocmd("LspAttach", {
			group = utils.augroup("lsp-attach"),
			nested = true,
			desc = "999rpm: configure buffer keymaps and behaviour on LSP attach",
			callback = function(event)
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if not client then
					return
				end

				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buf = event.buf, desc = "LSP: " .. desc, silent = true })
				end

				map("gd", function()
					vim.lsp.buf.definition({
						on_list = function(options)
							local unique = {}
							local seen = {}
							for _, loc in ipairs(options.items) do
								local key = loc.filename .. loc.lnum -- filename+line uniquely identifies one definition
								if not seen[key] then
									seen[key] = true
									table.insert(unique, loc)
								end
							end
							options.items = unique
							vim.fn.setloclist(0, {}, " ", options)
							if #unique > 1 then
								vim.cmd.lopen()
							else
								vim.cmd("silent! lfirst") -- silent: no error if list is empty
							end
						end,
					})
				end, "Go to Definition")

				if client:supports_method("textDocument/declaration", event.buf) then
					map("gD", vim.lsp.buf.declaration, "Go to Declaration") -- only where a server answers it; elsewhere gD stays Nvim's own file-global declaration search
				end

				if client:supports_method("textDocument/rename", event.buf) then
					vim.keymap.set("n", "grn", function()
						return ":IncRename " .. vim.fn.expand("<cword>")
					end, { buf = event.buf, expr = true, silent = true, desc = "LSP: Rename" })
				end

				map("<C-k>", vim.lsp.buf.signature_help, "Signature Help")

				map("<leader>wa", vim.lsp.buf.add_workspace_folder, "Workspace Add Folder") -- add dir to workspace
				map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Workspace Remove Folder") -- remove dir from workspace
				map("<leader>wf", function()
					vim.print(vim.lsp.buf.list_workspace_folders())
				end, "Workspace List Folders") -- print workspace folder list to command line

				map("<leader>xf", vim.diagnostic.open_float, "Line Diagnostics") -- ergonomic alias for built-in <C-w>d

				if client:supports_method("textDocument/documentHighlight", event.buf) and not vim.b[event.buf].user_lsp_highlight then
					vim.b[event.buf].user_lsp_highlight = true
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						desc = "999rpm: highlight other occurrences of the symbol under the cursor",
						buf = event.buf,
						group = hl_group,
						callback = vim.lsp.buf.document_highlight, -- highlight all occurrences of symbol under cursor
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						desc = "999rpm: clear symbol-occurrence highlights once the cursor moves",
						buf = event.buf,
						group = hl_group,
						callback = vim.lsp.buf.clear_references, -- clear highlights when cursor moves away
					})
				end

				if client.name == "ruff" then
					client.server_capabilities.hoverProvider = false -- let basedpyright handle hover for Python
				end
			end,
		})

		vim.api.nvim_create_autocmd("LspDetach", {
			group = utils.augroup("lsp-detach"),
			desc = "999rpm: drop reference highlights when a client detaches",
			callback = function(event)
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({ group = hl_group, buf = event.buf })
				vim.b[event.buf].user_lsp_highlight = nil -- let the next attach re-arm the pair above
			end,
		})

		vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", { desc = "Show LSP info" }) -- nvim-lspconfig defines no commands on 0.12; :lsp covers the rest
		vim.api.nvim_create_user_command("LspLog", function()
			vim.cmd(string.format("edit %s", vim.lsp.log.get_filename()))
		end, { desc = "Open LSP log file" })
		vim.api.nvim_create_user_command(
			"LspRestart",
			"lsp restart <args>", -- forwards client names through to the built-in rather than always restarting everything
			{ nargs = "*", desc = "Alias for :lsp restart" }
		)

		local servers = {
			lua_ls = {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = { checkThirdParty = false }, -- the vim.* library comes from lazydev.lua
						completion = { workspaceWord = true, callSnippet = "Both" },
						hint = {
							enable = true,
							setType = false,
							paramType = true,
							paramName = "Disable",
							semicolon = "Disable",
							arrayIndex = "Disable",
						},
						doc = { privateName = { "^_" } },
						type = { castNumberToInteger = true },
						diagnostics = {
							disable = { "incomplete-signature-doc", "trailing-space" },
							groupSeverity = { strong = "Warning", strict = "Warning" },
							groupFileStatus = {
								ambiguity = "Opened",
								await = "Opened",
								codestyle = "None",
								duplicate = "Opened",
								global = "Opened",
								luadoc = "Opened",
								redefined = "Opened",
								strict = "Opened",
								strong = "Opened",
								["type-check"] = "Opened",
								unbalanced = "Opened",
								unused = "Opened",
							},
							unusedLocalExclude = { "_*" },
						},
						format = { enable = false },
					},
				},
			},
			ts_ls = {
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "literal",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false, -- don't hint `foo(name: name)` when the arg already says it
							includeInlayFunctionParameterTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				},
			},
			yamlls = {
				settings = {
					yaml = {
						keyOrdering = false,
						schemaStore = {
							enable = false,
							url = "",
						},
						schemas = require("schemastore").yaml.schemas(),
					},
				},
			},
			tailwindcss = {},
			emmet_language_server = {},
			taplo = {},
			neocmake = {},
			bashls = {},
			jsonls = {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			},
			eslint = {},
			html = {},
			cssls = {},
			basedpyright = {
				settings = {
					basedpyright = {
						disableOrganizeImports = true, -- ruff owns import sorting, see `ruff` below
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
							typeCheckingMode = "standard",
						},
					},
				},
				capabilities = {
					textDocument = {
						publishDiagnostics = {
							tagSupport = { valueSet = { 2 } },
						},
					},
				},
			},
			ruff = {
				init_options = {
					settings = {
						organizeImports = true, -- pairs with basedpyright's disableOrganizeImports above
					},
				},
			},
			dockerls = {},
			docker_compose_language_service = {},
			markdown_oxide = {},
			mdx_analyzer = {},
		}

		local external_servers = {
			gopls = {
				_exec = "gopls",
				_optional = true, -- starts once gopls is on $PATH; no warning on machines without Go
				settings = {
					gopls = {
						usePlaceholders = true,
						analyses = { unusedparams = true },
						staticcheck = true,
						gofumpt = true,
						hints = {
							compositeLiteralFields = true,
							parameterNames = true,
						},
					},
				},
			},
			golangci_lint_ls = { _exec = "golangci-lint-langserver", _optional = true },
			clangd = { _exec = "clangd", _optional = true },
			hls = {
				_exec = "haskell-language-server-wrapper",
				_optional = true, -- ghcup manages hls against the installed GHC, so Mason does not install it
				settings = {
					haskell = {
						formattingProvider = "ormolu",
						cabalFormattingProvider = "cabal-fmt",
					},
				},
			},
			sqls = { _exec = "sqls", _optional = true },
			vimls = { _exec = "vim-language-server", _optional = true },
		}

		for name, opts in pairs(servers) do
			vim.lsp.config(name, opts)
			vim.lsp.enable(name)
		end

		for name, opts in pairs(external_servers) do
			local exec = opts._exec
			local optional = opts._optional
			opts._exec = nil
			opts._optional = nil
			if utils.executable(exec) then
				vim.lsp.config(name, opts)
				vim.lsp.enable(name)
			elseif not optional then
				vim.schedule(function()
					vim.notify(
						string.format("Executable '%s' not found, so server '%s' will not start", exec, name),
						vim.log.levels.WARN,
						{ title = "LSP" }
					)
				end)
			end
		end
	end,
}
