-- Neovim 0.12+ config. Load order: options, autocmds, mappings, then lazy.nvim with every spec under lua/plugins/.
-- lua/config/ holds editor settings, lua/plugins/<category>/ one plugin per file, lua/utils.lua the helpers they share.
-- A personal key sits on a built-in only when it does the same job better; mappings.lua lists the built-ins worth knowing.
-- Needs git, a C compiler, the tree-sitter CLI and a Nerd Font. README.md lists the optional tools, d2 among them.
vim.loader.enable()

require("config.options")
require("config.autocmds")
require("config.mappings")
require("config.lazy")
