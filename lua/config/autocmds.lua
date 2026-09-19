-- Autocommands. Every group is named "999rpm-<name>" through utils.augroup, so :autocmd 999rpm-* lists them all.
local api = vim.api
local fn = vim.fn
local utils = require("utils")
local augroup = utils.augroup

api.nvim_create_autocmd("InsertLeave", {
	group = augroup("no_paste"),
	desc = "999rpm: leave paste mode on every insert-mode exit",
	pattern = "*",
	command = "set nopaste",
})

api.nvim_create_autocmd("FileType", {
	group = augroup("format_options"),
	desc = "999rpm: re-strip comment-continuation formatoptions after ftplugins run",
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o", "t" })
	end,
})

api.nvim_create_autocmd("BufWritePre", {
	group = augroup("trim_whitespace"),
	desc = "999rpm: strip trailing whitespace on write",
	pattern = "*",
	callback = function(ev)
		local skip_fts = { markdown = true, gitcommit = true, gitrebase = true }
		if skip_fts[vim.bo[ev.buf].filetype] then
			return
		end
		local view = fn.winsaveview() -- winsaveview, not getpos("."): also restores the scroll offset, so a write near the window edge doesn't jump the screen
		vim.cmd([[keeppatterns %s/\s\+$//e]]) -- keeppatterns: without it every write overwrites the last search pattern and re-lights hlsearch
		fn.winrestview(view)
	end,
})

api.nvim_create_autocmd("BufWritePre", {
	group = augroup("auto_create_dir"),
	desc = "999rpm: create missing parent directories before writing a new file",
	callback = function(ctx)
		utils.may_create_dir(fn.fnamemodify(ctx.file, ":p:h")) -- shared helper rather than an inline mkdir; see utils.lua
	end,
})

api.nvim_create_autocmd("BufRead", {
	group = augroup("non_utf8_file"),
	desc = "999rpm: warn when a file is read in a non-UTF-8 encoding",
	pattern = "*",
	callback = function(ev)
		local enc = vim.bo[ev.buf].fileencoding
		if enc ~= "" and enc ~= "utf-8" then -- "" means 'encoding' is used, which is utf-8 here; only a real non-utf-8 read warns
			vim.notify("File read in a non-UTF-8 encoding", vim.log.levels.WARN)
		end
	end,
})

api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_loc"),
	desc = "999rpm: restore the cursor to its last position in a reopened file",
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

local auto_read_group = augroup("auto_read")
api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	group = auto_read_group,
	desc = "999rpm: checktime so autoread can pick up on-disk changes",
	callback = function()
		if fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
})
api.nvim_create_autocmd("FileChangedShellPost", {
	group = auto_read_group,
	desc = "999rpm: announce a buffer reloaded from disk",
	callback = function()
		vim.notify("File changed on disk, buffer reloaded", vim.log.levels.WARN)
	end,
})

api.nvim_create_autocmd("BufWritePre", {
	group = augroup("undo_disable"),
	desc = "999rpm: no persistent undo/backup for transient files",
	pattern = { "*.tmp", "*.bak", "COMMIT_EDITMSG", "MERGE_MSG" }, -- /tmp/* is left to secure_tmp below, which covers every tmp path
	callback = function(event)
		vim.opt_local.undofile = false

		local backup_was_on = vim.o.backup
		if backup_was_on then
			vim.o.backup = false
			api.nvim_create_autocmd("BufWritePost", {
				buf = event.buf,
				desc = "999rpm: restore the global backup flag after this write",
				once = true,
				callback = function()
					vim.o.backup = true
				end,
			})
		end
	end,
})

local secure_tmp = augroup("secure_tmp")
api.nvim_create_autocmd({ "BufNewFile", "BufReadPre" }, {
	group = secure_tmp,
	desc = "999rpm: no persistence at all for files under tmp/shm paths",
	pattern = { "/tmp/*", "$TMPDIR/*", "$TMP/*", "$TEMP/*", "*/shm/*", "/private/var/*" },
	callback = function(ev)
		vim.opt_local.undofile = false
		if vim.b[ev.buf].user_secure_tmp then
			return -- already armed for this buffer; don't stack a second pair on re-read
		end
		vim.b[ev.buf].user_secure_tmp = true

		api.nvim_create_autocmd("BufWritePre", {
			buf = ev.buf,
			group = secure_tmp,
			desc = "999rpm: suspend the global backup flag around this write",
			callback = function()
				vim.b[ev.buf].user_backup_was_on = vim.o.backup -- read at write time: the global could have been toggled since BufReadPre
				vim.o.backup = false
			end,
		})
		api.nvim_create_autocmd("BufWritePost", {
			buf = ev.buf,
			group = secure_tmp,
			desc = "999rpm: restore the global backup flag after this write",
			callback = function()
				vim.o.backup = vim.b[ev.buf].user_backup_was_on and true or false
			end,
		})
	end,
})

api.nvim_create_autocmd("BufReadPre", {
	group = augroup("large_file"),
	desc = "999rpm: drop expensive per-buffer features on files over 0.5 MB",
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
				buf = ev.buf,
				desc = "999rpm: restore line numbers after leaving a large file",
				once = true,
				callback = function()
					vim.wo.number = true
					vim.wo.relativenumber = true
				end,
			})
		end
	end,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("no_diag_node_modules"),
	desc = "999rpm: no diagnostics inside node_modules",
	pattern = "*/node_modules/*",
	callback = function(ev)
		vim.diagnostic.enable(false, { bufnr = ev.buf }) -- ev.buf, not 0: BufRead can fire for a buffer that is not the current one
	end,
})

local ft_format_check = {
	lua = { "stylua", "--check" }, -- conform: lua = { "stylua" }
	python = { "ruff", "format", "--check" }, -- conform: python = { "ruff_organize_imports", "ruff_format" }
}
api.nvim_create_autocmd("BufWritePost", {
	group = augroup("format_check"),
	desc = "999rpm: warn when autoformat is off and a file was left unformatted",
	callback = function(ev)
		if not (vim.g.disable_autoformat or vim.b[ev.buf].disable_autoformat) then
			return -- conform already formatted this write; nothing left to check
		end

		local cmd_base = ft_format_check[vim.bo[ev.buf].filetype]
		if not cmd_base or fn.executable(cmd_base[1]) == 0 then
			return
		end

		local cmd = vim.list_extend(vim.deepcopy(cmd_base), { ev.file })
		vim.system(cmd, { text = true }, function(result)
			if result.code ~= 0 then
				vim.schedule(function()
					vim.notify(string.format("[%s] File is not properly formatted.", cmd[1]), vim.log.levels.WARN)
				end)
			end
		end)
	end,
})

local yank_group = augroup("highlight_yank")
local pre_yank_view -- plain upvalue, not vim.g: a vim.g write crosses the Lua/Vimscript boundary and copies the table each time
api.nvim_create_autocmd("CursorMoved", {
	group = yank_group,
	desc = "999rpm: track the pre-yank cursor position",
	callback = function()
		local mode = api.nvim_get_mode().mode
		if mode == "n" or mode:find("^[vV\22]") then -- only normal and visual can begin a yank; skip the rest to keep CursorMoved cheap
			pre_yank_view = fn.winsaveview()
		end
	end,
})
api.nvim_create_autocmd("TextYankPost", {
	group = yank_group,
	desc = "999rpm: flash yanked text, then restore the cursor",
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 }) -- vim.hl, not vim.highlight: the latter is a deferred-deprecated alias, removal targeted at 2.0.0
		if vim.v.event.operator == "y" and pre_yank_view then
			fn.winrestview(pre_yank_view) -- winrestview, not setpos: also restores the scroll offset, so a yank near the window edge doesn't jump the screen
		end
	end,
})

local cursorline_group = augroup("cursorline")
api.nvim_create_autocmd("WinEnter", {
	group = cursorline_group,
	desc = "999rpm: cursorline on in the active window",
	callback = function(event)
		if vim.bo[event.buf].buftype == "" then
			vim.opt_local.cursorline = true
		end
	end,
})
api.nvim_create_autocmd("WinLeave", {
	group = cursorline_group,
	desc = "999rpm: cursorline off in unfocused windows",
	callback = function()
		vim.opt_local.cursorline = false
	end,
})

local number_toggle = augroup("number_toggle")
api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
	group = number_toggle,
	desc = "999rpm: relative numbers in the focused window",
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = true
		end
	end,
})
api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
	group = number_toggle,
	desc = "999rpm: absolute numbers when unfocused or in insert mode",
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = false
		end
	end,
})

api.nvim_create_autocmd("VimResized", {
	group = augroup("win_autoresize"),
	desc = "999rpm: equalize splits when the terminal resizes",
	command = "wincmd =",
})

api.nvim_create_autocmd("FileType", {
	group = augroup("no_conceal"),
	desc = "999rpm: no concealing in json/markdown/text",
	pattern = { "json", "jsonc", "markdown", "text" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

api.nvim_create_autocmd("ColorScheme", {
	group = augroup("custom_highlights"),
	desc = "999rpm: re-apply cursor/matchparen/LSP-reference highlights after a theme switch",
	pattern = "*",
	callback = function()
		api.nvim_set_hl(0, "Cursor", { fg = "black", bg = "#00c918", bold = true })
		api.nvim_set_hl(0, "Cursor2", { fg = "red", bg = "red" })

		api.nvim_set_hl(0, "MatchParen", { bold = true, underline = true })

		api.nvim_set_hl(0, "LspReferenceText", { underline = true, reverse = true })
		api.nvim_set_hl(0, "LspReferenceRead", { underline = true, reverse = true })
		api.nvim_set_hl(0, "LspReferenceWrite", { underline = true, reverse = true })
	end,
})

api.nvim_create_autocmd("BufEnter", {
	group = augroup("auto_close_win"),
	desc = "999rpm: quit if only utility windows remain",
	callback = function()
		if fn.getcmdwintype() ~= "" then
			return -- the command-line window cannot be left with :qall
		end
		local utility_fts = { "qf", "neo-tree" }
		for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
			if api.nvim_win_get_config(win).relative == "" then -- floats (pickers, previews, notifications) are not what keeps a tab alive
				local ft = vim.bo[api.nvim_win_get_buf(win)].filetype
				if not vim.tbl_contains(utility_fts, ft) then
					return -- at least one real window exists, don't quit
				end
			end
		end
		vim.cmd("qall")
	end,
})

api.nvim_create_autocmd("TermOpen", {
	group = augroup("term_start"),
	desc = "999rpm: terminal buffers open without line numbers, in insert mode",
	callback = function(event)
		vim.wo.relativenumber = false
		vim.wo.number = false
		if api.nvim_get_current_buf() == event.buf and vim.bo[event.buf].filetype ~= "snacks_terminal" then
			vim.cmd("startinsert") -- snacks terminals handle their own insert mode; a background terminal must not steal it
		end
	end,
})

api.nvim_create_autocmd("OptionSet", {
	group = augroup("shell_options"),
	pattern = "shell",
	desc = "999rpm: re-apply the shell* flags when 'shell' changes",
	callback = utils.apply_shell_options, -- shared helper; see utils.lua
})

api.nvim_create_autocmd("MenuPopup", {
	group = augroup("popupmenu"),
	desc = "999rpm: rebuild the right-click PopUp menu per buffer",
	pattern = "*",
	callback = function()
		local cword = fn.expand("<cword>")
		pcall(api.nvim_del_augroup_by_name, "nvim.popupmenu") -- drops Nvim's own default-menu builder; pcall since the group is gone after the first right-click
		vim.cmd([[
			aunmenu PopUp

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
			anoremenu PopUp.Find\ Symbol                <cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>
			anoremenu PopUp.Grep\ Word                  <cmd>lua Snacks.picker.grep_word()<CR>
			anoremenu PopUp.Find\ Todos                 <cmd>lua Snacks.picker.todo_comments()<CR>
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
		if not _G.Snacks then
			vim.cmd([[amenu disable PopUp.Find\ Symbol]])
			vim.cmd([[amenu disable PopUp.Grep\ Word]])
			vim.cmd([[amenu disable PopUp.Find\ Todos]])
			vim.cmd([[amenu disable PopUp.LazyGit]])
			vim.cmd([[amenu disable PopUp.Open\ Git\ in\ Browser]])
		end
	end,
})

api.nvim_create_autocmd("FileType", {
	group = augroup("spell_check"),
	desc = "999rpm: spell check on for prose filetypes",
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.spell = true
	end,
})
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("spell_check_ext"),
	desc = "999rpm: spell check on for .txt/.tex before FileType fires",
	pattern = { "*.txt", "*.tex" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	desc = "999rpm: close utility buffers with q",
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
				buf = event.buf,
				silent = true,
				desc = "Close buffer",
			})
		end)
	end,
})

local dynamic_smartcase = augroup("dynamic_smartcase")
api.nvim_create_autocmd("CmdlineEnter", {
	group = dynamic_smartcase,
	desc = "999rpm: smartcase off while the : command line is open",
	pattern = ":",
	callback = function()
		vim.o.smartcase = false
	end,
})
api.nvim_create_autocmd("CmdlineLeave", {
	group = dynamic_smartcase,
	desc = "999rpm: smartcase back on when the : command line closes",
	pattern = ":",
	callback = function()
		vim.o.smartcase = true
	end,
})
