-- Editor-wide keymaps. Plugin keys live in their plugin file; which-key.lua names the prefixes.
-- No key here takes a built-in away. Built-ins worth knowing: ; and , repeat f/t, q records a macro and @ replays it,
-- x deletes a char, P pastes over a selection without yanking it, H/M/L jump to the window top/middle/bottom, s changes a char,
-- ~ toggles case, gi resumes the last insert, gv reselects, g; and g, walk the change list, <C-o>/<C-i> walk the jump list,
-- zz/zt/zb scroll, gx opens a link, & repeats :s, @: repeats a command, ga shows character info, gq formats, . repeats,
-- <C-w>+ <C-w>- <C-w>< <C-w>> <C-w>= size windows, <C-v> starts blockwise visual, ZZ writes and quits, ZQ quits unsaved.
-- 0.12 defaults left alone: ]d [d ]D [D diagnostics, <C-w>d diagnostic float, ]q [q ]l [l lists, ]b [b buffers, ]a [a args,
-- ]t [t tags, ]<Space> [<Space> blank lines, an/in parent/child node, K hover, <C-s> signature help (insert), gr* LSP keys.
-- hardtime.lua owns h j k l J and the arrow keys (it wraps them to count repeats), so nothing here maps them.
local map = vim.keymap.set

map({ "n", "x" }, "<Space>", "<Nop>", { desc = "Leader prefix" }) -- bare Space would move right
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "n", "nzzzv", { desc = "Next match (centred)" })
map("n", "N", "Nzzzv", { desc = "Previous match (centred)" })
map("n", "<C-s>", "<Cmd>write<CR>", { desc = "Write file" }) -- normal-mode <C-s> has no built-in job

map("n", "<leader>qq", "<Cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>qa", "<Cmd>quitall<CR>", { desc = "Quit all" })

map("n", "<leader><leader>", "V", { desc = "Visual line" })
map("x", "<leader><leader>", "<Esc>", { desc = "Leave visual" })
map("i", "<M-m>", "<Esc>", { desc = "Leave insert" })

map("x", "<Tab>", ">gv", { desc = "Indent, keep selection" })
map("x", "<S-Tab>", "<gv", { desc = "Dedent, keep selection" })
map("n", "<M-j>", "<Cmd>move+<CR>==", { desc = "Move line down" })
map("n", "<M-k>", "<Cmd>move-2<CR>==", { desc = "Move line up" })
map("x", "<M-j>", ":move '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" }) -- ":" rather than <Cmd>, so the '< '> marks update first
map("x", "<M-k>", ":move '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })

local function yank_path(modifier, title)
	return function()
		local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), modifier)
		vim.fn.setreg("+", path)
		vim.notify(path, vim.log.levels.INFO, { title = title })
	end
end

map("n", "<leader>na", "ggVG", { desc = "Select whole buffer" })
map({ "n", "x" }, "<leader>np", '"0p', { desc = "Paste last yank (after)" })
map("n", "<leader>nP", '"0P', { desc = "Paste last yank (before)" })
map({ "n", "x" }, "<leader>nc", '"_c', { desc = "Change, no yank" })
map({ "n", "x" }, "<leader>nC", '"_C', { desc = "Change to line end, no yank" })
map({ "n", "x" }, "<leader>nd", '"_d', { desc = "Delete, no yank" })
map({ "n", "x" }, "<leader>nD", '"_D', { desc = "Delete to line end, no yank" })
map("n", "<leader>ny", yank_path(":~:.", "Yanked relative path"), { desc = "Yank relative path" })
map("n", "<leader>nY", yank_path(":p", "Yanked absolute path"), { desc = "Yank absolute path" })

map("n", "gco", "o<Esc>Vcx<Esc><Cmd>normal gcc<CR>fxa<BS>", { desc = "Comment line below" }) -- placeholder x keeps gcc from skipping a blank line
map("n", "gcO", "O<Esc>Vcx<Esc><Cmd>normal gcc<CR>fxa<BS>", { desc = "Comment line above" })
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
end, { desc = "Comment at line end" })

map("n", "<M-y>", "<C-w>v", { desc = "Split vertically" })
map("n", "<M-x>", "<C-w>s", { desc = "Split horizontally" })
map("n", "<M-w>", "<C-w>k", { desc = "Window up" })
map("n", "<M-s>", "<C-w>j", { desc = "Window down" })
map("n", "<M-a>", "<C-w>h", { desc = "Window left" })
map("n", "<M-d>", "<C-w>l", { desc = "Window right" })
map("n", "<M-e>", "<C-w>=", { desc = "Equalize windows" })
map("n", "<M-q>", "<Cmd>close<CR>", { desc = "Close window" })
map("n", "<M-Up>", "<Cmd>resize +2<CR>", { desc = "Taller window" })
map("n", "<M-Down>", "<Cmd>resize -2<CR>", { desc = "Shorter window" })
map("n", "<M-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Narrower window" })
map("n", "<M-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Wider window" })

local term_wincmd = require("utils").term_wincmd
map("t", "<M-w>", term_wincmd("k", "<M-w>"), { expr = true, desc = "Window up (floats get the key)" })
map("t", "<M-s>", term_wincmd("j", "<M-s>"), { expr = true, desc = "Window down (floats get the key)" })
map("t", "<M-a>", term_wincmd("h", "<M-a>"), { expr = true, desc = "Window left (floats get the key)" })
map("t", "<M-d>", term_wincmd("l", "<M-d>"), { expr = true, desc = "Window right (floats get the key)" })

map("n", "<leader><Tab>e", "<Cmd>tabedit<CR>", { desc = "New tab" })
map("n", "<leader><Tab>n", "<Cmd>tabnext<CR>", { desc = "Next tab (also gt)" })
map("n", "<leader><Tab>p", "<Cmd>tabprevious<CR>", { desc = "Previous tab (also gT)" })
map("n", "<leader><Tab>o", "<Cmd>tabonly<CR>", { desc = "Close other tabs" })
map("n", "<leader><Tab>q", "<Cmd>tabclose<CR>", { desc = "Close tab" })
