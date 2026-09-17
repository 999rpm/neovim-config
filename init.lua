-- Entry point: options, autocmds, mappings, then lazy.nvim (which imports lua/plugins/loader.lua).
-- Layout: lua/config/ for editor settings, lua/plugins/<category>/ for one plugin per file, lua/utils.lua for shared helpers.
-- Requires Neovim 0.12+, a Nerd Font, git, and a C compiler for treesitter parsers. README.md lists the optional tools.
if vim.loader then
	vim.loader.enable()
end

require("config.options")
require("config.autocmds")
require("config.mappings")
require("config.lazy")
