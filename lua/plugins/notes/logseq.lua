-- 999rpm-notes: Logseq-style notes on plain markdown, built on markdown-oxide (links, backlinks, completion, rename),
-- snacks pickers, mini.hipatterns and the notes_* helpers in utils.lua. The graph lives in vim.g.notes_dir (options.lua)
-- and keeps Logseq's layout, so the Logseq app still opens the same folder: journals/yyyy_MM_dd.md, pages/, assets/.
-- Keys (<leader>n): n today's journal, d journal for a date (today, -1, +2, fri, next mon, 2026-10-01), j journals,
-- p pages, N new page, s search the text, b linked references, u unlinked references, t open tasks, a agenda
-- (scheduled and deadline dates), T tags, x cycle TODO > DOING > DONE (visual: every selected line), X cancel a task,
-- S/D set SCHEDULED/DEADLINE, i insert a template, z focus the block (zoom in), Z unfold everything (zoom out),
-- g/G link graph as an image/as text, c commit the graph folder with git.
-- In graph buffers: gf follows the [[page]], #tag or ((block ref)) under the cursor and creates a missing page,
-- <C-w>f does the same in a vertical split (Logseq's sidebar), <C-CR> cycles the task marker in normal and insert mode,
-- <M-j>/<M-k> move a bullet together with its children. Commands: :Journal [date], :NotesInit (creates the folders).
-- Built-in keys that matter here: gd or <C-]> jump to a link target through markdown-oxide and <C-o> comes back, grr
-- lists references, grn renames a page or heading across the graph, gra offers "create file" on a missing link, K
-- previews a link, gO lists the headings, ]]/[[ next/previous heading, za/zc/zo toggle/close/open a block, zM/zR every
-- block, >>/<< and insert-mode <C-t>/<C-d> indent/dedent a line.
local function util(name, ...)
	local args = { ... }
	return function()
		require("utils")[name](unpack(args))
	end
end

local function selected_lines(force)
	return function()
		local first, last = vim.fn.line("v"), vim.fn.line(".")
		require("utils").notes_task_cycle(math.min(first, last), math.max(first, last), force)
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
	local utils = require("utils")
	if vim.b[buf]._999rpm_notes or not utils.notes_in_vault(buf) then
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
	if vim.api.nvim_get_current_buf() == buf then
		vim.opt_local.wrap = true -- a long block reads as one paragraph, as in Logseq
	end
	vim.b[buf].minihipatterns_config = { highlighters = highlighters }
	pcall(require("mini.hipatterns").disable, buf)
	pcall(require("mini.hipatterns").enable, buf)
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buf = buf, desc = desc })
	end
	map("n", "gf", util("notes_follow", false), "Follow link, tag or block ref")
	map("n", "<C-w>f", util("notes_follow", true), "Follow link in a vertical split")
	map({ "n", "i" }, "<C-CR>", util("notes_task_cycle"), "Cycle task marker")
	map("n", "<M-j>", util("notes_move_block", 1), "Move bullet and children down")
	map("n", "<M-k>", util("notes_move_block", -1), "Move bullet and children up")
end

return {
	"999rpm-notes", -- a name with no slash: lazy.nvim looks for no repository
	virtual = true, -- and adds no rtp entry; the code is utils.lua's notes_* helpers
	ft = "markdown",
	cmd = { "Journal", "NotesInit" },
	keys = {
		{ "<leader>nn", util("notes_journal"), desc = "Today's journal" },
		{
			"<leader>nd",
			function()
				vim.ui.input({ prompt = "Journal for (today, -1, +2, fri, next mon, 2026-10-01): " }, function(words)
					if words then
						require("utils").notes_journal(words)
					end
				end)
			end,
			desc = "Journal for a date",
		},
		{ "<leader>nj", util("notes_journals"), desc = "Journals" },
		{ "<leader>np", util("notes_pages"), desc = "Pages" },
		{ "<leader>nN", util("notes_new_page"), desc = "New page" },
		{ "<leader>ns", util("notes_search"), desc = "Search notes" },
		{ "<leader>nb", util("notes_backlinks"), desc = "Linked references" },
		{ "<leader>nu", util("notes_unlinked"), desc = "Unlinked references" },
		{ "<leader>nt", util("notes_tasks"), desc = "Open tasks" },
		{ "<leader>na", util("notes_agenda"), desc = "Agenda (scheduled, deadlines)" },
		{ "<leader>nT", util("notes_tags"), desc = "Tags" },
		{ "<leader>nx", util("notes_task_cycle"), desc = "Cycle task: TODO > DOING > DONE" },
		{ "<leader>nx", selected_lines(), mode = "x", desc = "Cycle task on each line" },
		{ "<leader>nX", util("notes_task_cycle", nil, nil, "CANCELED"), desc = "Cancel task" },
		{ "<leader>nX", selected_lines("CANCELED"), mode = "x", desc = "Cancel task on each line" },
		{ "<leader>nS", util("notes_task_date", "SCHEDULED"), desc = "Schedule" },
		{ "<leader>nD", util("notes_task_date", "DEADLINE"), desc = "Deadline" },
		{ "<leader>ni", util("notes_template"), desc = "Insert template" },
		{ "<leader>nz", util("notes_focus"), desc = "Focus block (zoom in)" },
		{ "<leader>nZ", util("notes_unfocus"), desc = "Unfold all (zoom out)" },
		{ "<leader>ng", util("notes_graph", false), desc = "Link graph (image)" },
		{ "<leader>nG", util("notes_graph", true), desc = "Link graph (text)" },
		{ "<leader>nc", util("notes_commit"), desc = "Commit the graph (git)" },
	},
	config = function()
		local utils = require("utils")
		utils.on_colorscheme("notes-highlights", paint)
		vim.api.nvim_create_autocmd("FileType", {
			group = utils.augroup("notes"),
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
			utils.notes_journal(o.args)
		end, { nargs = "*", desc = "Open the journal for a date (today when empty)" })
		vim.api.nvim_create_user_command("NotesInit", utils.notes_init, { desc = "Create journals/, pages/ and assets/" })
	end,
}
