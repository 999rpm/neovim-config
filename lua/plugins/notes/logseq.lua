-- 999rpm-notes: Logseq-style notes on plain markdown, built on markdown-oxide (links, backlinks, completion, rename),
-- snacks pickers, mini.hipatterns and utils/notes.lua. The graph lives in vim.g.notes_dir (options.lua) and keeps
-- Logseq's layout, so the Logseq app still opens the same folder: journals/yyyy_MM_dd.md, pages/, assets/. Commands:
-- :Journal [date], :NotesInit (creates the folders). Owns <leader>n, and in graph buffers gf, <C-w>f, <C-CR> and
-- <M-j>/<M-k>.
-- Built-in keys that matter here: gd or <C-]> jump to a link target through markdown-oxide and <C-o> comes back, grr
-- lists references, grn renames a page or heading across the graph, gra offers "create file" on a missing link, K
-- previews a link, gO lists the headings, ]]/[[ next/previous heading, za/zc/zo toggle/close/open a block, zM/zR every
-- block, >>/<< and insert-mode <C-t>/<C-d> indent/dedent a line.
local function notes(name, ...)
	local args = { n = select("#", ...), ... } -- the count keeps leading nils, which # and a bare unpack drop
	return function()
		require("utils.notes")[name](unpack(args, 1, args.n))
	end
end

local function selected_lines(force)
	return function()
		local first, last = vim.fn.line("v"), vim.fn.line(".")
		require("utils.notes").task_cycle(math.min(first, last), math.max(first, last), force)
		vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
	end
end

local function marker(word, group)
	return { pattern = "^%s*[-*+]%s+()" .. word .. "()%f[%s%z]", group = group }
end

local highlighters = { -- Lua patterns; the empty captures () bound the highlighted part
	todo = marker("TODO", "999rpmNotesTodo"),
	later = marker("LATER", "999rpmNotesTodo"),
	doing = marker("DOING", "999rpmNotesDoing"),
	now = marker("NOW", "999rpmNotesDoing"),
	in_progress = marker("IN%-PROGRESS", "999rpmNotesDoing"),
	waiting = marker("WAITING", "999rpmNotesWaiting"),
	wait = marker("WAIT", "999rpmNotesWaiting"),
	done = marker("DONE", "999rpmNotesDone"),
	done_text = { pattern = "^%s*[-*+]%s+DONE%s+().+()", group = "999rpmNotesClosed" },
	canceled = { pattern = "^%s*[-*+]%s+()CANCEL+ED%s.*()", group = "999rpmNotesClosed" }, -- CANCELED and CANCELLED
	property = { pattern = "^%s*()[%w_%-]+::()", group = "999rpmNotesProperty" },
	scheduled = { pattern = "^%s*()SCHEDULED:()", group = "999rpmNotesDate" },
	deadline = { pattern = "^%s*()DEADLINE:()", group = "999rpmNotesDeadline" },
	date = { pattern = "()<%d%d%d%d%-%d%d%-%d%d[^>]*>()", group = "999rpmNotesDate" },
	priority = { pattern = "()%[#[ABC]%]()", group = "999rpmNotesPriority" },
	block_ref = { pattern = "()%(%([%x%-]+%)%)()", group = "999rpmNotesRef" },
	tag = { pattern = "^()#[%w_][%w_/%-]*()", group = "999rpmNotesTag" },
	tag_inline = { pattern = "%s()#[%w_][%w_/%-]*()", group = "999rpmNotesTag" },
	tag_page = { pattern = "()#%[%[.-%]%]()", group = "999rpmNotesTag" },
	macro = { pattern = "(){{.-}}()", group = "999rpmNotesMacro" }, -- {{query}}, {{embed}} and the other Logseq macros
}

local function paint()
	local function fg(name)
		return vim.api.nvim_get_hl(0, { name = name, link = false }).fg
	end
	local set = vim.api.nvim_set_hl
	set(0, "999rpmNotesTodo", { fg = fg("DiagnosticInfo"), bold = true })
	set(0, "999rpmNotesDoing", { fg = fg("DiagnosticWarn"), bold = true })
	set(0, "999rpmNotesWaiting", { fg = fg("DiagnosticHint"), bold = true })
	set(0, "999rpmNotesDone", { fg = fg("DiagnosticOk"), bold = true })
	set(0, "999rpmNotesClosed", { fg = fg("Comment"), strikethrough = true })
	set(0, "999rpmNotesPriority", { fg = fg("DiagnosticWarn"), bold = true })
	set(0, "999rpmNotesProperty", { link = "@property" })
	set(0, "999rpmNotesDate", { link = "DiagnosticInfo" })
	set(0, "999rpmNotesDeadline", { link = "DiagnosticError" })
	set(0, "999rpmNotesRef", { link = "@markup.link" })
	set(0, "999rpmNotesTag", { link = "@markup.link.label" })
	set(0, "999rpmNotesMacro", { link = "@function.macro" })
end

---Graph-only setup for one markdown buffer: highlights, indentation, and the buffer keys listed in the header.
local function attach(buf)
	if vim.b[buf]._999rpm_notes or not require("utils.notes").is_page(buf) then -- is_page leaves notebooks out
		return
	end
	vim.b[buf]._999rpm_notes = true
	vim.b[buf].disable_autoformat = true -- prettier would rewrite the outline and the key:: value lines
	vim.b[buf].disable_lint = true -- markdownlint flags the outline format on nearly every line
	local spaced = false
	for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 300, false)) do
		spaced = spaced or line:match("^ +[-*+]%s") ~= nil
	end
	vim.bo[buf].expandtab = spaced -- Logseq indents with tabs; a page already indented with spaces keeps them
	vim.b[buf].minihipatterns_config = { highlighters = highlighters }
	local ok, hipatterns = pcall(require, "mini.hipatterns") -- mini.lua may be gone; the keys below work without colours
	if ok then
		hipatterns.disable(buf) -- again, so the buffer's own highlighters above replace the global ones
		hipatterns.enable(buf)
	end
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buf = buf, desc = desc })
	end
	map("n", "gf", notes("follow", false), "Follow link, tag or block ref (else built-in gf)") -- n: upgrades built-in gf: also [[page]], #tag and ((block ref)), creating a missing page; elsewhere the built-in, count included
	map("n", "<C-w>f", notes("follow", true), "Follow link in a vertical split (else built-in)") -- n: upgrades built-in <C-w>f: a link opens in a vertical split, as Logseq's sidebar; elsewhere the built-in split
	map({ "n", "i" }, "<C-CR>", notes("task_cycle"), "Cycle task marker") -- n/i: Ctrl+Enter, the line's marker: none, TODO, DOING, DONE in turn
	map("n", "<M-j>", notes("move_block", 1), "Move bullet and children down") -- n: Alt+j swaps the bullet, children included, with the next one; mappings.lua's Alt+j elsewhere
	map("n", "<M-k>", notes("move_block", -1), "Move bullet and children up") -- n: Alt+k, the same upwards
end

return {
	"999rpm-notes", -- a name with no slash: lazy.nvim looks for no repository
	virtual = true, -- and adds no rtp entry; the code is utils/notes.lua
	ft = "markdown",
	cmd = { "Journal", "NotesInit" },
	keys = {
		{ "<leader>nn", notes("journal"), desc = "Today's journal" }, -- n: open today's journal page, a new one with one empty bullet
		{
			"<leader>nd",
			function()
				vim.ui.input({ prompt = "Journal for (today, -1, +2, fri, next mon, 2026-10-01): " }, function(words)
					if words then
						require("utils.notes").journal(words)
					end
				end)
			end,
			desc = "Journal for a date",
		}, -- n: type today, -1, +2, fri, next mon or 2026-10-01
		{ "<leader>nj", notes("journals"), desc = "Journals" }, -- n: every journal page in a picker, newest first
		{ "<leader>np", notes("pages"), desc = "Pages" }, -- n: the graph's pages in a file picker
		{ "<leader>nN", notes("new_page"), desc = "New page" }, -- n: type a name; the page starts as one empty bullet
		{ "<leader>ns", notes("search"), desc = "Search notes" }, -- n: live grep over the graph's text
		{ "<leader>nb", notes("backlinks"), desc = "Linked references" }, -- n: blocks that link to this page (b for backlinks)
		{ "<leader>nu", notes("unlinked"), desc = "Unlinked references" }, -- n: plain mentions of this page's name that are not links yet
		{ "<leader>nt", notes("tasks"), desc = "Open tasks" }, -- n: TODO, DOING, NOW, LATER and WAITING across the graph, active ones first
		{ "<leader>na", notes("agenda"), desc = "Agenda (scheduled, deadlines)" }, -- n: dates of open tasks, soonest first, overdue ones in red
		{ "<leader>nT", notes("tags"), desc = "Tags" }, -- n: every tag with its count; picking one lists the blocks that use it
		{ "<leader>nx", notes("task_cycle"), desc = "Cycle task: TODO > DOING > DONE" }, -- n: the next marker for this line, none after DONE
		{ "<leader>nx", selected_lines(), mode = "x", desc = "Cycle task on each line" }, -- x: the same on every selected line
		{ "<leader>nX", notes("task_cycle", nil, nil, "CANCELED"), desc = "Cancel task" }, -- n: CANCELED, or TODO again on a canceled task
		{ "<leader>nX", selected_lines("CANCELED"), mode = "x", desc = "Cancel task on each line" }, -- x: the same on every selected line
		{ "<leader>nS", notes("task_date", "SCHEDULED"), desc = "Schedule" }, -- n: add or change the block's SCHEDULED date from a typed phrase
		{ "<leader>nD", notes("task_date", "DEADLINE"), desc = "Deadline" }, -- n: the same for its DEADLINE
		{ "<leader>ni", notes("template"), desc = "Insert template" }, -- n: pick a template:: block; its children land under the cursor
		{ "<leader>nz", notes("focus"), desc = "Focus block (zoom in)" }, -- n: fold away all but the cursor's block and the path to it
		{ "<leader>nZ", notes("unfocus"), desc = "Unfold all (zoom out)" }, -- n: every fold open again
		{ "<leader>ng", notes("graph", false), desc = "Link graph (image)" }, -- n: pages linking here and pages linked from here, drawn by d2
		{ "<leader>nG", notes("graph", true), desc = "Link graph (text)" }, -- n: the same as box-drawing text, uppercase twin of ng
		{ "<leader>nc", notes("commit"), desc = "Commit the graph (git)" }, -- n: git add and commit everything in the graph folder
	},
	config = function()
		local core = require("utils.core")
		core.on_colorscheme("notes-highlights", paint)
		vim.api.nvim_create_autocmd("FileType", {
			group = core.augroup("notes"),
			pattern = "markdown",
			desc = "999rpm: notes keys, highlights and indentation in graph buffers",
			callback = function(ev)
				attach(ev.buf)
			end,
		})
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
				attach(buf) -- the buffer whose FileType loaded this spec
			end
		end
		vim.api.nvim_create_user_command("Journal", function(o)
			require("utils.notes").journal(o.args)
		end, { nargs = "*", desc = "Open the journal for a date (today when empty)" })
		vim.api.nvim_create_user_command("NotesInit", notes("init"), { desc = "Create journals/, pages/ and assets/" })
	end,
}
