-- Autocommands. Every group is named "999rpm-<name>" through utils.augroup, so :autocmd 999rpm-* lists them all.
local api = vim.api
local fn = vim.fn
local utils = require("utils")
local augroup = utils.augroup

api.nvim_create_autocmd("FileType", {
	group = augroup("format_options"),
	desc = "999rpm: re-strip comment-continuation formatoptions after ftplugins run",
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o", "t" })
	end,
})

local keep_trailing = { markdown = true, gitcommit = true, gitrebase = true, diff = true, mail = true } -- hard line breaks, patch context lines, the "-- " signature
api.nvim_create_autocmd("BufWritePre", {
	group = augroup("trim_whitespace"),
	desc = "999rpm: strip trailing whitespace on write",
	callback = function(ev)
		local bo, ec = vim.bo[ev.buf], vim.b[ev.buf].editorconfig
		if keep_trailing[bo.filetype] or bo.binary or not bo.modifiable or bo.buftype ~= "" then
			return
		elseif type(ec) == "table" and ec.trim_trailing_whitespace == "false" then
			return -- the project's .editorconfig keeps it
		end
		local view = fn.winsaveview() -- the scroll offset is restored too, so the screen does not jump
		vim.cmd([[keeppatterns %s/\s\+$//e]]) -- keeppatterns: the last search pattern survives the write
		fn.winrestview(view)
	end,
})

api.nvim_create_autocmd("BufWritePre", {
	group = augroup("auto_create_dir"),
	desc = "999rpm: create missing parent directories before writing a new file",
	callback = function(ctx)
		if ctx.match:match("^%w%w+:[\\/][\\/]") then
			return -- a URL (oil://, scp://), not a path on disk
		end
		utils.may_create_dir(fn.fnamemodify(ctx.file, ":p:h"))
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
	desc = "999rpm: restore the last cursor position once the file shows in a window",
	callback = function(ev)
		if vim.b[ev.buf]._999rpm_last_loc then
			return -- :edit! re-reads the file; the cursor stays where it is
		end
		vim.b[ev.buf]._999rpm_last_loc = true
		local mark = api.nvim_buf_get_mark(ev.buf, '"') -- read now: closing the hidden window of a bufload() resets it
		api.nvim_create_autocmd("BufWinEnter", {
			buffer = ev.buf, -- a buffer loaded unseen (pickers, grug-far, LSP renames) waits for its first real window
			desc = "999rpm: jump to the '\" mark",
			callback = function()
				if fn.win_gettype() == "autocmd" then
					return -- bufload() shows the buffer in Neovim's hidden autocommand window first
				end
				local ft = vim.bo[ev.buf].filetype -- skipped as in :h last-position-jump
				local skip = ft:find("commit") or ft == "gitrebase" or ft == "xxd" or vim.wo.diff
				if not skip and mark[1] > 1 and mark[1] <= api.nvim_buf_line_count(ev.buf) then
					pcall(api.nvim_win_set_cursor, 0, mark)
				end
				return true -- done: the autocommand deletes itself
			end,
		})
	end,
})

local auto_read_group = augroup("auto_read")
api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = auto_read_group,
	desc = "999rpm: checktime so autoread can pick up on-disk changes", -- CursorHold would re-read every buffer ten times a second at updatetime=100
	callback = function()
		if fn.getcmdwintype() == "" and vim.bo.buftype ~= "nofile" then
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

api.nvim_create_autocmd({ "BufNewFile", "BufReadPre" }, {
	group = augroup("no_undofile"),
	desc = "999rpm: no undo file for temporary and transient files",
	pattern = {
		"/tmp/*",
		"$TMPDIR/*",
		"$TMP/*",
		"$TEMP/*",
		"*/shm/*",
		"/private/tmp/*",
		"/private/var/*",
		"*.tmp",
		"*.bak",
		"COMMIT_EDITMSG",
		"MERGE_MSG",
	},
	callback = function()
		vim.opt_local.undofile = false -- options.lua's 'backupskip' keeps their backups out
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
		if not cmd_base or not utils.executable(cmd_base[1]) then
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
local pre_yank = {} -- an upvalue: a vim.g write would copy the table across the Vimscript boundary on every move
api.nvim_create_autocmd("CursorMoved", {
	group = yank_group,
	desc = "999rpm: track the pre-yank cursor position",
	callback = function()
		local mode = api.nvim_get_mode().mode
		if mode == "n" or mode:find("^[vV\22]") then -- only normal and visual can begin a yank; skip the rest to keep CursorMoved cheap
			pre_yank.win, pre_yank.view = api.nvim_get_current_win(), fn.winsaveview()
		end
	end,
})
api.nvim_create_autocmd("TextYankPost", {
	group = yank_group,
	desc = "999rpm: flash yanked text, then restore the cursor",
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
		if vim.v.event.operator == "y" and pre_yank.win == api.nvim_get_current_win() then -- a yank run from code in another window keeps its cursor
			fn.winrestview(pre_yank.view) -- y leaves the cursor where the yank started, with the same scroll offset
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
		if vim.wo.number and vim.g._999rpm_relativenumber ~= false then -- false: <leader>oN (snacks.lua) turned them off
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
	desc = "999rpm: equalize splits in every tab when the terminal resizes",
	callback = function()
		for _, tab in ipairs(api.nvim_list_tabpages()) do
			api.nvim_win_call(api.nvim_tabpage_get_win(tab), function()
				vim.cmd("wincmd =") -- nvim_win_call visits the tab without firing TabEnter or BufEnter
			end)
		end
	end,
})

api.nvim_create_autocmd("FileType", {
	group = augroup("no_conceal"),
	desc = "999rpm: no concealing in json and text",
	pattern = { "json", "jsonc", "text" }, -- markdown's conceal level belongs to render-markdown.lua, which resets it on every mode change
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

local utility_fts = { qf = true, ["neo-tree"] = true, trouble = true } -- neo-tree.lua leaves close_if_last_window off, so this is the one place that decides
local function only_utility_windows()
	for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
		if
			api.nvim_win_get_config(win).relative == "" and not utility_fts[vim.bo[api.nvim_win_get_buf(win)].filetype]
		then
			return false -- floats (pickers, previews, notifications) do not keep a tab alive; one real window does
		end
	end
	return fn.getcmdwintype() == "" -- the command-line window cannot be left with :qall
end
api.nvim_create_autocmd("BufEnter", {
	group = augroup("auto_close_win"),
	desc = "999rpm: close the tab, or quit, when only utility windows remain",
	callback = function()
		if only_utility_windows() then
			vim.schedule(function() -- E1312: BufEnter may not change the window layout
				if only_utility_windows() then
					vim.cmd(#api.nvim_list_tabpages() > 1 and "tabclose" or "qall") -- other tabs keep their windows
				end
			end)
		end
	end,
})

api.nvim_create_autocmd("TermOpen", {
	group = augroup("term_start"),
	desc = "999rpm: terminal buffers open in insert mode",
	callback = function(event)
		if api.nvim_get_current_buf() == event.buf and vim.bo[event.buf].filetype ~= "snacks_terminal" then
			vim.cmd("startinsert") -- snacks terminals handle their own insert mode; a background terminal must not steal it
		end
	end,
})

api.nvim_create_autocmd("OptionSet", {
	group = augroup("shell_options"),
	pattern = "shell",
	desc = "999rpm: re-apply the shell* flags when 'shell' changes",
	callback = utils.apply_shell_options,
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
	group = augroup("prose"),
	desc = "999rpm: spell check and soft wrap for prose filetypes",
	pattern = { "text", "tex", "plaintex", "typst", "gitcommit", "markdown", "quarto" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.wrap = true -- 'linebreak' and 'breakindent' (options.lua) break at words and keep the indent
	end,
})

api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	desc = "999rpm: close utility buffers with q",
	pattern = { "checkhealth", "help", "man", "qf" }, -- man's own q runs <C-w>q, which quits Neovim from the last window
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			utils.map_close(event.buf, true)
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
