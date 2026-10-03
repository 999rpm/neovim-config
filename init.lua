-- 999rpm's Neovim config, for Neovim 0.12+. Load order: options, autocmds, mappings, then lazy.nvim, which imports
-- every spec under lua/plugins/ (plugins/loader.lua lists the category folders).
-- Layout: lua/config/ editor settings, lua/plugins/<category>/ one plugin per file, plugins/deps/shared.lua the
-- libraries several plugins need, lua/utils/ the shared helpers by subject (core, shell, statusline, debugger, fences,
-- d2, notes, jupyter, notebook, run, project, themes), each function naming the files that call it.
-- Beyond code: plugins/notes/ is a Logseq-style notes graph (journals, pages, backlinks, tasks, agenda, templates),
-- plugins/notebook/ runs Jupyter notebooks against real kernels, with JupyterLab-style cell keys under <leader>k, and
-- plugins/projects/ creates, opens and builds projects the way Visual Studio does, under <leader>w.
-- Keys: built-in keys keep their jobs, the filetype plugins' own keys included; a personal key sits on a built-in
-- only when it does the same job better. Conflicts resolve kitty > shell > tmux > Neovim: nothing here takes kitty's
-- ctrl+shift and alt+digit keys or tmux's prefix C-b, and terminal mode leaves the shell its Alt keys.
-- mappings.lua lists the built-ins worth knowing, which-key.lua the leader groups (press <leader> and wait), and every
-- on/off switch is under <leader>o.
-- Startup loads about a dozen plugins; servers, completion and the rest arrive with the first file. 'shell' follows
-- the login shell, zsh or nushell. Needs git, a C compiler, ripgrep, the tree-sitter CLI and a Nerd Font.
vim.loader.enable()

require("config.options")
require("config.autocmds")
require("config.mappings")
require("config.lazy")
