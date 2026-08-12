-- Editor-wide autocmds not owned by any specific plugin. Companion files: options.lua (static
-- settings this file reacts to), mappings.lua (keymaps). Grouped below by EDITING BEHAVIOR /
-- FILE HANDLING / UI / DISPLAY / FILETYPE-SPECIFIC. Every custom group here is namespaced
-- "999rpm-<name>" via utils.augroup() — see that function's own doc-comment.
local api = vim.api
local fn = vim.fn
local augroup = require("utils").augroup

-- ============================================================
-- EDITING BEHAVIOR
-- ============================================================

-- Turn off paste mode when leaving insert
api.nvim_create_autocmd("InsertLeave", {
	group = augroup("no_paste"),
	pattern = "*",
	command = "set nopaste",
})

-- Re-enforce formatoptions after FileType plugins run.
-- Many bundled ftplugins re-add 'c', 'r', 'o' (auto-comment leaders) even
-- after options.lua removes them, because they fire on the FileType event.
-- Running this in the same event with a slightly-later priority keeps them off.
api.nvim_create_autocmd("FileType", {
	group = augroup("format_options"),
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o", "t" })
	end,
})

-- Remove trailing whitespace on save, preserving cursor position.
-- Skips markdown and gitcommit because trailing spaces are semantically
-- meaningful there (two spaces = <br> in Markdown).
api.nvim_create_autocmd("BufWritePre", {
	group = augroup("trim_whitespace"),
	pattern = "*",
	callback = function(ev)
		local skip_fts = { markdown = true, gitcommit = true, gitrebase = true }
		if skip_fts[vim.bo[ev.buf].filetype] then
			return
		end
		local pos = fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		fn.setpos(".", pos)
	end,
})

-- Auto-create intermediate directories when saving a new file
api.nvim_create_autocmd("BufWritePre", {
	group = augroup("auto_create_dir"),
	callback = function(ctx)
		local dir = fn.fnamemodify(ctx.file, ":p:h")
		if fn.isdirectory(dir) == 0 then
			fn.mkdir(dir, "p")
		end
	end,
})

-- ============================================================
-- FILE HANDLING
-- ============================================================

-- Warn when opening a file that is not UTF-8 encoded
api.nvim_create_autocmd("BufRead", {
	group = augroup("non_utf8_file"),
	pattern = "*",
	callback = function()
		if vim.bo.fileencoding ~= "utf-8" then
			vim.notify("File not in UTF-8 format!", vim.log.levels.WARN)
		end
	end,
})

-- Restore cursor to last known position when reopening a file
api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit", "commit", "gitrebase" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].user_last_loc then
			return
		end
		vim.b[buf].user_last_loc = true
		local mark = api.nvim_buf_get_mark(buf, '"')
		local lcount = api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Reload file automatically if changed outside nvim.
-- options.lua sets autoread=true; these autocmds trigger the actual checktime call.
local auto_read_group = augroup("auto_read")
api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	group = auto_read_group,
	callback = function()
		if fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
})
api.nvim_create_autocmd("FileChangedShellPost", {
	group = auto_read_group,
	callback = function()
		vim.notify("File changed on disk. Buffer reloaded!", vim.log.levels.WARN)
	end,
})

-- Disable undo for temporary/transient files.
--
-- NOTE on `backup`: it is a **global-only** option in Neovim, so vim.opt_local.backup is
-- silently equivalent to vim.opt_global.backup — it would permanently disable backup for the
-- whole session the first time any matching file is opened, clobbering options.lua's
-- backup=true. The correct approach is keeping backup files away from these paths via
-- backupskip (already done in options.lua for /tmp/* etc.) and handling git commit messages
-- through the write/post pair below, which temporarily toggles the global flag only around
-- the write.
--
-- NOTE on `swapfile`: options.lua already sets swapfile=false globally, so no action here.
api.nvim_create_autocmd("BufWritePre", {
	group = augroup("undo_disable"),
	pattern = { "/tmp/*", "*.tmp", "*.bak", "COMMIT_EDITMSG", "MERGE_MSG" },
	callback = function(event)
		vim.opt_local.undofile = false

		local backup_was_on = vim.o.backup
		if backup_was_on then
			vim.o.backup = false
			api.nvim_create_autocmd("BufWritePost", {
				buffer = event.buf,
				once = true,
				callback = function()
					vim.o.backup = true
				end,
			})
		end
	end,
})

-- Belt-and-suspenders: disable all persistence for files in shm/tmp dirs.
-- `backup` is global-only, so it's toggled safely around each write, capturing the original
-- value at read time (rather than at write time) since the global state could change between
-- BufReadPre and the eventual BufWritePre.
api.nvim_create_autocmd({ "BufNewFile", "BufReadPre" }, {
	group = augroup("secure_tmp"),
	pattern = { "/tmp/*", "$TMPDIR/*", "$TMP/*", "$TEMP/*", "*/shm/*", "/private/var/*" },
	callback = function(ev)
		vim.opt_local.undofile = false

		if vim.o.backup then
			api.nvim_create_autocmd("BufWritePre", {
				buffer = ev.buf,
				callback = function()
					vim.o.backup = false
				end,
			})
			api.nvim_create_autocmd("BufWritePost", {
				buffer = ev.buf,
				callback = function()
					vim.o.backup = true
				end,
			})
		end
	end,
})

-- Large file optimizations: disable expensive per-buffer features for files > 0.5 MB.
-- This is the ONLY large-file handler active — snacks.lua ships a near-identical `bigfile`
-- module (plus disabling treesitter/LSP/syntax, which this one doesn't) at a different size
-- threshold; running both would mean duplicate work at two thresholds, so snacks.bigfile is
-- disabled in favor of this one (see snacks.lua's note). If very large files (tens of MB+)
-- ever get slow, snacks.bigfile's extra treesitter/LSP-disabling is the thing to revisit.
api.nvim_create_autocmd("BufReadPre", {
	group = augroup("large_file"),
	callback = function(ev)
		local size_limit = 524288 -- 0.5 MB
		local size = fn.getfsize(ev.file)
		if size > size_limit or size == -2 then
			vim.wo.relativenumber = false
			vim.wo.number = false
			vim.bo.swapfile = false
			vim.bo.bufhidden = "unload"
			vim.bo.undolevels = -1

			api.nvim_create_autocmd("BufLeave", {
				buffer = ev.buf,
				once = true,
				callback = function()
					vim.wo.number = true
					vim.wo.relativenumber = true
				end,
			})
		end
	end,
})

-- Disable diagnostics inside node_modules
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("no_diag_node_modules"),
	pattern = "*/node_modules/*",
	callback = function()
		vim.diagnostic.enable(false, { bufnr = 0 })
	end,
})

-- Warn if a supported file type is not properly formatted after saving.
-- Requires `stylua` and/or `black` to be installed and on $PATH.
local ft_format_check = {
	python = { "black", "--check" },
	lua = { "stylua", "--check" },
}
api.nvim_create_autocmd("BufWritePost", {
	group = augroup("format_check"),
	callback = function(ev)
		local ft = vim.api.nvim_get_option_value("filetype", { buf = ev.buf })
		local cmd_base = ft_format_check[ft]
		if not cmd_base then
			return
		end

		local cmd = vim.deepcopy(cmd_base)
		table.insert(cmd, ev.file)

		if fn.executable(cmd[1]) == 0 then
			return
		end

		local result = vim.system(cmd, { text = true }):wait()
		if result.code ~= 0 then
			vim.notify(string.format("[%s] File is not properly formatted.", cmd[1]), vim.log.levels.WARN)
		end
	end,
})

-- ============================================================
-- UI / DISPLAY
-- ============================================================

-- Highlight yanked text briefly, then restore cursor to pre-yank position.
-- Cursor tracking happens on every CursorMoved so the saved position is always
-- the one just before the yank motion starts.
local yank_group = augroup("highlight_yank")
api.nvim_create_autocmd("CursorMoved", {
	group = yank_group,
	callback = function()
		vim.g.user_cursor_pos = fn.getcurpos()
	end,
})
api.nvim_create_autocmd("TextYankPost", {
	group = yank_group,
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
		if vim.v.event.operator == "y" then
			fn.setpos(".", vim.g.user_cursor_pos)
		end
	end,
})

-- Show cursorline only in the active window.
-- options.lua sets cursorline=true globally; these autocmds hide it in
-- unfocused splits and while in insert mode so it doesn't become visual noise.
api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
	group = augroup("cursorline_show"),
	callback = function(event)
		if vim.bo[event.buf].buftype == "" then
			vim.opt_local.cursorline = true
		end
	end,
})
api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
	group = augroup("cursorline_hide"),
	callback = function()
		vim.opt_local.cursorline = false
	end,
})

-- Toggle relative/absolute line numbers based on mode and focus.
-- options.lua sets both number=true and relativenumber=true globally;
-- these autocmds switch to absolute numbers in insert mode and unfocused windows.
local number_toggle = augroup("number_toggle")
api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
	group = number_toggle,
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = true
		end
	end,
})
api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
	group = number_toggle,
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = false
		end
	end,
})

-- Equalize window sizes when the terminal is resized
api.nvim_create_autocmd("VimResized", {
	group = augroup("win_autoresize"),
	command = "wincmd =",
})

-- Disable conceallevel for JSON and Markdown.
-- options.lua sets conceallevel=2 globally to hide URL syntax etc.;
-- these file types are easier to work with at level 0.
api.nvim_create_autocmd("FileType", {
	group = augroup("no_conceal"),
	pattern = { "json", "jsonc", "markdown", "text" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Re-apply highlight groups that survive colorscheme switches.
--
-- This autocmd is REQUIRED for the custom guicursor shapes defined in
-- options.lua. The guicursor option references the "Cursor" and "Cursor2"
-- highlight groups by name:
--
--   n-v-c:block-Cursor/lCursor  →  uses hl "Cursor"
--   i-ci-ve:ver25-Cursor2/lCursor2  →  uses hl "Cursor2"
--
-- These groups are not defined by most colorschemes, so without this
-- autocmd every :colorscheme command silently breaks the cursor colours.
-- Running on ColorScheme guarantees they are (re)defined after every theme
-- change, including the initial one on startup.
api.nvim_create_autocmd("ColorScheme", {
	group = augroup("custom_highlights"),
	pattern = "*",
	callback = function()
		-- Cursor shapes (required by guicursor in options.lua)
		vim.api.nvim_set_hl(0, "Cursor", { fg = "black", bg = "#00c918", bold = true })
		vim.api.nvim_set_hl(0, "Cursor2", { fg = "red", bg = "red" })

		-- Make matching parentheses stand out more than most themes manage
		vim.api.nvim_set_hl(0, "MatchParen", { bold = true, underline = true })

		-- Word-under-cursor reference highlights, styled to actually stand out.
		-- These are the group names native LSP document-highlight actually uses —
		-- `LspReferenceText`/`LspReferenceRead`/`LspReferenceWrite` (wired up on CursorHold in
		-- lspconfig.lua's LspAttach block) — which default-link to "Visual", a known complaint
		-- (e.g. rose-pine/neovim#330) since an LSP reference then looks identical to an actual
		-- Visual selection until overridden.
		vim.api.nvim_set_hl(0, "LspReferenceText", { underline = true, reverse = true })
		vim.api.nvim_set_hl(0, "LspReferenceRead", { underline = true, reverse = true })
		vim.api.nvim_set_hl(0, "LspReferenceWrite", { underline = true, reverse = true })
	end,
})

-- Auto-quit nvim when only utility/sidebar windows remain open
-- (e.g. NvimTree or quickfix left open after the last real buffer closes)
api.nvim_create_autocmd("BufEnter", {
	group = augroup("auto_close_win"),
	desc = "Quit if only utility windows remain",
	callback = function()
		local utility_fts = { "qf", "vista", "NvimTree", "neo-tree", "aerial" }
		local tabwins = api.nvim_tabpage_list_wins(0)
		for _, win in pairs(tabwins) do
			local buf = api.nvim_win_get_buf(win)
			local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
			if not vim.tbl_contains(utility_fts, ft) then
				return -- at least one real window exists, don't quit
			end
		end
		vim.cmd("qall")
	end,
})

-- No line numbers in terminal buffers; enter insert mode immediately
api.nvim_create_autocmd("TermOpen", {
	group = augroup("term_start"),
	callback = function()
		vim.wo.relativenumber = false
		vim.wo.number = false
		vim.cmd("startinsert")
	end,
})

-- Context-aware right-click / <RightMouse> menu, extending Nvim's own default PopUp menu
-- ($VIMRUNTIME/lua/vim/_defaults.lua) with LSP, diagnostics, and picker actions. Rebuilt on
-- every popup (rather than defined once) because what should be enabled — is there an LSP
-- client for this method, is there a word under the cursor — depends on the buffer you
-- right-clicked in, not just on what's installed.
--
-- Adapted from rafi/vim-config <https://github.com/rafi/vim-config> (lua/rafi/config/
-- autocmds.lua): the native/LSP/diagnostic entries are close to a direct port; the picker and
-- git entries are rewired to what this config actually has — Telescope instead of a LazyVim
-- picker wrapper, todo-comments' real :TodoTelescope command, snacks.lua's existing
-- Snacks.lazygit()/gitbrowse() (same functions already bound to <leader>gl/<leader>gb) — and
-- the bookmarks.nvim entry is dropped since this config doesn't have that plugin.
api.nvim_create_autocmd("MenuPopup", {
	group = augroup("popupmenu"),
	pattern = "*",
	callback = function()
		local cword = fn.expand("<cword>")
		vim.cmd([[
			aunmenu PopUp
			autocmd! nvim.popupmenu

			anoremenu PopUp.Inspect                   <cmd>Inspect<CR>
			anoremenu PopUp.Definition                 <cmd>lua vim.lsp.buf.definition()<CR>
			anoremenu PopUp.References                  <cmd>lua vim.lsp.buf.references()<CR>
			anoremenu PopUp.Implementation             <cmd>lua vim.lsp.buf.implementation()<CR>
			anoremenu PopUp.Declaration                 <cmd>lua vim.lsp.buf.declaration()<CR>
			anoremenu PopUp.-1-                        <Nop>
			anoremenu PopUp.Diagnostics\ (Trouble)      <cmd>Trouble diagnostics toggle<CR>
			anoremenu PopUp.Show\ Diagnostics           <cmd>lua vim.diagnostic.open_float()<CR>
			anoremenu PopUp.Show\ All\ Diagnostics      <cmd>lua vim.diagnostic.setqflist()<CR>
			anoremenu PopUp.-2-                        <Nop>
			anoremenu PopUp.Find\ Symbol                <cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols({default_text = vim.fn.expand('<cword>')})<CR>
			anoremenu PopUp.Grep\ Word                  <cmd>lua require('telescope.builtin').live_grep({default_text = vim.fn.expand('<cword>')})<CR>
			anoremenu PopUp.Find\ Todos                 <cmd>TodoTelescope<CR>
			anoremenu PopUp.-3-                        <Nop>
			anoremenu PopUp.LazyGit                     <cmd>lua Snacks.lazygit()<CR>
			anoremenu PopUp.Open\ Git\ in\ Browser      <cmd>lua Snacks.gitbrowse()<CR>
			anoremenu PopUp.Open\ in\ Web\ Browser      gx
			anoremenu PopUp.-4-                        <Nop>
			vnoremenu PopUp.Cut                         "+x
			vnoremenu PopUp.Copy                        "+y
			anoremenu PopUp.Paste                       "+gP
			vnoremenu PopUp.Paste                       "+P
			vnoremenu PopUp.Delete                      "_x
			nnoremenu PopUp.Select\ All                 ggVG
			vnoremenu PopUp.Select\ All                 gg0oG$
			inoremenu PopUp.Select\ All                 <C-Home><C-O>VG
		]])

		local function has_client_for(method)
			return cword ~= "" and #vim.lsp.get_clients({ bufnr = 0, method = method }) > 0
		end
		if not has_client_for("textDocument/definition") then
			vim.cmd([[amenu disable PopUp.Definition]])
		end
		if not has_client_for("textDocument/references") then
			vim.cmd([[amenu disable PopUp.References]])
		end
		if not has_client_for("textDocument/implementation") then
			vim.cmd([[amenu disable PopUp.Implementation]])
		end
		if not has_client_for("textDocument/declaration") then
			vim.cmd([[amenu disable PopUp.Declaration]])
		end
		if not pcall(require, "telescope") then
			vim.cmd([[amenu disable PopUp.Find\ Symbol]])
			vim.cmd([[amenu disable PopUp.Grep\ Word]])
		end
		if not pcall(require, "todo-comments") then
			vim.cmd([[amenu disable PopUp.Find\ Todos]])
		end
		if not _G.Snacks then
			vim.cmd([[amenu disable PopUp.LazyGit]])
			vim.cmd([[amenu disable PopUp.Open\ Git\ in\ Browser]])
		end
	end,
})

-- ============================================================
-- FILETYPE-SPECIFIC
-- ============================================================

-- Enable spell check for prose file types.
-- options.lua configures spelllang and spelloptions globally but leaves
-- spell=false by default — only enable it where it makes sense.
api.nvim_create_autocmd("FileType", {
	group = augroup("spell_check"),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.spell = true
	end,
})
-- Catch .txt and .tex files opened before their FileType fires
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("spell_check_ext"),
	pattern = { "*.txt", "*.tex" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

-- Close utility/sidebar buffers with just <q>.
-- vim.schedule defers the keymap.set call until after the FileType event
-- has fully settled, avoiding rare edge cases with buftype changes.
api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"blame",
		"checkhealth",
		"fugitive",
		"fugitiveblame",
		"help",
		"httpResult",
		"lazy",
		"lspinfo",
		"man",
		"notify",
		"oil",
		"qf",
		"spectre_panel",
		"startuptime",
		"Trouble",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Close buffer",
			})
		end)
	end,
})

-- Disable smartcase in command-line mode so :s/// and :g// are case-sensitive
-- by default — matching the expectation of most ex commands.
-- options.lua sets smartcase=true for normal search; this temporarily suspends
-- it only while the : command line is active.
local dynamic_smartcase = augroup("dynamic_smartcase")
api.nvim_create_autocmd("CmdLineEnter", {
	group = dynamic_smartcase,
	pattern = ":",
	callback = function()
		vim.o.smartcase = false
	end,
})
api.nvim_create_autocmd("CmdLineLeave", {
	group = dynamic_smartcase,
	pattern = ":",
	callback = function()
		vim.o.smartcase = true
	end,
})
