-- Editor-wide keymaps. Plugin keys live in their plugin file; which-key.lua labels the prefixes.
-- Replaced built-ins: ; (repeat f/F/t/T), q (macro record), x/X (delete no longer yanks), <C-a> (increment, now > in dial.lua),
-- <C-q> (blockwise visual, still on <C-v>), H/L (window top/bottom, now buffer switching in barbar.lua), f/F (flash.lua), s (surround.lua).
-- Built-ins worth remembering: gi last insert spot, gv reselect, g; g, change list, '' jump back, <C-o>/<C-i> jump list,
-- zz/zt/zb scroll, gx open link, & repeat :s, @: repeat command, ga character info, gq format, . repeat.
local map = vim.keymap.set

map({ "n", "v" }, "<space>", "<nop>", { desc = "disable space bar" })
map("n", "q", "<nop>", { desc = "Macro recording disabled (q is a no-op; @ replay is unaffected)" })
map({ "n", "x" }, ";", ":", { desc = "Enter command mode (native repeat-f/F/t/T on ;/, is gone)" })
map("n", "<C-s>", "<cmd>w<CR>", { noremap = true, desc = "Save file" })
map("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit" })
map("i", "<C-e>", "<Esc><cmd>wq<CR>", { desc = "Save and Quit" })

map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move up (visual line)" })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move down (visual line)" })

map("n", "<leader><leader>", "V", { desc = "Visual Mode" })
map("x", "<leader><leader>", "<Esc>", { desc = "Normal Mode" })
map("i", "<M-m>", "<Esc>", { desc = "Normal Mode" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("n", "n", "nzzzv", { desc = "Next search match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search match (centered)" })

map("n", "<C-a>", "gg<S-v>G", { desc = "Select all (native increment moved to '>' below)" })
map({ "n", "v" }, "x", '"_x', { noremap = true, desc = "Delete char (no yank)" })
map({ "n", "v" }, "X", '"_X', { noremap = true, desc = "Delete prev char (no yank)" })
map("x", "<S-Tab>", "<gv", { noremap = true, desc = "Indent left" })
map("x", "<Tab>", ">gv", { noremap = true, desc = "Indent right" })

map("v", "p", '"_dP', { noremap = true, desc = "Paste over selection (no yank)" })

map("n", "J", "mzJ`z", { desc = "Join line (cursor stays put)" })

map("n", "<M-k>", "<cmd>move-2<CR>==", { desc = "Move line up" })
map("n", "<M-j>", "<cmd>move+<CR>==", { desc = "Move line down" })
map("x", "<M-k>", ":move '<-2<CR>gv=gv", { noremap = true, desc = "Move selection up" })
map("x", "<M-j>", ":move '>+1<CR>gv=gv", { noremap = true, desc = "Move selection down" })

map("n", "<leader>np", '"0p', { desc = "Paste from yank register (after)" })
map("n", "<leader>nP", '"0P', { desc = "Paste from yank register (before)" })
map("v", "<leader>np", '"0p', { desc = "Paste from yank register" })

map({ "n", "v" }, "<leader>nc", '"_c', { desc = "Change (no yank)" })
map({ "n", "v" }, "<leader>nC", '"_C', { desc = "Change to EOL (no yank)" })
map({ "n", "v" }, "<leader>nd", '"_d', { desc = "Delete (no yank)" })
map({ "n", "v" }, "<leader>nD", '"_D', { desc = "Delete to EOL (no yank)" })

map("n", "<leader>ny", function()
	local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":~:.") or ""
	vim.fn.setreg("+", path)
	vim.notify(path, vim.log.levels.INFO, { title = "Yanked relative path" })
end, { silent = true, desc = "Yank relative path" })

map("n", "<leader>nY", function()
	local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p") or ""
	vim.fn.setreg("+", path)
	vim.notify(path, vim.log.levels.INFO, { title = "Yanked absolute path" })
end, { silent = true, desc = "Yank absolute path" })

map("n", "<leader>no", "o<Esc>^Da", { noremap = true, desc = "New line below (no comment)" })
map("n", "<leader>nO", "O<Esc>^Da", { noremap = true, desc = "New line above (no comment)" })

map("n", "gco", "o<Esc>Vgcc", { remap = true, desc = "Comment line below" })
map("n", "gcO", "O<Esc>Vgcc", { remap = true, desc = "Comment line above" })
map("n", "gcA", "ox<Esc>Vgcc$x<Esc>gi<Space>", { remap = true, desc = "Append comment at end of line" })

map("n", "<M-y>", "<C-w>v", { desc = "Split vertical" })
map("n", "<M-x>", "<C-w>s", { desc = "Split horizontal" })

map("n", "<M-w>", "<C-w>k", { desc = "Window up" })
map("n", "<M-s>", "<C-w>j", { desc = "Window down" })
map("n", "<M-a>", "<C-w>h", { desc = "Window left" })
map("n", "<M-d>", "<C-w>l", { desc = "Window right" })

map("n", "<M-e>", "<C-w>=", { desc = "Equalize splits" })

local term_wincmd = require("utils").term_wincmd -- shared helper; see utils.lua
map("t", "<M-w>", term_wincmd("k", "<M-w>"), { expr = true, desc = "Window up (float: passes the key through)" })
map("t", "<M-s>", term_wincmd("j", "<M-s>"), { expr = true, desc = "Window down (float: passes the key through)" })
map("t", "<M-a>", term_wincmd("h", "<M-a>"), { expr = true, desc = "Window left (float: passes the key through)" })
map("t", "<M-d>", term_wincmd("l", "<M-d>"), { expr = true, desc = "Window right (float: passes the key through)" })

map("n", "<M-q>", "<cmd>close<CR>", { desc = "Close split" })

map("n", "<Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

map("n", "<leader><Tab>e", "<cmd>tabedit<CR>", { desc = "New tab" })
map("n", "<leader><Tab>n", "<cmd>tabnext<CR>", { desc = "Next tab (native: gt)" })
map("n", "<leader><Tab>p", "<cmd>tabprevious<CR>", { desc = "Previous tab (native: gT)" })
map("n", "<leader><Tab>o", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
map("n", "<leader><Tab>q", "<cmd>tabclose<CR>", { desc = "Close tab" })
