-- Core keymaps not owned by any specific plugin. Plugin-specific keymaps live in their own
-- files' `keys` tables instead (see e.g. plugins/ui/bufferline.lua, plugins/git/gitsigns.lua,
-- plugins/search/telescope.lua). Each mapping's own `desc` explains what it does and, where a
-- mapping overrides a native Vim behavior, what that trade-off is — see AUDIT_SUMMARY.md for
-- the fuller reasoning behind any of them.
local map = vim.keymap.set
local utils = require("utils")

utils.cowboy()

--  General / Core
map({ "n", "v" }, "<space>", "<nop>", { desc = "disable space bar" })
map("n", "q", "<nop>", { desc = "Disable macro recording (q{reg}/q to stop)" })
map({ "n", "x" }, ";", ":", { desc = "Enter command mode (native repeat-f/F/t/T on ;/, is gone)" })
map("n", "<C-s>", "<cmd>w<CR>", { noremap = true, desc = "Save file" })
map("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<C-e>", "<cmd>wq<CR>", { desc = "Save and Quit" })
map("i", "<C-e>", "<Esc><cmd>wq<CR>", { desc = "Save and Quit" })

--  Navigation & Scrolling
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move up (visual line)" })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move down (visual line)" })

-- Changing modes
map("n", "<leader><leader>", "V", { desc = "Visual Mode" })
map("x", "<leader><leader>", "<Esc>", { desc = "Normal Mode" })
map("i", "<M-m>", "<Esc>", { desc = "Normal Mode" })

--  Search & Highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

--  Editing & Text Manipulation
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all (native increment moved to '>' below)" })
map({ "n", "v" }, "x", '"_x', { noremap = true, desc = "Delete char (no yank)" })
map({ "n", "v" }, "X", '"_X', { noremap = true, desc = "Delete prev char (no yank)" })
map("x", "<S-Tab>", "<gv", { noremap = true, desc = "Indent left" })
map("x", "<Tab>", ">gv", { noremap = true, desc = "Indent right" })

map("v", "p", '"_dP', { noremap = true, desc = "Paste over selection (no yank)" })

-- Drag current line(s) vertically and auto-indent
map("n", "<M-k>", "<cmd>move-2<CR>==", { desc = "Move line up" })
map("n", "<M-j>", "<cmd>move+<CR>==", { desc = "Move line down" })
map("x", "<M-k>", ":move '<-2<CR>gv-gv", { noremap = true, desc = "Move selection up" })
map("x", "<M-j>", ":move '>+1<CR>gv-gv", { noremap = true, desc = "Move selection down" })

-- Paste from yank register (not affected by deletions)
map("n", "<Leader>np", '"0p', { desc = "Paste from yank register (after)" })
map("n", "<Leader>nP", '"0P', { desc = "Paste from yank register (before)" })
map("v", "<Leader>np", '"0p', { desc = "Paste from yank register" })

-- Change/Delete without polluting the register
map({ "n", "v" }, "<Leader>nc", '"_c', { desc = "Change (no yank)" })
map({ "n", "v" }, "<Leader>nC", '"_C', { desc = "Change to EOL (no yank)" })
map({ "n", "v" }, "<Leader>nd", '"_d', { desc = "Delete (no yank)" })
map({ "n", "v" }, "<Leader>nD", '"_D', { desc = "Delete to EOL (no yank)" })

-- Yank buffer's relative path to clipboard
map("n", "<leader>ny", function()
	local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":~:.") or ""
	vim.fn.setreg("+", path)
	vim.notify(path, vim.log.levels.INFO, { title = "Yanked relative path" })
end, { silent = true, desc = "Yank relative path" })

-- Yank absolute path
map("n", "<leader>nY", function()
	local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p") or ""
	vim.fn.setreg("+", path)
	vim.notify(path, vim.log.levels.INFO, { title = "Yanked absolute path" })
end, { silent = true, desc = "Yank absolute path" })

-- New line without comment continuation
map("n", "<Leader>no", "o<Esc>^Da", { noremap = true, desc = "New line below (no comment)" })
map("n", "<Leader>nO", "O<Esc>^Da", { noremap = true, desc = "New line above (no comment)" })

-- Increment / Decrement numbers (also letters, via nrformats+="alpha" in options.lua).
-- NOTE: this replaces native Normal-mode `>`/`<` (indent operators: `>>`, `>j`, `>ip`, ...)
-- entirely — bare `>`/`<` now always increments/decrements, never waits for a motion.
-- Visual-mode indent still works (see the Tab/Shift-Tab mappings above).
map("n", ">", "<C-a>", { desc = "Increment alpha" })
map("n", "<", "<C-x>", { desc = "Decrement alpha" })

--  Window Management (Splits)
map("n", "<M-y>", "<C-w>v", { desc = "Split vertical" })
map("n", "<M-x>", "<C-w>s", { desc = "Split horizontal" })

map("n", "<M-w>", "<C-w>k", { desc = "Window up" })
map("n", "<M-s>", "<C-w>j", { desc = "Window down" })
map("n", "<M-a>", "<C-w>h", { desc = "Window left" })
map("n", "<M-d>", "<C-w>l", { desc = "Window right" })

map("n", "<M-e>", "<C-w>=", { desc = "Equalize splits" })
map("n", "<M-q>", "<cmd>close<CR>", { desc = "Close split" })

--  Window Resizing
map("n", "<Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

--  Tabs
map("n", "te", ":tabedit<CR>", { desc = "New tab" })
map("n", "tn", ":tabnext<CR>", { noremap = true, desc = "Next tab" })
map("n", "tp", ":tabprev<CR>", { noremap = true, desc = "Previous tab" })
map("n", "to", ":tabonly<CR>", { noremap = true, desc = "Close other tabs" })
map("n", "tq", ":tabclose<CR>", { noremap = true, desc = "Close tab" })

--  Toggles & UI
map("n", "<leader>on", "<cmd>set nu!<CR>", { desc = "Toggle line number" })
map("n", "<leader>or", "<cmd>set rnu!<CR>", { desc = "Toggle relative number" })
map("n", "<leader>ow", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })
-- Theme cycling/style-switching (<leader>os / <leader>ot / <leader>oT / <leader>ou) lives
-- entirely in plugins/ui/themes.lua — see that file's own keymap table.
