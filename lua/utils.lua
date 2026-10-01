-- Shared helpers. Every entry names the files that call it, so a helper with no caller is visible as dead code.
local fn = vim.fn
local api = vim.api

local M = {}

---@param dir string
function M.may_create_dir(dir) -- This util is used by autocmds.lua, options.lua, and d2_render and notes_init below
	if fn.isdirectory(dir) == 0 then
		fn.mkdir(dir, "p")
	end
end

---@param name string
---@return boolean
function M.executable(name) -- This util is used by autocmds.lua, lazy.lua, lint.lua, lspconfig.lua, mason.lua, options.lua, shared.lua, tree-sitter-d2.lua, treesitter.lua, yazi.lua, and d2_run and notes_rg below
	return fn.executable(name) > 0
end

---Absolute path inside Mason's data directory, with the Windows layout when running there.
---@param unix string path relative to the Mason root, POSIX layout
---@param windows? string same path in the Windows layout, when it differs
---@return string
function M.mason_path(unix, windows) -- This util is used by dap-python.lua and dap.lua
	local root = fn.stdpath("data") .. "/mason/"
	return root .. ((fn.has("win32") == 1 and windows) or unix)
end

---Leading-edge throttle: calls inside the window are dropped, not queued.
---@param callback fun()
---@param ms integer
---@return fun()
function M.throttle(callback, ms) -- This util is used by lualine.lua
	local last = 0
	return function()
		local now = vim.uv.now()
		if now - last < ms then
			return
		end
		last = now
		callback()
	end
end

---@param msg string
---@param title string
local function warn(msg, title)
	vim.schedule(function()
		vim.notify(msg, vim.log.levels.WARN, { title = title })
	end)
end

---Wraps an nvim-dap adapter so its Mason file is checked when a session starts, not when nvim-dap loads.
---@param path string absolute path of the Mason-installed file
---@param label string Mason package name
---@param adapter table|function the adapter as nvim-dap takes it
---@return function
function M.mason_adapter(path, label, adapter) -- This util is used by dap.lua and dap-python.lua
	return function(callback, config, parent)
		if not vim.uv.fs_stat(path) then
			return warn(("%s not found at %s. Check :Mason or :MasonLog, then run :MasonInstall %s."):format(label, path, label), "DAP")
		end
		if type(adapter) == "function" then
			return adapter(callback, config, parent)
		end
		callback(adapter)
	end
end

---@param var_name string
---@param label string
function M.warn_if_missing_env(var_name, label) -- This util is used by avante.lua
	if (vim.env[var_name] or "") == "" then
		warn(("%s is not set; %s will fail on first use."):format(var_name, label), label)
	end
end

---@param name string executable looked up on $PATH
---@param label string
---@param hint string
---@return boolean found
function M.warn_if_missing_exec(name, label, hint) -- This util is used by hex.lua, octo.lua, treesitter.lua and yazi.lua
	if M.executable(name) then
		return true
	end
	warn(("'%s' not found on $PATH. %s"):format(name, hint), label)
	return false
end

---Augroup namespaced as "999rpm-<n>".
---@param name string
---@param clear? boolean defaults to true
---@return integer
function M.augroup(name, clear) -- This util is used by autocmds.lua, lint.lua, logseq.lua, lspconfig.lua, lualine.lua, markdown-plus.lua, nvim-bqf.lua, oil.lua and treesitter.lua
	return api.nvim_create_augroup("999rpm-" .. name:gsub("_", "-"), { clear = clear ~= false })
end

---Binds the shared list-menu navigation (Tab/S-Tab) in one buffer, matching the picker, Trouble and dropbar.
---@param buf integer
function M.menu_nav(buf) -- This util is used by harpoon.lua and nvim-bqf.lua
	vim.keymap.set("n", "<Tab>", "j", { buf = buf, desc = "Next entry" })
	vim.keymap.set("n", "<S-Tab>", "k", { buf = buf, desc = "Previous entry" })
end

---Binds q to close a throwaway window, and wipe its buffer where nothing else holds it.
---@param buf integer
---@param wipe? boolean also delete the buffer, defaults to false
function M.map_close(buf, wipe) -- This util is used by autocmds.lua and by d2_text below
	if not api.nvim_buf_is_valid(buf) then
		return -- autocmds.lua calls this through vim.schedule, and the buffer can be wiped before the callback runs
	end
	vim.keymap.set("n", "q", function()
		pcall(vim.cmd.close) -- the last window cannot close; the buffer still goes
		if wipe then
			pcall(api.nvim_buf_delete, buf, { force = true })
		end
	end, { buf = buf, silent = true, desc = "Close" })
end

local nu_shell_options = { -- nushell/integrations values, except shellpipe
	shellcmdflag = "--login --stdin --no-newline -c",
	shellredir = "out+err> %s",
	shellpipe = "| complete | update stderr { ansi strip } | tee { [$in.stdout $in.stderr] | str join | ansi strip | save --force --raw %s } | into record", -- saves stdout too, like 2>&1| tee; upstream's stderr-only save left :grep with an empty quickfix list
	shellquote = "",
	shellxquote = "",
	shellxescape = "",
	shelltemp = false,
}

local posix_shell_options = {
	shellcmdflag = "-c",
	shellredir = ">%s 2>&1",
	shellpipe = "2>&1| tee",
	shellquote = "",
	shellxquote = "",
	shellxescape = "",
	shelltemp = false,
}

local csh_shell_options = vim.tbl_extend("force", posix_shell_options, { shellpipe = "|& tee", shellredir = ">&" })

---Login shell from the passwd database (follows chsh without a new login), then $SHELL, then sh.
---@return string
function M.login_shell() -- This util is used by options.lua
	local ok, passwd = pcall(vim.uv.os_get_passwd)
	for _, shell in ipairs({ ok and passwd and passwd.shell or "", vim.env.SHELL or "" }) do
		if shell ~= "" and fn.executable(shell) == 1 then
			return shell
		end
	end
	return "sh"
end

---Set the shell* options that match 'shell': nushell values for nu, Vim's own shell-family values otherwise.
function M.apply_shell_options() -- This util is used by autocmds.lua and options.lua
	local name = fn.fnamemodify(vim.o.shell, ":t")
	local set = name == "nu" and nu_shell_options or (name:match("csh$") and csh_shell_options or posix_shell_options)
	for option, value in pairs(set) do
		vim.o[option] = value
	end
end

---Run a Lua function as a terminal-mode window move; floating windows get the key instead.
---@param dir "h"|"j"|"k"|"l"
---@param key string
---@return fun(): string
function M.term_wincmd(dir, key) -- This util is used by mappings.lua
	return function()
		if api.nvim_win_get_config(0).relative ~= "" then
			return key
		end
		return "<Cmd>wincmd " .. dir .. "<CR>"
	end
end

---Per-buffer memo keyed on b:changedtick, so a statusline component scans a buffer once per edit, not once per redraw.
---@generic T
---@param key string
---@param compute fun(): T
---@return T
function M.buf_cached(key, compute) -- This util is used by lualine.lua
	local buf = api.nvim_get_current_buf()
	local tick = api.nvim_buf_get_changedtick(buf)
	local store = vim.b[buf]._999rpm_cache or {}
	local hit = store[key]
	if hit and hit.tick == tick then
		return hit.value
	end
	local value = compute()
	store[key] = { tick = tick, value = value }
	vim.b[buf]._999rpm_cache = store -- reassigned whole: vim.b returns a copy, so mutating `store` alone does not persist
	return value
end

---@param cmd string[]
---@return string?
local function run_git(cmd)
	local out = fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		return nil
	end
	return vim.trim(out)
end

---Branch for the current buffer: gitsigns' cached head, else one cached `git rev-parse` per buffer.
---@return string
function M.get_current_branch_name() -- This util is used by options.lua
	local head = vim.tbl_get(vim.b, "gitsigns_status_dict", "head")
	if head and head ~= "" then
		return head
	end
	local cached = vim.b._999rpm_branch
	if cached == nil then
		local dir = fn.expand("%:p:h")
		cached = fn.isdirectory(dir) == 1 and (run_git({ "git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" }) or "") or ""
		if cached == "HEAD" then
			cached = run_git({ "git", "-C", dir, "rev-parse", "--short", "HEAD" }) or cached
		end
		vim.b._999rpm_branch = cached
	end
	return cached
end

---Client capabilities with folding ranges (nvim-ufo) and blink.cmp completion. Requiring blink here also runs its own
---plugin file, which merges the same completion capabilities into vim.lsp.config("*") for anything started later.
---@return lsp.ClientCapabilities
function M.get_lsp_capabilities() -- This util is used by lspconfig.lua
	local caps = vim.lsp.protocol.make_client_capabilities()
	caps.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
	local ok, blink = pcall(require, "blink.cmp")
	return ok and blink.get_lsp_capabilities(caps) or caps
end

---RainbowDelimiter groups, in rainbow-delimiters' own order. Colors follow the active theme.
---@type string[]
M.rainbow_delimiter_groups = { -- This util is used by rainbow-delimiters.lua and snacks.lua
	"RainbowDelimiterRed",
	"RainbowDelimiterYellow",
	"RainbowDelimiterBlue",
	"RainbowDelimiterOrange",
	"RainbowDelimiterGreen",
	"RainbowDelimiterViolet",
	"RainbowDelimiterCyan",
}

---Runs `apply` now and after every colorscheme change, so highlight overrides survive a theme switch.
---@param name string augroup suffix
---@param apply fun()
function M.on_colorscheme(name, apply) -- This util is used by barbar.lua, dap.lua, logseq.lua, multicursor.lua and render-markdown.lua
	apply()
	api.nvim_create_autocmd("ColorScheme", {
		group = M.augroup(name),
		desc = "999rpm: re-apply " .. name .. " after a theme switch",
		callback = apply,
	})
end

---Diagram under the cursor: the whole buffer in a d2 file, else the fenced d2 block holding the cursor.
---@return string? source
---@return string name file stem for the rendered output
local function d2_source()
	local lines = api.nvim_buf_get_lines(0, 0, -1, false)
	local stem = fn.expand("%:t:r")
	stem = stem ~= "" and stem or "untitled"
	if vim.bo.filetype == "d2" then
		return table.concat(lines, "\n"), stem
	end
	local row = api.nvim_win_get_cursor(0)[1]
	local open ---@type { row: integer, lang: string, fence: string }?
	for i, line in ipairs(lines) do
		if open then
			local close = line:match("^%s*([`~]+)%s*$")
			if close and close:sub(1, 1) == open.fence:sub(1, 1) and #close >= #open.fence then
				if open.lang == "d2" and row >= open.row and row <= i then
					return table.concat(lines, "\n", open.row + 1, i - 1), ("%s-%d"):format(stem, open.row)
				end
				open = nil
			end
		else
			local fence, lang = line:match("^%s*(```+)%s*([%w_.+-]*)")
			if not fence then
				fence, lang = line:match("^%s*(~~~+)%s*([%w_.+-]*)")
			end
			if fence then
				open = { row = i, lang = lang, fence = fence }
			end
		end
	end
	return nil, stem
end

---@param args string[]
---@param src? string diagram source; the diagram under the cursor when nil
---@param name? string file stem of the output
---@param on_done fun(stdout: string, name: string)
local function d2_run(args, src, name, on_done)
	if not M.executable("d2") then
		warn("'d2' not found on $PATH. It is one static binary: https://d2lang.com/tour/install", "d2")
		return
	end
	if not src then
		src, name = d2_source()
		if not src then
			warn("The cursor is not in a d2 file or inside a ```d2 block.", "d2")
			return
		end
	end
	local cmd = { "d2" }
	for _, arg in ipairs(args) do
		table.insert(cmd, (arg:gsub("{name}", name))) -- {name}: the output file stem
	end
	vim.system(cmd, { stdin = src, text = true }, function(res) -- argv, not a shell string, so zsh and nushell behave the same
		vim.schedule(function()
			if res.code ~= 0 then
				vim.notify(vim.trim(res.stderr ~= "" and res.stderr or res.stdout), vim.log.levels.ERROR, { title = "d2" })
				return
			end
			on_done(res.stdout, name)
		end)
	end)
end

---Renders a d2 diagram (the one under the cursor when src is nil) to PNG in a split, where snacks.image draws it.
---@param src? string
---@param name? string
function M.d2_render(src, name) -- This util is used by tree-sitter-d2.lua and notes_graph below
	local dir = fn.stdpath("cache") .. "/999rpm-d2"
	M.may_create_dir(dir)
	local theme = vim.o.background == "light" and "0" or "200" -- d2's Neutral default, or Dark Mauve on a dark background
	d2_run({ "--theme=" .. theme, "-", dir .. "/{name}.png" }, src, name, function(_, stem)
		local png = ("%s/%s.png"):format(dir, stem)
		local win = fn.bufwinid(png)
		if win ~= -1 then
			api.nvim_win_call(win, function()
				vim.cmd("edit!") -- reload the image after a re-render
			end)
		else
			vim.cmd("vsplit " .. fn.fnameescape(png))
		end
	end)
end

---Renders a d2 diagram (the one under the cursor when src is nil) as text in a split; no image protocol needed. q closes it.
---@param src? string
---@param name? string
function M.d2_text(src, name) -- This util is used by tree-sitter-d2.lua and notes_graph below
	d2_run({ "--stdout-format=txt", "-", "-" }, src, name, function(stdout)
		local buf = fn.bufnr("999rpm://d2-text")
		if buf == -1 then
			buf = api.nvim_create_buf(false, true)
			api.nvim_buf_set_name(buf, "999rpm://d2-text")
			M.map_close(buf) -- shared q binding; see map_close above
		end
		local lines = vim.split(stdout, "\n", { trimempty = true })
		vim.bo[buf].modifiable = true
		api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modifiable = false
		if fn.bufwinid(buf) == -1 then
			vim.cmd(("botright %dsplit"):format(math.min(#lines + 1, 25)))
			api.nvim_win_set_buf(0, buf)
		end
	end)
end

local MONTHS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" } -- English, as Logseq writes them, in any locale
local DAYS = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" } -- os.date("*t").wday order
local TASK_NEXT = { -- Logseq's marker cycle; LATER > NOW is its second workflow
	[""] = "TODO",
	TODO = "DOING",
	DOING = "DONE",
	DONE = "",
	LATER = "NOW",
	NOW = "DONE",
	WAITING = "DOING",
	WAIT = "DOING",
	["IN-PROGRESS"] = "DONE",
	CANCELED = "TODO",
	CANCELLED = "TODO",
}
local TASK_RANK = { DOING = 1, NOW = 1, ["IN-PROGRESS"] = 1, TODO = 2, LATER = 2, WAITING = 3, WAIT = 3 } -- task picker order

---@param msg string
local function info(msg)
	vim.notify(msg, vim.log.levels.INFO, { title = "Notes" })
end

---Root of the notes graph (vim.g.notes_dir, options.lua), with ~ expanded.
---@return string
function M.notes_root() -- This util is used by logseq.lua, auto-save.lua and img-clip.lua
	return vim.fs.normalize(vim.g.notes_dir or "~/notes")
end

---@param buf? integer
---@return boolean
function M.notes_in_vault(buf) -- This util is used by logseq.lua, auto-save.lua and img-clip.lua
	local name = api.nvim_buf_get_name(buf or 0)
	return name ~= "" and vim.fs.relpath(M.notes_root(), vim.fs.normalize(name)) ~= nil
end

---Noon of the day a phrase names: today (or nothing), yesterday, tomorrow, +N/-N days, YYYY-MM-DD, or a weekday with an
---optional "next"/"last" in front ("fri", "next monday").
---@param words? string
---@return integer? time
local function parse_date(words)
	words = vim.trim((words or ""):lower())
	local now = os.date("*t")
	local function day(offset)
		return os.time({ year = now.year, month = now.month, day = now.day + offset, hour = 12 })
	end
	if words == "" or words == "today" then
		return day(0)
	elseif words == "yesterday" then
		return day(-1)
	elseif words == "tomorrow" then
		return day(1)
	end
	local sign, count = words:match("^([+-])%s*(%d+)$")
	if count then
		return day(tonumber(count) * (sign == "-" and -1 or 1))
	end
	local y, m, d = words:match("^(%d%d%d%d)[-_/](%d%d?)[-_/](%d%d?)$")
	if y then
		return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
	end
	local parts = vim.split(words, "%s+")
	local prefix = #parts == 2 and parts[1] or ""
	local wday
	for i, name in ipairs(DAYS) do
		if parts[#parts]:sub(1, 3) == name:lower() then
			wday = i
		end
	end
	if not wday or #parts > 2 or not vim.list_contains({ "", "next", "last" }, prefix) then
		return nil
	end
	local diff = wday - now.wday
	if prefix == "next" and diff <= 0 then
		diff = diff + 7
	elseif prefix == "last" and diff >= 0 then
		diff = diff - 7
	elseif prefix == "" and diff < 0 then
		diff = diff + 7
	end
	return day(diff)
end

---Logseq's default journal title ("MMM do, yyyy"), e.g. Sep 30th, 2026.
---@param time integer
---@return string
local function journal_title(time)
	local t = os.date("*t", time)
	local d = t.day
	local suffix = (d % 10 == 1 and d ~= 11) and "st" or (d % 10 == 2 and d ~= 12) and "nd" or (d % 10 == 3 and d ~= 13) and "rd" or "th"
	return ("%s %d%s, %d"):format(MONTHS[t.month], d, suffix, t.year)
end

---@param time integer
---@return string
local function journal_path(time)
	return ("%s/journals/%s.md"):format(M.notes_root(), os.date("%Y_%m_%d", time))
end

---Title of a graph file as Logseq shows it: the journal title for journals/yyyy_MM_dd.md, else a title:: property, else
---the file name with Logseq's "___" namespace separator turned back into "/".
---@param path string
---@param lines string[] the file's first lines
---@return string
local function page_title(path, lines)
	local stem = fn.fnamemodify(path, ":t:r")
	local y, m, d = stem:match("^(%d%d%d%d)_(%d%d)_(%d%d)$")
	if y then
		return journal_title(os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 }))
	end
	for i = 1, math.min(#lines, 8) do
		local title = lines[i]:match("^%s*title::%s*(.-)%s*$")
		if title and title ~= "" then
			return title
		end
	end
	return (stem:gsub("___", "/"):gsub("%%2F", "/"))
end

---Values of the alias:: property in a page's first block.
---@param lines string[]
---@return string[]
local function page_aliases(lines)
	for i = 1, math.min(#lines, 8) do
		local list = lines[i]:match("^%s*alias::%s*(.-)%s*$")
		if list then
			local out = {}
			for alias in list:gmatch("[^,]+") do
				alias = vim.trim(alias):gsub("^%[%[(.*)%]%]$", "%1")
				if alias ~= "" then
					out[#out + 1] = alias
				end
			end
			return out
		end
	end
	return {}
end

---@param text string
---@return string text with ripgrep's regex metacharacters escaped (ASCII only, so UTF-8 names survive)
local function rg_escape(text)
	return (text:gsub("[%.%+%*%?%(%)%[%]%{%}%^%$|\\#&~%-]", "\\%0"))
end

---ripgrep over the graph's markdown files, Logseq's own logseq/ folder left out, as vimgrep rows.
---@param args string[] rg arguments, patterns included
---@param every_match? boolean keep each match of a line, for -o searches
---@return { file: string, lnum: integer, col: integer, text: string }[]
local function notes_rg(args, every_match)
	local root = M.notes_root()
	if fn.isdirectory(root) == 0 then
		return {}
	elseif not M.executable("rg") then
		warn("The notes pickers need ripgrep (rg) on $PATH.", "Notes")
		return {}
	end
	local cmd = vim.list_extend({ "rg", "--vimgrep", "--no-messages", "--glob", "*.md", "--glob", "!logseq/**" }, args)
	local res = vim.system(cmd, { text = true, cwd = root }):wait()
	local rows, seen = {}, {}
	for line in vim.gsplit(res.stdout or "", "\n", { trimempty = true }) do
		local file, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
		local key = file and (file .. ":" .. lnum)
		if file and (every_match or not seen[key]) then
			seen[key] = true
			rows[#rows + 1] = { file = vim.fs.joinpath(root, file), lnum = tonumber(lnum), col = tonumber(col), text = text }
		end
	end
	return rows
end

---File behind a page name: a journal title opens its journal, an existing page matches case-insensitively (as Logseq's
---names do), an alias:: property counts too, and anything else is a new file in pages/ with "/" written as "___".
---@param name string
---@return string
local function page_path(name)
	local root = M.notes_root()
	local mon, day, year = name:match("^(%a%a%a)%a* (%d%d?)%a%a, (%d%d%d%d)$")
	for i, abbr in ipairs(MONTHS) do
		if mon and abbr:lower() == mon:lower() then
			return journal_path(os.time({ year = tonumber(year), month = i, day = tonumber(day), hour = 12 }))
		end
	end
	local file = (name:gsub("/", "___")) .. ".md"
	for _, dir in ipairs({ root .. "/pages", root }) do
		if fn.isdirectory(dir) == 1 then
			for entry, kind in vim.fs.dir(dir) do
				if kind == "file" and entry:lower() == file:lower() then
					return dir .. "/" .. entry
				end
			end
		end
	end
	local hit = notes_rg({ "-i", "-m", "1", "-e", "^\\s*alias::.*\\b" .. rg_escape(name) .. "\\b" })[1]
	return hit and hit.file or (root .. "/pages/" .. file)
end

---ripgrep pattern for links to any of the names: [[name]], #[[name]], #name and tags:: entries.
---@param names string[]
---@return string
local function ref_pattern(names)
	local alts = {}
	for _, name in ipairs(names) do
		local e = rg_escape(name)
		vim.list_extend(alts, { "\\[\\[" .. e .. "\\]\\]", "^\\s*tags::.*\\b" .. e .. "\\b" })
		if not name:find("%s") then
			alts[#alts + 1] = "#" .. e .. "(?:[^\\w/-]|$)"
		end
	end
	return table.concat(alts, "|")
end

---Title and aliases of the current page.
---@return string[]
local function current_names()
	local lines = api.nvim_buf_get_lines(0, 0, 8, false)
	return vim.list_extend({ page_title(api.nvim_buf_get_name(0), lines) }, page_aliases(lines))
end

---@param title string
---@param rows { file: string, lnum: integer, col: integer, text: string, label?: string }[]
---@param opts? table extra snacks.picker options
local function notes_pick(title, rows, opts)
	if #rows == 0 then
		return info("Nothing found: " .. title)
	end
	local root, items = M.notes_root(), {}
	for i, row in ipairs(rows) do
		local label = row.label or vim.trim(row.text)
		items[i] = {
			idx = i,
			text = (vim.fs.relpath(root, row.file) or row.file) .. " " .. label, -- matched against the query: path and text
			line = label,
			file = row.file,
			pos = { row.lnum, math.max(row.col - 1, 0) },
			row = row,
		}
	end
	Snacks.picker.pick(vim.tbl_extend("force", { source = "999rpm_notes", title = title, items = items, format = "file" }, opts or {}))
end

---Opens a graph page; a page that does not exist yet starts as one empty bullet and stays unwritten until it gets text.
---@param path string
---@param split? boolean open in a vertical split, like Logseq's sidebar
local function open_page(path, split)
	vim.cmd((split and "vsplit " or "edit ") .. fn.fnameescape(path))
	if fn.filereadable(path) == 0 and api.nvim_buf_line_count(0) == 1 and api.nvim_get_current_line() == "" then
		api.nvim_buf_set_lines(0, 0, -1, false, { "- " })
		vim.bo.modified = false
		api.nvim_win_set_cursor(0, { 1, 2 })
	end
end

---@param words? string a date phrase (see parse_date); today when empty
function M.notes_journal(words) -- This util is used by logseq.lua
	local time = parse_date(words)
	if not time then
		return warn(("%q is not a date: try today, -1, +2, fri, next mon or 2026-10-01"):format(words), "Notes")
	end
	open_page(journal_path(time))
end

---Journal pages, newest first, under their Logseq titles.
function M.notes_journals() -- This util is used by logseq.lua
	local dir = M.notes_root() .. "/journals"
	local items = {}
	if fn.isdirectory(dir) == 1 then
		for name, kind in vim.fs.dir(dir) do
			local y, m, d = name:match("^(%d%d%d%d)_(%d%d)_(%d%d)%.md$")
			if kind == "file" and y then
				local time = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
				local label = ("%s-%s-%s %s  %s"):format(y, m, d, DAYS[os.date("*t", time).wday], journal_title(time))
				items[#items + 1] = { text = label, file = dir .. "/" .. name, date = name }
			end
		end
	end
	if #items == 0 then
		return info("No journal pages in " .. dir)
	end
	table.sort(items, function(a, b)
		return a.date > b.date
	end)
	Snacks.picker.pick({ source = "999rpm_journals", title = "Journals", items = items, format = "text", preview = "file" })
end

function M.notes_pages() -- This util is used by logseq.lua
	Snacks.picker.files({ title = "Pages", cwd = M.notes_root(), ft = "md", exclude = { "logseq" } })
end

function M.notes_search() -- This util is used by logseq.lua
	Snacks.picker.grep({ title = "Search notes", cwd = M.notes_root(), glob = "*.md", exclude = { "logseq" } })
end

function M.notes_new_page() -- This util is used by logseq.lua
	vim.ui.input({ prompt = "New page: " }, function(title)
		title = vim.trim(title or "")
		if title ~= "" then
			open_page(page_path(title))
		end
	end)
end

---Blocks that link to a page ([[page]], #page, tags::), Logseq's linked references.
---@param name? string page name; the current page and its aliases when nil
function M.notes_backlinks(name) -- This util is used by logseq.lua
	local names = name and { name } or current_names()
	local here = api.nvim_buf_get_name(0)
	local rows = vim.tbl_filter(function(row)
		return name ~= nil or row.file ~= here
	end, notes_rg({ "-i", "-e", ref_pattern(names) }))
	notes_pick("Linked references: " .. names[1], rows)
end

---Plain-text mentions of the current page that are not links yet, Logseq's unlinked references.
function M.notes_unlinked() -- This util is used by logseq.lua
	local names = current_names()
	local here = api.nvim_buf_get_name(0)
	local args = { "-i", "-w", "-F" }
	for _, name in ipairs(names) do
		vim.list_extend(args, { "-e", name })
	end
	local rows = vim.tbl_filter(function(row)
		local low = row.text:lower()
		for _, name in ipairs(names) do
			if low:find("[[" .. name:lower() .. "]]", 1, true) or low:find("#" .. name:lower(), 1, true) then
				return false
			end
		end
		return row.file ~= here
	end, notes_rg(args))
	notes_pick("Unlinked references: " .. names[1], rows)
end

---Every #tag, #[[tag]] and tags:: value in the graph with its count; picking one lists its references.
function M.notes_tags() -- This util is used by logseq.lua
	local counts = {}
	local function add(tag)
		tag = vim.trim(tag)
		if tag == "" or tag:match("^%x%x%x$") or tag:match("^%x%x%x%x%x%x$") then
			return -- hex colours, not tags
		end
		local key = tag:lower()
		counts[key] = counts[key] or { name = tag, count = 0 }
		counts[key].count = counts[key].count + 1
	end
	for _, row in ipairs(notes_rg({ "-o", "-e", [=[#\[\[[^\]]+\]\]|#\w[\w/-]*]=] }, true)) do
		add((row.text:gsub("^#%[%[", ""):gsub("%]%]$", ""):gsub("^#", "")))
	end
	for _, row in ipairs(notes_rg({ "-e", [[^\s*tags::]] })) do
		for tag in (row.text:match("tags::(.*)$") or ""):gmatch("[^,]+") do
			add((vim.trim(tag):gsub("^%[%[(.*)%]%]$", "%1"):gsub("^#", "")))
		end
	end
	local items = {}
	for _, entry in pairs(counts) do
		items[#items + 1] = { text = ("%s  (%d)"):format(entry.name, entry.count), name = entry.name, count = entry.count }
	end
	if #items == 0 then
		return info("No tags in the graph")
	end
	table.sort(items, function(a, b)
		if a.count ~= b.count then
			return a.count > b.count
		end
		return a.name:lower() < b.name:lower()
	end)
	Snacks.picker.pick({
		source = "999rpm_tags",
		title = "Tags",
		items = items,
		format = "text",
		layout = { preview = false },
		confirm = function(picker, item)
			picker:close()
			if item then
				M.notes_backlinks(item.name)
			end
		end,
	})
end

---Open tasks across the graph: DOING/NOW first, then TODO/LATER and unchecked boxes, then WAITING; newest journals first.
function M.notes_tasks() -- This util is used by logseq.lua
	local rows = notes_rg({ "-e", [=[^\s*[-*+]\s+((TODO|DOING|NOW|LATER|WAITING|WAIT|IN-PROGRESS)\b|\[ \])]=] })
	for _, row in ipairs(rows) do
		row.rank = TASK_RANK[row.text:match("^%s*[-*+]%s+([%u-]+)")] or 2 -- an unchecked box ranks with TODO
	end
	table.sort(rows, function(a, b)
		if a.rank ~= b.rank then
			return a.rank < b.rank
		elseif a.file ~= b.file then
			return a.file > b.file -- journal file names sort by date
		end
		return a.lnum < b.lnum
	end)
	notes_pick("Open tasks", rows)
end

---SCHEDULED and DEADLINE dates of unfinished tasks, soonest first; overdue dates in the error colour, today's in the
---warning colour.
function M.notes_agenda() -- This util is used by logseq.lua
	local today = os.date("%Y-%m-%d")
	local files, rows = {}, {}
	for _, row in ipairs(notes_rg({ "-e", [[(SCHEDULED|DEADLINE): <\d{4}-\d{2}-\d{2}]] })) do
		local kind, date = row.text:match("(%u+): <(%d+%-%d+%-%d+)")
		files[row.file] = files[row.file] or fn.readfile(row.file)
		local task = ""
		for l = row.lnum, 1, -1 do -- the block's first line is the date line itself or the nearest bullet above it
			local text = files[row.file][l]
			if text:match("^%s*[-*+]%s") then
				task = vim.trim((text:gsub("^%s*[-*+]%s+", "")))
				break
			end
		end
		if kind and not (task:match("^DONE") or task:match("^CANCEL")) then
			row.date, row.kind, row.task = date, kind, task
			row.label = ("%s %s %s"):format(date, kind, task)
			rows[#rows + 1] = row
		end
	end
	table.sort(rows, function(a, b)
		if a.date ~= b.date then
			return a.date < b.date
		end
		return a.kind > b.kind
	end)
	notes_pick("Agenda", rows, {
		format = function(item)
			local row = item.row
			local time =
				os.time({ year = tonumber(row.date:sub(1, 4)), month = tonumber(row.date:sub(6, 7)), day = tonumber(row.date:sub(9, 10)) })
			local hl = row.date < today and "DiagnosticError" or row.date == today and "DiagnosticWarn" or "DiagnosticInfo"
			return {
				{ ("%s %s  "):format(row.date, DAYS[os.date("*t", time).wday]), hl },
				{ row.kind == "DEADLINE" and "deadline   " or "scheduled  ", "Comment" },
				{ row.task },
			}
		end,
	})
end

---Cycles Logseq's task marker on each line of a range: none > TODO > DOING > DONE > none (LATER > NOW > DONE on the
---second workflow). With `force` the marker becomes that one, or TODO when it already is.
---@param first? integer first line (1-based), the cursor line when nil
---@param last? integer
---@param force? string marker to set, e.g. "CANCELED"
function M.notes_task_cycle(first, last, force) -- This util is used by logseq.lua
	local cursor = api.nvim_win_get_cursor(0)
	first = first or cursor[1]
	last = last or first
	local lines = api.nvim_buf_get_lines(0, first - 1, last, false)
	for i, line in ipairs(lines) do
		local lead, rest = line:match("^(%s*[-*+]%s+)(.*)$")
		if not lead then
			lead, rest = line:match("^(%s*)(.*)$")
		end
		local marker, text = rest:match("^([%u-]+)%s+(.*)$")
		if not (marker and TASK_NEXT[marker]) then
			marker, text = TASK_NEXT[rest] and rest or "", TASK_NEXT[rest] and "" or rest
		end
		local next_marker = force and (marker == force and "TODO" or force) or TASK_NEXT[marker]
		lines[i] = lead .. (next_marker ~= "" and (next_marker .. " ") or "") .. text
		if first + i - 1 == cursor[1] and cursor[2] >= #lead then
			cursor[2] = math.max(#lead, cursor[2] + #lines[i] - #line)
		end
	end
	api.nvim_buf_set_lines(0, first - 1, last, false, lines)
	pcall(api.nvim_win_set_cursor, 0, cursor)
end

---Adds or replaces the block's SCHEDULED or DEADLINE line, in Logseq's "<2026-10-01 Thu>" form, from a date phrase.
---@param kind "SCHEDULED"|"DEADLINE"
function M.notes_task_date(kind) -- This util is used by logseq.lua
	local buf = api.nvim_get_current_buf()
	local row = api.nvim_win_get_cursor(0)[1]
	vim.ui.input({ prompt = kind .. " (today, +3, fri, 2026-10-01): " }, function(words)
		local time = words and parse_date(words)
		if not time then
			return words and warn(("%q is not a date"):format(words), "Notes")
		end
		local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
		local block = row
		while block > 1 and not lines[block]:match("^%s*[-*+]%s") do
			block = block - 1
		end
		local indent = lines[block]:match("^%s*")
		local stamp = ("%s  %s: <%s %s>"):format(indent, kind, os.date("%Y-%m-%d", time), DAYS[os.date("*t", time).wday])
		local l = block + 1
		while lines[l] and not lines[l]:match("^%s*[-*+]%s") and #lines[l]:match("^%s*") > #indent do
			if lines[l]:match("^%s*" .. kind .. ":") then
				return api.nvim_buf_set_lines(buf, l - 1, l, false, { stamp })
			end
			l = l + 1
		end
		api.nvim_buf_set_lines(buf, block, block, false, { stamp })
	end)
end

---Logseq's template variables: <% today %>, <% yesterday %>, <% tomorrow %>, <% time %>, <% current page %>.
---@param line string
---@param title string current page title
---@return string
local function fill_template(line, title)
	return (
		line:gsub("<%%%s*(.-)%s*%%>", function(var)
			var = var:lower()
			if var == "today" or var == "yesterday" or var == "tomorrow" then
				return "[[" .. journal_title(parse_date(var)) .. "]]"
			elseif var == "time" then
				return os.date("%H:%M")
			elseif var == "current page" then
				return "[[" .. title .. "]]"
			end
		end)
	)
end

---Inserts the children of a template:: block (the block itself too with template-including-parent:: true) under the
---cursor line, re-indented to it; an empty bullet on the cursor line is replaced.
---@param row { file: string, lnum: integer, label?: string }
---@param buf integer
---@param win integer
local function insert_template(row, buf, win)
	local lines = fn.readfile(row.file)
	local block = row.lnum - 1
	while block >= 1 and not lines[block]:match("^%s*[-*+]%s") do
		block = block - 1
	end
	if block < 1 then
		return warn("template:: has no block above it in " .. row.file, "Notes")
	end
	local base = #lines[block]:match("^%s*")
	local with_parent = false
	local l = block + 1
	while lines[l] and lines[l]:match("^%s*[%w_-]+::") and #lines[l]:match("^%s*") > base do -- the block's own properties
		with_parent = with_parent or lines[l]:match("template%-including%-parent::%s*true") ~= nil
		l = l + 1
	end
	local body = with_parent and { lines[block] } or {}
	while lines[l] and (lines[l]:match("^%s*$") or #lines[l]:match("^%s*") > base) do
		body[#body + 1] = lines[l]
		l = l + 1
	end
	while #body > 0 and body[#body]:match("^%s*$") do
		body[#body] = nil
	end
	if #body == 0 then
		return warn(("Template %s has no content"):format(row.label or ""), "Notes")
	end
	local cursor = api.nvim_win_get_cursor(win)[1]
	local current = api.nvim_buf_get_lines(buf, cursor - 1, cursor, false)[1]
	local indent, strip = current:match("^%s*"), body[1]:match("^%s*")
	local title = page_title(api.nvim_buf_get_name(buf), api.nvim_buf_get_lines(buf, 0, 8, false))
	for i, line in ipairs(body) do
		line = line:sub(1, #strip) == strip and line:sub(#strip + 1) or line:gsub("^%s+", "")
		body[i] = line ~= "" and (indent .. fill_template(line, title)) or ""
	end
	api.nvim_buf_set_lines(buf, current:match("^%s*[-*+]%s*$") and cursor - 1 or cursor, cursor, false, body)
end

---Blocks marked template:: anywhere in the graph; the picked one is inserted under the cursor.
function M.notes_template() -- This util is used by logseq.lua
	local rows = notes_rg({ "-e", [[^\s*template::\s*\S]] })
	for _, row in ipairs(rows) do
		row.label = row.text:match("template::%s*(.-)%s*$")
	end
	local buf, win = api.nvim_get_current_buf(), api.nvim_get_current_win()
	notes_pick("Templates", rows, {
		confirm = function(picker, item)
			picker:close()
			if item then
				insert_template(item.row, buf, win)
			end
		end,
	})
end

---Moves the list item under the cursor, children included, past its previous or next sibling (Logseq's
---Alt+Shift+Up/Down); the first and last child stay put. Outside a list the line moves on its own.
---@param dir 1|-1
function M.notes_move_block(dir) -- This util is used by logseq.lua
	local cursor = api.nvim_win_get_cursor(0)
	local line = api.nvim_get_current_line()
	local ok, parser = pcall(vim.treesitter.get_parser, 0, "markdown")
	local node
	if ok and parser then
		parser:parse()
		node = vim.treesitter.get_node({ lang = "markdown", pos = { cursor[1] - 1, #line:match("^%s*") }, ignore_injections = true })
		while node and node:type() ~= "list_item" do
			node = node:parent()
		end
	end
	if not node then
		return pcall(vim.cmd, dir > 0 and "move+" or "move-2")
	end
	local sibling = dir > 0 and node:next_named_sibling() or node:prev_named_sibling()
	if not (sibling and sibling:type() == "list_item") then
		return
	end
	local function rows(n)
		local s, _, e, ec = n:range()
		return s, ec == 0 and e - 1 or e -- inclusive last row
	end
	local a_s, a_e = rows(node)
	local b_s, b_e = rows(sibling)
	local top_s, top_e, bot_s, bot_e = a_s, a_e, b_s, b_e
	if dir < 0 then
		top_s, top_e, bot_s, bot_e = b_s, b_e, a_s, a_e
	end
	local function get(s, e)
		return api.nvim_buf_get_lines(0, s, e + 1, false)
	end
	local top, mid, bot = get(top_s, top_e), get(top_e + 1, bot_s - 1), get(bot_s, bot_e)
	local swapped = vim.list_extend(vim.list_extend(vim.list_extend({}, bot), mid), top) -- a new list: bot and mid are counted below
	api.nvim_buf_set_lines(0, top_s, bot_e + 1, false, swapped)
	local start = dir > 0 and (top_s + #bot + #mid) or top_s
	api.nvim_win_set_cursor(0, { start + cursor[1] - 1 - a_s + 1, cursor[2] })
end

---Folds every block away except the path to the cursor and the cursor's own block, which opens fully (Logseq's zoom-in).
function M.notes_focus() -- This util is used by logseq.lua
	if package.loaded.ufo then
		require("ufo").closeAllFolds()
	else
		vim.cmd("normal! zM")
	end
	pcall(vim.cmd, "normal! zv")
	pcall(vim.cmd, "normal! zO") -- E490 when the block has no children
end

---Opens every fold again (Logseq's zoom-out).
function M.notes_unfocus() -- This util is used by logseq.lua
	if package.loaded.ufo then
		require("ufo").openAllFolds()
	else
		vim.cmd("normal! zR")
	end
end

---Follows the [[page]], #tag or ((block ref)) under the cursor, creating a missing page the way Logseq does; anything
---else goes to the built-in gf.
---@param split? boolean open in a vertical split, like Logseq's sidebar
function M.notes_follow(split) -- This util is used by logseq.lua
	local line = api.nvim_get_current_line()
	local col = api.nvim_win_get_cursor(0)[2] + 1
	local function under(pattern)
		local init = 1
		while true do
			local s, e, capture = line:find(pattern, init)
			if not s then
				return nil
			elseif col >= s and col <= e then
				return capture
			end
			init = e + 1
		end
	end
	local ref = under("%(%(([%x%-]+)%)%)")
	if ref then
		local hit = notes_rg({ "-i", "-e", "^\\s*id::\\s*" .. ref .. "\\s*$" })[1]
		if not hit then
			return warn("No block carries id:: " .. ref, "Notes")
		end
		vim.cmd((split and "vsplit " or "edit ") .. fn.fnameescape(hit.file))
		return api.nvim_win_set_cursor(0, { math.max(hit.lnum - 1, 1), 0 }) -- the block line sits right above its id::
	end
	local name = under("#?%[%[(.-)%]%]") or under("%f[#]#([%w_][%w_/%-]*)")
	if name then
		return open_page(page_path((name:gsub("|.*$", ""))), split)
	end
	local ok, err = pcall(vim.cmd, split and "wincmd f" or "normal! gf")
	if not ok then
		warn(err, "Notes")
	end
end

---Local link graph of the current page (pages it links to, pages linking to it), drawn by d2 as a PNG that snacks.image
---shows, or as box-drawing text.
---@param as_text? boolean
function M.notes_graph(as_text) -- This util is used by logseq.lua
	local here = api.nvim_buf_get_name(0)
	local lines = api.nvim_buf_get_lines(0, 0, -1, false)
	local title = page_title(here, lines)
	local outgoing, incoming = { seen = { [title:lower()] = true } }, { seen = { [title:lower()] = true } }
	local function add(list, name)
		name = vim.trim(name)
		if name ~= "" and not list.seen[name:lower()] and #list < 40 then -- past ~40 nodes a side the drawing stops being readable
			list.seen[name:lower()] = true
			list[#list + 1] = name
		end
	end
	for _, line in ipairs(lines) do
		for name in line:gmatch("%[%[(.-)%]%]") do
			add(outgoing, (name:gsub("|.*$", "")))
		end
		for tag in line:gmatch("%f[#]#([%w_][%w_/%-]*)") do
			add(outgoing, tag)
		end
	end
	for _, row in ipairs(notes_rg({ "-i", "-e", ref_pattern(current_names()) })) do
		if row.file ~= here then
			add(incoming, page_title(row.file, fn.readfile(row.file, "", 8)))
		end
	end
	if #outgoing + #incoming == 0 then
		return info("No links to or from " .. title)
	end
	local function q(text)
		return '"' .. text:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
	end
	local src = { "direction: right", q(title) .. ": {", "  style.bold: true", "  style.stroke-width: 3", "}" }
	for _, name in ipairs(incoming) do
		src[#src + 1] = q(name) .. " -> " .. q(title)
	end
	for _, name in ipairs(outgoing) do
		src[#src + 1] = q(title) .. " -> " .. q(name)
	end
	local stem = "graph-" .. fn.fnamemodify(here, ":t:r")
	local render = as_text and M.d2_text or M.d2_render
	render(table.concat(src, "\n"), stem)
end

---Commits every change in the graph folder when it is a git repository (Logseq's git auto commit, on demand).
function M.notes_commit() -- This util is used by logseq.lua
	local root = M.notes_root()
	if not vim.uv.fs_stat(root .. "/.git") then
		return warn(root .. " is not a git repository; run `git init` there first.", "Notes")
	end
	vim.system({ "git", "-C", root, "add", "--all" }, { text = true }, function(add)
		if add.code ~= 0 then
			return warn(vim.trim(add.stderr or ""), "Notes")
		end
		local msg = "999rpm: notes " .. os.date("%Y-%m-%d %H:%M")
		vim.system({ "git", "-C", root, "commit", "--quiet", "-m", msg }, { text = true }, function(res)
			if res.code == 0 then
				return vim.schedule(function()
					info("Committed: " .. msg)
				end)
			end
			local out = vim.trim((res.stdout or "") .. (res.stderr or ""))
			warn(out:find("nothing to commit", 1, true) and "Nothing to commit" or out, "Notes")
		end)
	end)
end

---Creates journals/, pages/ and assets/ in the graph folder.
function M.notes_init() -- This util is used by logseq.lua
	local root = M.notes_root()
	for _, sub in ipairs({ "journals", "pages", "assets" }) do
		M.may_create_dir(root .. "/" .. sub)
	end
	info("Graph folders ready in " .. root)
end

---Active Python virtual environment (venv before conda), or "".
---@return string
function M.get_virtual_env() -- This util is used by lualine.lua
	local venv = os.getenv("VIRTUAL_ENV")
	if venv then
		return fn.fnamemodify(venv, ":t")
	end
	return os.getenv("CONDA_DEFAULT_ENV") or ""
end

return M
