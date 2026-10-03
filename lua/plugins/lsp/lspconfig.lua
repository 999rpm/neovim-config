-- neovim/nvim-lspconfig: server definitions, started through vim.lsp.config/vim.lsp.enable. Mason installs the binaries
-- (mason.lua); rust-analyzer belongs to rustaceanvim.lua.
-- Built-in LSP keys, kept as they are: K hover, grn rename (inc-rename preview), gra code action, grx code lens,
-- grr references, gri implementation, grt type definition, gO document symbols, <C-s> signature help in insert mode.
-- Built-in diagnostic keys, also kept: ]d/[d next/previous, ]D/[D last/first, <C-w>d float. Floats take 'winborder'.
-- Added per buffer, only where an attached server answers them: gd definition, gD declaration, <C-k> signature help
-- (normal mode); everywhere a server attaches: <leader>lwa/lwr/lwl add, remove and list workspace folders.
-- Diagnostics: tiny-inline-diagnostic.lua draws the cursor line's messages, mappings.lua holds <leader>df/db/dw.
return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" }, -- off the startup path; the servers still attach before the first FileType
	dependencies = { "b0o/schemastore.nvim" }, -- JSON/YAML schema catalog for jsonls and yamlls
	config = function()
		local core = require("utils.core")

		vim.diagnostic.config({
			update_in_insert = false,
			severity_sort = true,
			float = {
				source = "if_many", -- show the source only when several servers report on one line
				max_height = 20, -- a long diagnostic message cannot take over the screen
				max_width = 120,
			},
			underline = {
				severity = vim.diagnostic.severity.ERROR, -- errors only, so warnings and hints stay quiet
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰃤 ",
					[vim.diagnostic.severity.WARN] = "󰀦 ",
					[vim.diagnostic.severity.HINT] = "󰌵 ",
					[vim.diagnostic.severity.INFO] = "󰭷 ",
				},
			},
			virtual_lines = false, -- tiny-inline-diagnostic.lua draws the cursor line's diagnostics instead
			virtual_text = false, -- the same; left on, both would draw
		})

		pcall(require, "blink.cmp") -- loads blink, whose plugin file merges its completion capabilities into vim.lsp.config("*")

		vim.api.nvim_create_autocmd("LspAttach", {
			group = core.augroup("lsp-attach"),
			nested = true,
			desc = "999rpm: configure buffer keymaps and behaviour on LSP attach",
			callback = function(event)
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if not client then
					return
				end

				local function map(keys, func, desc, mode)
					vim.keymap.set(mode or "n", keys, func, { buf = event.buf, desc = "LSP: " .. desc, silent = true })
				end

				if client:supports_method("textDocument/definition", event.buf) then -- render-markdown's and crates.nvim's in-process servers answer none, so gd stays built-in there
					map("gd", function()
						vim.lsp.buf.definition({
							on_list = function(options)
								local unique, seen = {}, {}
								for _, loc in ipairs(options.items) do
									local key = loc.filename .. loc.lnum -- filename plus line identifies one definition
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
									vim.cmd("silent! lfirst") -- silent: an empty list is not an error
								end
							end,
						})
					end, "Go to definition")
				end

				if client:supports_method("textDocument/declaration", event.buf) then
					map("gD", vim.lsp.buf.declaration, "Go to declaration") -- elsewhere gD stays the built-in file-global declaration search
				end

				if client:supports_method("textDocument/rename", event.buf) then
					vim.keymap.set("n", "grn", function()
						return ":IncRename " .. vim.fn.expand("<cword>")
					end, { buf = event.buf, expr = true, silent = true, desc = "LSP: Rename" })
				end

				if client:supports_method("textDocument/signatureHelp", event.buf) then
					map("<C-k>", vim.lsp.buf.signature_help, "Signature help")
				end

				map("<leader>lwa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
				map("<leader>lwr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
				map("<leader>lwl", function()
					vim.print(vim.lsp.buf.list_workspace_folders())
				end, "List workspace folders")

				if client.name == "ruff" then
					client.server_capabilities.hoverProvider = false -- basedpyright answers hover for Python
				end
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
						format = { enable = false }, -- stylua formats Lua through conform.lua
					},
				},
			},
			ts_ls = {
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "literal",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false, -- no hint on foo(name: name)
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
						schemaStore = { enable = false, url = "" }, -- off, so the catalog below is the only source
						schemas = require("schemastore").yaml.schemas(),
					},
				},
			},
			jsonls = {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			},
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
						publishDiagnostics = { tagSupport = { valueSet = { 2 } } }, -- greys out unreachable code
					},
				},
			},
			ruff = {
				init_options = {
					settings = { organizeImports = true }, -- pairs with basedpyright's disableOrganizeImports above
				},
			},
			tailwindcss = {},
			emmet_language_server = {},
			taplo = {},
			neocmake = {},
			bashls = {},
			eslint = {},
			html = {},
			cssls = {},
			dockerls = {},
			docker_compose_language_service = {},
			markdown_oxide = {
				root_markers = { ".moxide.toml", "logseq", ".obsidian", ".git" }, -- a Logseq graph keeps its logseq/ folder at the root
				capabilities = {
					workspace = { didChangeWatchedFiles = { dynamicRegistration = true } }, -- upstream's README: pages created outside Neovim get indexed
				},
			},
			mdx_analyzer = {},
		}

		local external_servers = { -- toolchain-managed binaries Mason does not install: each starts once it is on $PATH
			gopls = {
				_exec = "gopls",
				settings = {
					gopls = {
						usePlaceholders = true,
						analyses = { unusedparams = true },
						staticcheck = true,
						gofumpt = true,
						hints = { compositeLiteralFields = true, parameterNames = true },
					},
				},
			},
			golangci_lint_ls = { _exec = "golangci-lint-langserver" },
			clangd = { _exec = "clangd" },
			hls = {
				_exec = "haskell-language-server-wrapper", -- ghcup builds hls against the installed GHC
				settings = {
					haskell = {
						formattingProvider = "ormolu",
						cabalFormattingProvider = "cabal-fmt",
					},
				},
			},
			sqls = { _exec = "sqls" },
			vimls = { _exec = "vim-language-server" },
		}

		local enabled = {}
		for name, opts in pairs(servers) do
			vim.lsp.config(name, opts)
			enabled[#enabled + 1] = name
		end
		for name, opts in pairs(external_servers) do
			local exec = opts._exec
			opts._exec = nil
			if core.executable(exec) then
				vim.lsp.config(name, opts)
				enabled[#enabled + 1] = name
			end
		end
		vim.lsp.enable(enabled) -- one call: each vim.lsp.enable() re-runs FileType over every open buffer
	end,
}
