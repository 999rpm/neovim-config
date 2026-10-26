-- neovim/nvim-lspconfig: server definitions, started through vim.lsp.config/vim.lsp.enable. Mason installs the binaries
-- (mason.lua); rust-analyzer belongs to rustaceanvim.lua. markdown-oxide serves markdown files and the notes graph,
-- never a notebook (.ipynb), whose cells otter.lua serves. basedpyright pushes its diagnostics, and a notebook's cells
-- get a basedpyright of their own, rooted at the notebook's folder, where the kernel imports from (molten.lua), with
-- the project's .venv Python. Diagnostics: tiny-inline-diagnostic.lua draws the cursor line's messages, mappings.lua
-- holds <leader>df/db/dw. Floats take 'winborder'.
-- Built-in LSP keys kept as Neovim sets them: K hover, gra code action, grx code lens, grr references, gri
-- implementation, grt type definition, gO document symbols, <C-s> signature help in insert mode; ]d/[d, ]D/[D and
-- <C-w>d for diagnostics. Set per buffer below, only where an attached server answers them: gd, gD and grn as upgrades
-- of the built-ins, normal-mode <C-k>. Owns <leader>lw.
return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" }, -- off the startup path; the servers still attach before the first FileType
	config = function()
		local core = require("utils.core")

		vim.diagnostic.config({
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

				---The servers' locations for method, one hit jumped to and several in the location list; when no server finds
				---any, the built-in key runs, so a word the servers do not know still gets Neovim's own text search.
				---@param method string
				---@param builtin string
				local function locate(method, builtin)
					return function()
						local win = vim.api.nvim_get_current_win()
						vim.lsp.buf_request_all(event.buf, method, function(c)
							return vim.lsp.util.make_position_params(win, c.offset_encoding)
						end, function(results)
							if not vim.api.nvim_win_is_valid(win) then
								return -- the window closed before the servers answered
							end
							local items, seen = {}, {}
							for id, res in pairs(results) do
								local found = res.result or {}
								local c = vim.lsp.get_client_by_id(id)
								found = c
									and vim.lsp.util.locations_to_items(
										vim.islist(found) and found or { found },
										c.offset_encoding
									)
								for _, item in ipairs(found or {}) do
									local key = item.filename .. ":" .. item.lnum -- one definition per file and line, whichever server sent it
									if not seen[key] then
										seen[key] = true
										items[#items + 1] = item
									end
								end
							end
							if #items == 0 then
								return vim.api.nvim_win_call(win, function()
									vim.cmd("normal! " .. builtin)
								end)
							end
							vim.fn.setloclist(win, {}, " ", { title = method, items = items })
							vim.api.nvim_win_call(win, function()
								vim.cmd(#items > 1 and "lopen" or "lfirst")
							end)
						end)
					end
				end

				if client:supports_method("textDocument/definition", event.buf) then -- render-markdown's and crates.nvim's in-process servers answer none, so gd stays built-in there
					map("gd", locate("textDocument/definition", "gd"), "Go to definition (LSP, else built-in)") -- n: upgrades built-in gd: the server's definition, one hit jumped to, several in the location list; when no server finds one, the built-in local-declaration search
				end

				if client:supports_method("textDocument/declaration", event.buf) then
					map("gD", locate("textDocument/declaration", "gD"), "Go to declaration (LSP, else built-in)") -- n: upgrades built-in gD the same way; with no answer, the built-in file-wide search
				end

				if client:supports_method("textDocument/rename", event.buf) then
					vim.keymap.set("n", "grn", function()
						vim.v.errmsg = "" -- inc-rename cancels the rename when v:errmsg holds anything, and barbar's startup leaves an E116 there
						return ":IncRename " .. vim.fn.expand("<cword>")
					end, { buf = event.buf, expr = true, silent = true, desc = "LSP: Rename (live preview)" }) -- n: upgrades built-in grn: the same rename, each change previewed while typing (inc-rename.lua)
				end

				if client:supports_method("textDocument/signatureHelp", event.buf) then
					map("<C-k>", vim.lsp.buf.signature_help, "Signature help") -- n: the parameters of the call under the cursor; normal-mode <C-k> has no built-in job
				end

				map("<leader>lwa", vim.lsp.buf.add_workspace_folder, "Add workspace folder") -- n: let the server index another folder too
				map("<leader>lwr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder") -- n: drop one of those folders
				map("<leader>lwl", function()
					vim.print(vim.lsp.buf.list_workspace_folders())
				end, "List workspace folders") -- n: print the folders the servers index

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

		local cell_roots = {} -- notebook folders that root a basedpyright of their own, each with the project's .venv Python or false

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
				capabilities = { textDocument = { diagnostic = { dynamicRegistration = false } } }, -- the server then pushes its diagnostics: Neovim pulls only for buffers shown in a window, and otter.lua's hidden cell buffers never are
				root_dir = function(bufnr, on_dir) -- a notebook's cells resolve imports from the notebook's folder, which the kernel searches ahead of site-packages, so a module there wins over a package of the same name
					local project = vim.fs.root(bufnr, vim.lsp.config.basedpyright.root_markers)
					if not require("utils.notebook").is_cell_buffer(bufnr) then
						return on_dir(project)
					end
					local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
					if dir ~= project then
						local python = project and core.venv_bin(project .. "/.venv", "python")
						cell_roots[dir] = python and vim.uv.fs_stat(python) ~= nil and python or false
					end
					on_dir(dir)
				end,
				before_init = function(_, config) -- a cells root checks the open cells only, as the project's own client reports the folder's files, and takes the .venv basedpyright finds at a project root
					local python = cell_roots[config.root_dir]
					if python == nil then
						return
					end
					config.settings.basedpyright.analysis.diagnosticMode = "openFilesOnly" -- in place: the client answers the server from this table
					if python then
						config.settings.python = { pythonPath = python }
					end
				end,
				settings = {
					basedpyright = {
						disableOrganizeImports = true, -- ruff owns import sorting, see `ruff` below
						analysis = { -- useLibraryCodeForTypes stays unset: set here it would override a project's pyproject.toml
							diagnosticMode = "workspace",
							typeCheckingMode = "standard",
						},
					},
				},
			},
			ruff = {
				init_options = {
					settings = {
						organizeImports = true, -- pairs with basedpyright's disableOrganizeImports above
						configuration = { -- inline, above the project's own ruff settings (Ruff 0.9.8 and later)
							lint = {
								["extend-per-file-ignores"] = { ["*.otter.*"] = { "I001", "N999" } }, -- otter.lua's hidden cell file: blank lines stand in for the markdown between cells, and its name is no module name
							},
						},
					},
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
				root_dir = function(bufnr, on_dir) -- never in a notebook: its rename renames the .ipynb file, and otter.lua answers there
					if not vim.api.nvim_buf_get_name(bufnr):match("%.ipynb$") then
						on_dir(vim.fs.root(bufnr, { ".moxide.toml", "logseq", ".obsidian", ".git" })) -- a Logseq graph keeps its logseq/ folder at the root
					end
				end,
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
			hls = { _exec = "haskell-language-server-wrapper" }, -- ghcup builds it against the installed GHC; nvim-lspconfig sets ormolu and cabal-fmt
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
