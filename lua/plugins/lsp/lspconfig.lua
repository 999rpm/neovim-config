-- LSP servers + diagnostics config, wired directly onto Nvim 0.11+'s native vim.lsp.config()/
-- vim.lsp.enable() — not the deprecated require("lspconfig").setup{} wrapper. This file still
-- depends on neovim/nvim-lspconfig for its bundled per-server default configs and the
-- lspconfig.util.root_pattern() helper a couple of servers below use.
--
-- Substantially adapted from jdhao/nvim-config <https://github.com/jdhao/nvim-config>
-- (lua/lsp_conf.lua, lua/lsp_utils.lua, lua/diagnostic-conf.lua, after/lsp/*.lua) — periodically
-- diffed against his live repo; utils.lua and mason.lua share this credit. Two settings were
-- sourced from elsewhere: `includeInlayParameterNameHintsWhenArgumentMatchesName`
-- (craftzdog/dotfiles-public) and the schemastore.nvim jsonls/yamlls integration
-- (xero/dotfiles).
--
-- Features: capabilities (blink.cmp + nvim-ufo folding via utils.get_lsp_capabilities()) ·
-- diagnostics (virtual_lines on the current line, signs, size-capped rounded floats,
-- <leader>xw/<leader>xb to quickfix) · gd de-dup for `local M.fn = function() end`-style Lua ·
-- document highlight on CursorHold · <leader>oh inlay-hint toggle, capability-gated ·
-- :LspFormat for an on-demand manual format (format-*on-save* is conform.lua's sole job, not
-- this file's — see plugins/lang-tools/conform.lua) · LSP progress echoed via nvim_echo ·
-- LspInfo/LspLog/LspRestart commands · Mason-managed servers (`servers` below) enabled
-- unconditionally, everything else (`external_servers`) gated on utils.executable() · Python
-- split cleanly between basedpyright (types) and ruff (imports + hover, with basedpyright's
-- own hover disabled in ruff's favour) · JSON/YAML schema validation via schemastore.nvim.
--
-- `servers` vs `external_servers`: `servers` assumes Mason already put the binary on $PATH
-- (kept in sync with mason.lua's `ensure_installed` — see that file's own note) and enables
-- unconditionally. `external_servers` is for anything better installed outside Mason — each
-- entry executable-checks itself (`_exec`) and only warns if missing when `_optional = false`.
-- `hls` (Haskell) is deliberately external rather than Mason-managed: haskell-language-server's
-- own install docs recommend ghcup directly, and Mason's package for it has a long history of
-- version-matching failures against a project's actual GHC — `ghcup install hls` (or your
-- distro's package) is the reliable path. See mason.lua for the tools that ARE Mason-managed
-- for Haskell (ormolu, haskell-debug-adapter).
return {
	"neovim/nvim-lspconfig",
	dependencies = { "b0o/schemastore.nvim" }, -- pure data (JSON/YAML schema catalog), no setup() of its own — see jsonls/yamlls below
	config = function()
		local utils = require("utils")

		local border_style = "rounded"

		vim.diagnostic.config({
			update_in_insert = false,
			severity_sort = true,
			float = {
				border = border_style,
				source = "if_many", -- show source only when multiple servers report on the same line
				max_height = 20, -- same cap as K/hover and <C-k>/signature-help below, so no float
				max_width = 120, -- can take over the screen on an unusually long diagnostic message
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
			virtual_lines = { current_line = true }, -- show inline detail for the line under cursor only
			virtual_text = false, -- disabled to avoid double-rendering with virtual_lines
		})

		-- Diagnostics aren't LSP-exclusive (nvim-lint or any other source can populate them
		-- too), so these two live here rather than inside the LspAttach callback below —
		-- adapted from jdhao's diagnostic-conf.lua onto this file's own <leader>x* namespace.
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
			flags = { debounce_text_changes = 500 },
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = utils.augroup("lsp-attach"),
			nested = true,
			desc = "Configure buffer keymaps and behaviour on LSP attach",
			callback = function(event)
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if not client then
					return
				end

				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buf = event.buf, desc = "LSP: " .. desc, silent = true })
				end

				-- ┌──────────────────────────────────────────────────────────────────┐
				-- │ Neovim's OWN keymaps/behaviour once a client attaches (0.11+, see │
				-- │ :help lsp-defaults). Don't re-map these below — change behaviour  │
				-- │ via vim.lsp.config() or vim.keymap.del() instead if ever needed.  │
				-- │                                                                  │
				-- │  Navigation:                                                     │
				-- │  gd       – definition   (CUSTOM below: de-dup + location list)  │
				-- │  <C-]>    – definition   via 'tagfunc' (automatic, no map needed)│
				-- │  <C-w>]   – definition   in a new horizontal split (same source) │
				-- │  <C-w>}   – definition   in the preview window (same source)     │
				-- │  grt      – type definition                    [global default]  │
				-- │  grr      – references (quickfix)              [global default]  │
				-- │  gri      – implementation (quickfix)          [global default]  │
				-- │  gO       – document symbols list              [global default]  │
				-- │  gx       – Nvim's own default: opens the path/URL under cursor, │
				-- │             no LSP needed; a server's documentLink adds          │
				-- │             link-awareness on top, e.g. gopls on an import path  │
				-- │                                                                  │
				-- │  Actions:                                                        │
				-- │  K        – hover documentation (CUSTOM below: border + size)    │
				-- │             — safe to override: default is only "K" as long as   │
				-- │             nothing else maps it, which is the case here         │
				-- │  grn      – rename symbol                      [global default]  │
				-- │  gra      – code action (normal + visual)      [global default]  │
				-- │  grx      – run code lens                      [global default]  │
				-- │  gq / gw  – format via 'formatexpr' (gw leaves the cursor alone) │
				-- │                                                                  │
				-- │  Signature help:                                                 │
				-- │  <C-k>    – signature help, normal mode        (CUSTOM below)    │
				-- │  <C-s>    – signature help, insert mode        (CUSTOM below)    │
				-- │  <C-S>    – signature help, insert mode        [global default,  │
				-- │             same byte as <C-s> in most terminals]                │
				-- │                                                                  │
				-- │  Also wired up automatically, no map involved: omnifunc is set   │
				-- │  to LSP completion the same way 'tagfunc'/'formatexpr' are —     │
				-- │  moot here since blink.cmp's own LSP source drives completion    │
				-- │  instead. Document colors are highlighted automatically wherever │
				-- │  a server reports them; a server can watch workspace files on    │
				-- │  our behalf; Visual/operator-pending `an`/`in` fall back to      │
				-- │  LSP's `selection_range` when Treesitter isn't active.           │
				-- │                                                                  │
				-- │  Diagnostics (global, available without a server):               │
				-- │  [d / ]d  – jump to prev/next diagnostic       [built-in 0.10]   │
				-- │  [D / ]D  – jump to first/last diagnostic      [built-in 0.11]   │
				-- │  <C-w>d   – open floating diagnostic detail    [built-in 0.10]   │
				-- └──────────────────────────────────────────────────────────────────┘

				-- gd: go to definition with de-duplication.
				-- Avoids showing duplicate results for `local M.fn = function() ... end` style Lua code.
				-- See: https://www.reddit.com/r/neovim/comments/19cvgtp
				-- Uses the location list: jumps directly on a single hit, opens lopen for multiple.
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

				-- K: hover documentation (overrides built-in to apply border and size constraints)
				map("K", function()
					vim.lsp.buf.hover({
						border = border_style,
						max_height = 20,
						max_width = 120,
						close_events = { "CursorMoved", "BufLeave", "WinLeave", "LspDetach" },
					})
				end, "Hover Documentation")

				-- <C-k>: signature help from normal mode (built-in default only covers insert mode, via <C-S>)
				map("<C-k>", function()
					vim.lsp.buf.signature_help({ border = border_style })
				end, "Signature Help")

				-- <C-s> insert: same byte as built-in <C-S> in most terminals, kept for the custom border
				vim.keymap.set("i", "<C-s>", function()
					vim.lsp.buf.signature_help({ border = border_style })
				end, { buf = event.buf, desc = "LSP: Signature Help (insert)", silent = true })

				map("<leader>wa", vim.lsp.buf.add_workspace_folder, "Workspace Add Folder") -- add dir to workspace
				map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Workspace Remove Folder") -- remove dir from workspace
				map("<leader>wf", function()
					vim.print(vim.lsp.buf.list_workspace_folders())
				end, "Workspace List Folders") -- print workspace folder list to command line

				map("<leader>ox", function()
					local enabled = vim.diagnostic.is_enabled({ bufnr = event.buf })
					vim.diagnostic.enable(not enabled, { bufnr = event.buf })
				end, "Toggle Diagnostics") -- disable/re-enable all diagnostics for this buffer

				map("<leader>xf", vim.diagnostic.open_float, "Line Diagnostics") -- ergonomic alias for built-in <C-w>d

				if client:supports_method("textDocument/documentHighlight", event.buf) then
					local hl_group = utils.augroup("lsp-highlight", false)
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buf = event.buf,
						group = hl_group,
						callback = vim.lsp.buf.document_highlight, -- highlight all occurrences of symbol under cursor
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buf = event.buf,
						group = hl_group,
						callback = vim.lsp.buf.clear_references, -- clear highlights when cursor moves away
					})
					vim.api.nvim_create_autocmd("LspDetach", {
						group = utils.augroup("lsp-detach"),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "999rpm-lsp-highlight", buf = event2.buf })
						end,
					})
				end

				if client:supports_method("textDocument/inlayHint", event.buf) then
					map("<leader>oh", function()
						-- Both the check AND the enable() call must be scoped to `bufnr`;
						-- enable() applies globally to every buffer if you leave that out.
						local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
						vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
					end, "Toggle Inlay Hints") -- show/hide inline parameter names and return types
				end

				-- No format-on-save autocmd here on purpose: that job belongs solely to
				-- plugins/lang-tools/conform.lua, whose own `lsp_format = "fallback"` already covers
				-- "format via LSP when no CLI formatter is configured for this filetype". A second,
				-- independent BufWritePre formatter here would format some filetypes twice, and
				-- conform's own <leader>tc/<leader>tC toggles wouldn't cover it.

				if client.name == "ruff" then
					client.server_capabilities.hoverProvider = false -- let basedpyright handle hover for Python
				end
			end,
		})

		vim.api.nvim_create_autocmd("LspProgress", {
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client.name == "basedpyright" then
					return -- suppress basedpyright's verbose indexing progress
				end

				local value = ev.data.params.value
				vim.api.nvim_echo({ { value.message or "done" } }, false, {
					id = "lsp." .. ev.data.client_id,
					kind = "progress",
					source = "vim.lsp",
					title = value.title,
					status = value.kind ~= "end" and "running" or "success",
					percent = value.percentage,
				})
			end,
		})

		-- nvim-lspconfig no longer ships :LspInfo/:LspLog/:LspRestart for free now that its
		-- old require("lspconfig").setup{} wrapper is deprecated in favour of vim.lsp.config —
		-- these three thin aliases keep the familiar command names working on top of the
		-- native :checkhealth / :lsp subcommands.
		vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", { desc = "Show LSP info" })
		vim.api.nvim_create_user_command("LspLog", function()
			vim.cmd(string.format("edit %s", vim.lsp.log.get_filename()))
		end, { desc = "Open LSP log file" })
		vim.api.nvim_create_user_command("LspRestart", "lsp restart", { desc = "Restart LSP" })
		vim.api.nvim_create_user_command("LspFormat", function()
			vim.lsp.buf.format({ async = true })
		end, { desc = "Format buffer via LSP" })

		-- Assumed installed via Mason (see `ensure_installed` in mason.lua — keep both lists
		-- in sync) so they're enabled unconditionally, with no utils.executable() check.
		local servers = {
			lua_ls = {
				single_file_support = true,
				settings = {
					Lua = {
						-- Nvim always embeds LuaJIT specifically, never a different Lua version.
						runtime = { version = "LuaJIT" },
						workspace = { checkThirdParty = false }, -- vim.* API awareness comes from lazydev.lua (ft-gated to Neovim config/plugin dirs), not a static workspace.library entry here — see that file's header
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
				-- root_dir/single_file_support intentionally NOT set here. nvim-lspconfig's own
				-- current default (its lsp/ts_ls.lua) already handles this well: tries package-
				-- manager lockfiles and .git at equal priority, then falls back to the cwd — it
				-- always attaches somewhere rather than refusing to start. A previous version of
				-- this entry overrode both with the older root_pattern(".git")-only pattern plus
				-- single_file_support = false, which is exactly why a standalone .js file with
				-- no .git upward got zero diagnostics and no ufo LSP-folding: ts_ls simply never
				-- attached. Verified against a fresh clone of nvim-lspconfig before removing
				-- this rather than guessing. Same reasoning applies to `tailwindcss` below.
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
							-- Disable yamlls' own built-in schema store fetch — schemastore.nvim's
							-- schemas below replace it, and the plugin's README says its own
							-- "ignore" and other advanced options need the built-in one off.
							enable = false,
							url = "",
						},
						schemas = require("schemastore").yaml.schemas(),
					},
				},
			},
			tailwindcss = {}, -- see ts_ls's note above — inherits nvim-lspconfig's own current root_dir default
			taplo = {},
			neocmake = {},
			bashls = {},
			jsonls = {
				settings = {
					json = {
						-- schemastore.json.schemas() also accepts { select = {"package.json", ...} }
						-- to validate against only specific schemas instead of the full catalog
						-- (verified against xero/dotfiles' lsp/jsonls.lua) — left un-narrowed here
						-- since broader validation coverage is the safer default for a general
						-- config; narrow it if jsonls ever feels slow on huge JSON files.
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			},
			eslint = {},
			html = {},
			cssls = {},
			rust_analyzer = {},
			basedpyright = {
				-- Adapted from jdhao's after/lsp/pyright.lua, translated to basedpyright's own
				-- settings tree (it forked pyright's `pyright.*`/`python.analysis.*` keys under
				-- `basedpyright.*` — the old names are silently ignored, per basedpyright's docs).
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
							-- suppresses basedpyright diagnostics that duplicate a ruff diagnostic
							-- on the same line; see DetachHead/basedpyright#203
							tagSupport = { valueSet = { 2 } },
						},
					},
				},
			},
			ruff = {
				init_options = {
					settings = {
						organizeImports = true, -- ruff's own default already; explicit for the pairing above
					},
				},
			},
			dockerls = {},
			docker_compose_language_service = {},
			markdown_oxide = {},
			mdx_analyzer = {},
		}

		-- NOT installed via Mason's ensure_installed — each one is only enabled if its
		-- executable is already found on $PATH, so a machine without e.g. Go toolchain
		-- installed just gets a warning instead of a broken client.
		local external_servers = {
			-- Settings adapted from jdhao's after/lsp/gopls.lua; see go.dev/gopls/settings.
			gopls = {
				_exec = "gopls",
				_optional = false, -- listed at all => you use Go => worth the startup nag if missing
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
			golangci_lint_ls = { _exec = "golangci-lint-langserver", _optional = true }, -- second source of the same golangci-lint diagnostics lint.lua already provides via direct CLI invocation, if you ever install golangci-lint-langserver — off by default, no conflict since only one path is active
			clangd = { _exec = "clangd", _optional = true },
			hls = {
				_exec = "haskell-language-server-wrapper",
				_optional = true, -- install with `ghcup install hls` — see header note on why this isn't Mason-managed
				settings = {
					haskell = {
						-- Match plugins/lang-tools/conform.lua's `haskell = {"ormolu"}` choice, so a
						-- manual :LspFormat (which calls the LSP client directly, bypassing conform)
						-- formats the same way format-on-save does instead of a different tool.
						formattingProvider = "ormolu",
						cabalFormattingProvider = "cabal-fmt",
					},
				},
			},
			sqls = { _exec = "sqls", _optional = true },
			vimls = { _exec = "vim-language-server", _optional = true },
			-- Optional Python type checkers, both off by default: running either alongside
			-- basedpyright means two full type checkers on the same buffer, and neither has a
			-- dedup trick with basedpyright the way ruff does (see basedpyright's own
			-- `capabilities` above), so turning one on would likely double up diagnostics
			-- rather than add coverage. Uncomment at most one to try it.
			-- Meta's Rust-based Python type checker (github.com/facebook/pyrefly):
			-- pyrefly = {
			-- 	_exec = "pyrefly",
			-- 	_optional = true,
			-- 	settings = { python = { pyrefly = { typeCheckingMode = "default" } } },
			-- },
			-- Astral's Rust-based Python type checker, sibling to ruff (docs.astral.sh/ty):
			-- ty = {
			-- 	_exec = "ty",
			-- 	_optional = true,
			-- 	settings = { ty = { diagnosticMode = "workspace" } },
			-- },
			-- Optional grammar/spell-check servers — off by default (jdhao leaves them
			-- commented out in his own config too). Uncomment either line to turn one on;
			-- install with `brew install ltex-ls` / `brew install codebook-lsp` (or
			-- `cargo install codebook-lsp`) first, or via Mason's :MasonInstall ltex-ls.
			-- ltex = { _exec = "ltex-ls", _optional = true }, -- LanguageTool check for prose & Markdown
			-- codebook = { _exec = "codebook-lsp", _optional = true }, -- code-aware spell check
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
						string.format("Executable '%s' not found — server '%s' will not start", exec, name),
						vim.log.levels.WARN,
						{ title = "LSP" }
					)
				end)
			end
		end
	end,
}
