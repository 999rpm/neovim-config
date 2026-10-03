-- Logseq-style notes graph on plain markdown: journals, pages, links, references, tags, tasks, agenda, templates,
-- block moves, focus, the link graph and git commits. The graph folder is vim.g.notes_dir (options.lua) and keeps
-- Logseq's layout: journals/yyyy_MM_dd.md, pages/, assets/.
local fn = vim.fn
local api = vim.api
local core = require("utils.core")

local M = {}

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

---@param msg string
local function warn(msg)
	core.warn(msg, "Notes")
end

---Root of the graph (vim.g.notes_dir, options.lua), with ~ expanded.
---@return string
function M.root() -- This util is used by img-clip.lua and the helpers below
	return vim.fs.normalize(vim.g.notes_dir or "~/notes")
end

---A page of the graph: a .md file under the graph folder, a symlinked folder included. Notebooks open as markdown
---too, but stay .ipynb files and are not pages.
---@param buf? integer
---@return boolean
function M.is_page(buf) -- This util is used by auto-save.lua, img-clip.lua and logseq.lua
	local name = api.nvim_buf_get_name(buf or 0)
	if not name:match("%.md$") then
		return false
	end
	local root, path = M.root(), vim.fs.normalize(name)
	if vim.fs.relpath(root, path) then
		return true
	end
	local real_root, real_dir = vim.uv.fs_realpath(root), vim.uv.fs_realpath(vim.fs.dirname(path))
	return real_root ~= nil and real_dir ~= nil and vim.fs.relpath(real_root, real_dir) ~= nil
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
		local time = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
		local back = os.date("*t", time)
		return (back.month == tonumber(m) and back.day == tonumber(d)) and time or nil -- os.time would roll 2026-02-31 into March
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
	local suffix = (d % 10 == 1 and d ~= 11) and "st"
		or (d % 10 == 2 and d ~= 12) and "nd"
		or (d % 10 == 3 and d ~= 13) and "rd"
		or "th"
	return ("%s %d%s, %d"):format(MONTHS[t.month], d, suffix, t.year)
end

---@param time integer
---@return string
local function journal_path(time)
	return ("%s/journals/%s.md"):format(M.root(), os.date("%Y_%m_%d", time))
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
	local root = M.root()
	if fn.isdirectory(root) == 0 then
		return {}
	elseif not core.executable("rg") then
		warn("The notes pickers need ripgrep (rg) on $PATH.")
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
			rows[#rows + 1] =
				{ file = vim.fs.joinpath(root, file), lnum = tonumber(lnum), col = tonumber(col), text = text }
		end
	end
	return rows
end

---File behind a page name: a journal title opens its journal, an existing page matches case-insensitively (as Logseq's
---names do), an alias:: property counts too, and anything else is a new file in pages/ with "/" written as "___".
---@param name string
---@return string
local function page_path(name)
	local root = M.root()
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
	local root, items = M.root(), {}
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
	Snacks.picker.pick(
		vim.tbl_extend("force", { source = "999rpm_notes", title = title, items = items, format = "file" }, opts or {})
	)
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
function M.journal(words) -- This util is used by logseq.lua
	local time = parse_date(words)
	if not time then
		return warn(("%q is not a date: try today, -1, +2, fri, next mon or 2026-10-01"):format(words or ""))
	end
	open_page(journal_path(time))
end

---Journal pages, newest first, under their Logseq titles.
function M.journals() -- This util is used by logseq.lua
	local dir = M.root() .. "/journals"
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
	Snacks.picker.pick({
		source = "999rpm_journals",
		title = "Journals",
		items = items,
		format = "text",
		preview = "file",
	})
end

function M.pages() -- This util is used by logseq.lua
	Snacks.picker.files({ title = "Pages", cwd = M.root(), ft = "md", exclude = { "logseq" } })
end

function M.search() -- This util is used by logseq.lua
	Snacks.picker.grep({ title = "Search notes", cwd = M.root(), glob = "*.md", exclude = { "logseq" } })
end

function M.new_page() -- This util is used by logseq.lua
	vim.ui.input({ prompt = "New page: " }, function(title)
		title = vim.trim(title or "")
		if title ~= "" then
			open_page(page_path(title))
		end
	end)
end

---Blocks that link to a page ([[page]], #page, tags::), Logseq's linked references.
---@param name? string page name; the current page and its aliases when nil
function M.backlinks(name) -- This util is used by logseq.lua and tags below
	local names = name and { name } or current_names()
	local here = api.nvim_buf_get_name(0)
	local rows = vim.tbl_filter(function(row)
		return name ~= nil or row.file ~= here
	end, notes_rg({ "-i", "-e", ref_pattern(names) }))
	notes_pick("Linked references: " .. names[1], rows)
end

---Plain-text mentions of the current page that are not links yet, Logseq's unlinked references.
function M.unlinked() -- This util is used by logseq.lua
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
function M.tags() -- This util is used by logseq.lua
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
		items[#items + 1] =
			{ text = ("%s  (%d)"):format(entry.name, entry.count), name = entry.name, count = entry.count }
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
				M.backlinks(item.name)
			end
		end,
	})
end

---Open tasks across the graph: DOING/NOW first, then TODO/LATER and unchecked boxes, then WAITING; newest journals first.
function M.tasks() -- This util is used by logseq.lua
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
function M.agenda() -- This util is used by logseq.lua
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
			local time = os.time({
				year = tonumber(row.date:sub(1, 4)),
				month = tonumber(row.date:sub(6, 7)),
				day = tonumber(row.date:sub(9, 10)),
			})
			local hl = row.date < today and "DiagnosticError"
				or row.date == today and "DiagnosticWarn"
				or "DiagnosticInfo"
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
function M.task_cycle(first, last, force) -- This util is used by logseq.lua
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
function M.task_date(kind) -- This util is used by logseq.lua
	local buf = api.nvim_get_current_buf()
	local row = api.nvim_win_get_cursor(0)[1]
	vim.ui.input({ prompt = kind .. " (today, +3, fri, 2026-10-01): " }, function(words)
		local time = words and parse_date(words)
		if not time then
			return words and warn(("%q is not a date"):format(words))
		end
		local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
		local block = row
		while block > 1 and not lines[block]:match("^%s*[-*+]%s") do
			block = block - 1
		end
		local indent = lines[block]:match("^%s*")
		local stamp = ("%s  %s: <%s %s>"):format(
			indent,
			kind,
			os.date("%Y-%m-%d", time),
			DAYS[os.date("*t", time).wday]
		)
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
		return warn("template:: has no block above it in " .. row.file)
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
		return warn(("Template %s has no content"):format(row.label or ""))
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
function M.template() -- This util is used by logseq.lua
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
function M.move_block(dir) -- This util is used by logseq.lua
	local cursor = api.nvim_win_get_cursor(0)
	local line = api.nvim_get_current_line()
	local ok, parser = pcall(vim.treesitter.get_parser, 0, "markdown")
	local node
	if ok and parser then
		parser:parse()
		node = vim.treesitter.get_node({
			lang = "markdown",
			pos = { cursor[1] - 1, #line:match("^%s*") },
			ignore_injections = true,
		})
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
function M.focus() -- This util is used by logseq.lua
	if package.loaded.ufo then
		require("ufo").closeAllFolds()
	else
		vim.cmd("normal! zM")
	end
	pcall(vim.cmd, "normal! zv")
	pcall(vim.cmd, "normal! zO") -- E490 when the block has no children
end

---Opens every fold again (Logseq's zoom-out).
function M.unfocus() -- This util is used by logseq.lua
	if package.loaded.ufo then
		require("ufo").openAllFolds()
	else
		vim.cmd("normal! zR")
	end
end

---Follows the [[page]], #tag or ((block ref)) under the cursor, creating a missing page the way Logseq does; anything
---else goes to the built-in gf.
---@param split? boolean open in a vertical split, like Logseq's sidebar
function M.follow(split) -- This util is used by logseq.lua
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
			return warn("No block carries id:: " .. ref)
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
		warn(err)
	end
end

---Local link graph of the current page (pages it links to, pages linking to it), drawn by d2 as a PNG that snacks.image
---shows, or as box-drawing text.
---@param as_text? boolean
function M.graph(as_text) -- This util is used by logseq.lua
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
	local d2 = require("utils.d2")
	local render = as_text and d2.text or d2.render
	render(table.concat(src, "\n"), "graph-" .. fn.fnamemodify(here, ":t:r"))
end

---Commits every change in the graph folder when it is a git repository (Logseq's git auto commit, on demand).
function M.commit() -- This util is used by logseq.lua
	local root = M.root()
	if not vim.uv.fs_stat(root .. "/.git") then
		return warn(root .. " is not a git repository; run `git init` there first.")
	end
	vim.system({ "git", "-C", root, "add", "--all" }, { text = true }, function(add)
		if add.code ~= 0 then
			return warn(vim.trim(add.stderr or ""))
		end
		local msg = "999rpm: notes " .. os.date("%Y-%m-%d %H:%M")
		vim.system({ "git", "-C", root, "commit", "--quiet", "-m", msg }, { text = true }, function(res)
			if res.code == 0 then
				return vim.schedule(function()
					info("Committed: " .. msg)
				end)
			end
			local out = vim.trim((res.stdout or "") .. (res.stderr or ""))
			warn(out:find("nothing to commit", 1, true) and "Nothing to commit" or out)
		end)
	end)
end

---Creates journals/, pages/ and assets/ in the graph folder.
function M.init() -- This util is used by logseq.lua
	local root = M.root()
	for _, sub in ipairs({ "journals", "pages", "assets" }) do
		core.may_create_dir(root .. "/" .. sub)
	end
	info("Graph folders ready in " .. root)
end

return M
