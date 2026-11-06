-- Editor-wide keymaps. Plugin keys live in their plugin file; which-key.lua names the prefixes. A key here sits on a
-- built-in only when it does the built-in's job better (n, N, insert , . ;), each logged in AUDIT_SUMMARY.md.
-- Built-ins worth knowing: ; and , repeat f/t, q records a macro and @ replays it, x deletes a char, P pastes over a
-- selection without yanking it, H/M/L jump to the window top/middle/bottom, s changes a char, ~ toggles case, gi
-- resumes the last insert, gv reselects, g; and g, walk the change list, <C-o>/<C-i> walk the jump list, zz/zt/zb
-- scroll, gx opens a link, & repeats :s, @: repeats a command, ga shows character info, gq formats (gw keeps the
-- cursor), . repeats, <C-w>+ <C-w>- <C-w>< <C-w>> <C-w>= size windows, <C-v> starts blockwise visual, ZZ writes and
-- quits, ZQ quits unsaved, <C-t>/<C-d> indent/dedent the line in insert mode, <C-l> clears the search highlight.
-- vag selects the whole buffer (mini.lua's g object). :sort sorts lines without a shell; :%!sort runs sort(1) through
-- 'shell', which is sh under any login shell.
-- 0.12 defaults left alone: ]d [d ]D [D diagnostics, <C-w>d diagnostic float, ]q [q ]l [l lists, ]b [b buffers, ]a [a
-- args, ]t [t tags, ]<Space> [<Space> blank lines, an/in parent/child node and visual ]n [n ]N [N next/previous node or
-- sibling, K hover, <C-s> signature help (insert), gr* LSP keys, [[ ]] shell prompts in a terminal buffer, ZR restart
-- Neovim, :Undotree (<leader>uu here). % g% [% ]% z% a% i% come from matchup.lua, gl/gL (align) from mini.lua.
-- Inside tmux, C-b C-b sends <C-b> (page up). Terminal mode maps nothing here: zsh's vi mode reads Alt+key as <Esc> and
-- the key, and nushell binds Alt keys too, so <C-\><C-n> leaves terminal mode and the window keys below follow.
-- Filetype keys kept: <C-a>/<C-x> cycle the action of a git rebase todo line, gO lists a man page's sections.
-- hardtime.lua wraps h j k l, - + and <CR> to count repeats and show hints; they keep their built-in moves.
-- Prefixes owned here: <leader>q quit, <leader>y yank and no-yank edits, <leader><Tab> tabs, and <leader>c, <leader>d,
-- <leader>p, <leader>u entries listed below.
local map = vim.keymap.set

map({ "n", "x" }, "<Space>", "<Nop>", { desc = "Leader prefix" }) -- n/x: a bare Space would move right; it only starts leader keys
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" }) -- n: Esc in normal mode has no job of its own; it also hides the hits
map("n", "n", "nzzzv", { desc = "Next match (centred)" }) -- n: upgrades built-in n: the same jump, counts kept, then the match is centred and its fold opened
map("n", "N", "Nzzzv", { desc = "Previous match (centred)" }) -- n: upgrades built-in N the same way
map("n", "<C-s>", "<Cmd>write<CR>", { desc = "Write file" }) -- n: normal-mode <C-s> has no built-in job

map("n", "<leader>qq", "<Cmd>quit<CR>", { desc = "Quit window" }) -- n: :quit, asks when the buffer has changes
map("n", "<leader>qa", "<Cmd>quitall<CR>", { desc = "Quit all" }) -- n: :quitall, asks about every changed buffer
map("n", "<leader>ph", "<Cmd>checkhealth<CR>", { desc = "Checkhealth" }) -- n: Neovim's and the plugins' self-checks
map("n", "<leader>uu", function()
	vim.cmd.packadd("nvim.undotree") -- 0.12 ships it as an opt package
	vim.cmd.Undotree()
end, { desc = "Undo tree" }) -- n: browse every undo state as a tree

map("n", "<leader>cr", function()
	require("utils.run").run()
end, { desc = "Build and run (project or file)" }) -- n: Visual Studio's Ctrl+F5 (utils/run.lua); a failed build fills the quickfix list

map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Line diagnostics (float)" }) -- n: the full messages of this line; shorter reach than the built-in <C-w>d
map("n", "<leader>db", function()
	vim.fn.setqflist({}, " ", { title = "Buffer diagnostics", items = vim.diagnostic.toqflist(vim.diagnostic.get(0)) })
	vim.cmd.copen()
end, { desc = "Buffer diagnostics to quickfix" }) -- n: this buffer's diagnostics in the quickfix list
map("n", "<leader>dw", function()
	local cell_buffer = require("utils.notebook").is_cell_buffer
	local shown = vim.tbl_filter(function(d)
		return not cell_buffer(d.bufnr)
	end, vim.diagnostic.get())
	vim.fn.setqflist({}, " ", { title = "Diagnostics", items = vim.diagnostic.toqflist(shown) })
	vim.cmd.copen()
end, { desc = "All diagnostics to quickfix" }) -- n: every open buffer except otter's hidden notebook cells, and opens the list
for key, severity in pairs({ e = "ERROR", w = "WARN" }) do -- ]d/[d stay every severity
	local level, label = vim.diagnostic.severity[severity], severity == "ERROR" and "error" or "warning"
	map("n", "]" .. key, function()
		vim.diagnostic.jump({ count = vim.v.count1, severity = level })
	end, { desc = "Next " .. label }) -- n: ]e next error, ]w next warning, skipping lower severities
	map("n", "[" .. key, function()
		vim.diagnostic.jump({ count = -vim.v.count1, severity = level })
	end, { desc = "Previous " .. label }) -- n: [e and [w go back the same way
end

map("n", "dm", function()
	local mark = vim.fn.getcharstr()
	if mark == "!" then
		vim.cmd("delmarks!") -- every lowercase mark of the buffer
	elseif mark:match('^[%w"%^%.%[%]<>]$') then
		vim.cmd.delmarks(mark)
	end
end, { desc = "Delete mark (next key names it, ! all lowercase)" }) -- n: the opposite of m{letter}; dm has no built-in job, m is not a motion

map("n", "<leader><leader>", "V", { desc = "Visual line" }) -- n: Space twice selects the line
map("x", "<leader><leader>", "<Esc>", { desc = "Leave visual" }) -- x: and twice more leaves the selection
map("i", "<M-m>", "<Esc>", { desc = "Leave insert" }) -- i: Alt+m, an Esc that stays under the fingers
for _, char in ipairs({ ",", ".", ";" }) do
	map("i", char, char .. "<C-g>u", { desc = "Insert " .. char .. " and start a new undo step" }) -- i: upgrades the typed , . ; with an undo break: u undoes a clause, while . repeats the whole insert and counts still work
end

map("x", "<Tab>", ">gv", { desc = "Indent, keep selection" }) -- x: > that keeps the selection for another press
map("x", "<S-Tab>", "<gv", { desc = "Dedent, keep selection" }) -- x: < the same way
map("n", "<M-j>", "<Cmd>move+<CR>==", { desc = "Move line down" }) -- n: Alt+j swaps the line with the next; notes/logseq.lua moves a whole bullet in graph buffers
map("n", "<M-k>", "<Cmd>move-2<CR>==", { desc = "Move line up" }) -- n: Alt+k swaps it with the previous
map("x", "<M-j>", ":move '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" }) -- x: ":" rather than <Cmd>, so the '< '> marks update first
map("x", "<M-k>", ":move '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" }) -- x: the selected lines up one, reindented

---Copy the current file's path to the system clipboard and echo what was copied.
---@param modifier string fnamemodify() specifier
---@param title string notification title
---@return fun()
local function yank_path(modifier, title)
	return function()
		local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), modifier)
		vim.fn.setreg("+", path)
		vim.notify(path, vim.log.levels.INFO, { title = title })
	end
end

map({ "n", "x" }, "<leader>yp", '"0p', { desc = "Paste last yank (after)" }) -- n/x: register 0 keeps the last yank through deletes
map("n", "<leader>yP", '"0P', { desc = "Paste last yank (before)" }) -- n: the same, before the cursor
map({ "n", "x" }, "<leader>yc", '"_c', { desc = "Change, no yank" }) -- n/x: "_ is the black hole register, so the yank survives
map({ "n", "x" }, "<leader>yC", '"_C', { desc = "Change to line end, no yank" }) -- n/x: C into the black hole
map({ "n", "x" }, "<leader>yd", '"_d', { desc = "Delete, no yank" }) -- n/x: d{motion} into the black hole
map({ "n", "x" }, "<leader>yD", '"_D', { desc = "Delete to line end, no yank" }) -- n/x: D into the black hole
map("n", "<leader>yf", yank_path(":~:.", "Yanked relative path"), { desc = "Yank relative path" }) -- n: the file's path from the working directory, to the clipboard
map("n", "<leader>yF", yank_path(":p", "Yanked absolute path"), { desc = "Yank absolute path" }) -- n: the full path, to the clipboard

map("n", "gco", "o<Esc>Vcx<Esc><Cmd>normal gcc<CR>fxa<BS>", { desc = "Comment line below" }) -- n: gc + o, a new commented line below; placeholder x keeps gcc from skipping a blank line
map("n", "gcO", "O<Esc>Vcx<Esc><Cmd>normal gcc<CR>fxa<BS>", { desc = "Comment line above" }) -- n: gc + O, the same above
map("n", "gcA", function()
	local left, right = vim.bo.commentstring:match("^(.-)%%s(.-)$")
	if not left then
		return
	end
	local head = ("%s %s "):format((vim.api.nvim_get_current_line():gsub("%s+$", "")), vim.trim(left))
	local tail = vim.trim(right) ~= "" and (" " .. vim.trim(right)) or ""
	vim.api.nvim_set_current_line(head .. tail)
	if tail == "" then
		vim.cmd("startinsert!")
	else
		vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], #head })
		vim.cmd("startinsert")
	end
end, { desc = "Comment at line end" }) -- n: gc + A, a comment after the code, cursor ready to type

map("n", "<M-y>", "<C-w>v", { desc = "Split vertically" }) -- n: Alt+y runs the built-in <C-w>v
map("n", "<M-x>", "<C-w>s", { desc = "Split horizontally" }) -- n: Alt+x runs <C-w>s
map("n", "<M-w>", "<C-w>k", { desc = "Window up" }) -- n: Alt+w/a/s/d move between windows like arrow keys on WASD
map("n", "<M-s>", "<C-w>j", { desc = "Window down" }) -- n: Alt+s, the window below
map("n", "<M-a>", "<C-w>h", { desc = "Window left" }) -- n: Alt+a, the window on the left
map("n", "<M-d>", "<C-w>l", { desc = "Window right" }) -- n: Alt+d, the window on the right
map("n", "<M-e>", "<C-w>=", { desc = "Equalize windows" }) -- n: Alt+e, every window the same size
map("n", "<M-q>", "<Cmd>close<CR>", { desc = "Close window" }) -- n: Alt+q, the window goes, the buffer stays
map("n", "<M-Up>", "<Cmd>resize +2<CR>", { desc = "Taller window" }) -- n: Alt+arrows resize; the bare arrows keep moving the cursor
map("n", "<M-Down>", "<Cmd>resize -2<CR>", { desc = "Shorter window" }) -- n: two lines shorter
map("n", "<M-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Narrower window" }) -- n: two columns narrower
map("n", "<M-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Wider window" }) -- n: two columns wider

map("n", "<leader><Tab>e", "<Cmd>tabedit<CR>", { desc = "New tab" }) -- n: an empty tab page
map("n", "<leader><Tab>n", "<Cmd>tabnext<CR>", { desc = "Next tab (also gt)" }) -- n: the built-in gt does the same
map("n", "<leader><Tab>p", "<Cmd>tabprevious<CR>", { desc = "Previous tab (also gT)" }) -- n: the built-in gT does the same
map("n", "<leader><Tab>o", "<Cmd>tabonly<CR>", { desc = "Close other tabs" }) -- n: keep only this tab page
map("n", "<leader><Tab>q", "<Cmd>tabclose<CR>", { desc = "Close tab" }) -- n: close this tab page
