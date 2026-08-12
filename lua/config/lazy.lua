-- Bootstraps folke/lazy.nvim itself (self-installing on first run), then calls its setup()
-- with this config's plugin-manager options: `{ import = "plugins" }` below hands off to
-- `lua/plugins/init.lua`, which explicitly imports each category subfolder by name — lazy.nvim
-- itself does NOT recurse into subfolders on its own (see plugins/init.lua's own header for why,
-- confirmed against lazy.nvim's source) — plus lockfile/dev-path/UI/performance tuning, and the
-- `<leader>ol` (:Lazy) / `<leader>om` (:Mason) keymaps at the bottom. Every other .lua file under
-- `lua/plugins/` (grouped into category subfolders — see init.lua's file-layout note) is a
-- plugin *spec* this file discovers and loads; it doesn't reference any of them by name itself.
local fn = vim.fn
local api = vim.api
local uv = vim.uv or vim.loop

-- Ensure Lazy path
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
	print("Installing lazy.nvim...")
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- Load user lazy options securely
local user_lazy_opts = {}
local has_config, user_setup = pcall(require, "config.setup")
if has_config and type(user_setup) == "table" and user_setup.lazy_opts then
	user_lazy_opts = user_setup.lazy_opts() or {}
end

-- Plugin Spec Detection
local user_path = fn.stdpath("config") .. "/lua"
local has_user_plugins = uv.fs_stat(user_path .. "/plugins") ~= nil or uv.fs_stat(user_path .. "/plugins.lua") ~= nil

local has_git = fn.executable("git") == 1
local disabled_plugins = {
	"gzip",
	"matchit",
	-- "matchparen",
	"netrwPlugin",
	"rplugin",
	"tarPlugin",
	"tohtml",
	-- "tutor",
	"zipPlugin",
	"vimballPlugin",
	"2html_plugin",
}

-- `git = { added = ..., modified = ..., removed = ... }` used to live here too, alongside the
-- rest. Removed rather than fixed: grepped lazy.nvim's current source for `icons.git` and it's
-- read nowhere at all (confirmed against a fresh clone of lua/lazy/view/render.lua, the only
-- place `Config.options.ui.icons.*` gets consumed) - unlike every icon below, which IS read
-- (cmd/config/event/ft/etc. all appear in render.lua). Dead config from an older lazy.nvim
-- version rather than a real, currently-broken feature.
local icons = {
	cmd = "󰞷 ",
	config = "󰒓 ",
	event = "󰉉 ",
	ft = "󰈔 ",
	init = "󰈮 ",
	keys = "󰌌 ",
	plugin = "󰏖 ",
	runtime = "󰍜 ",
	require = "󰢱 ",
	source = "󰈩 ",
	start = "󰐊 ",
	task = "󰄉 ",
	lazy = "󰒲 ",
}

require("lazy").setup(vim.tbl_extend("keep", user_lazy_opts, {
	spec = {
		has_user_plugins and { import = "plugins" } or nil,
	},
	defaults = { lazy = false, version = false },
	lockfile = fn.stdpath("config") .. "/lazy-lock.json",
	concurrency = 10,
	-- Optimized dev path resolution
	dev = { path = fn.stdpath("config") .. "/dev" },
	install = { missing = has_git, colorscheme = {} },
	checker = { enabled = has_git, notify = true },
	change_detection = { notify = false },
	ui = {
		border = "rounded",
		size = { width = 0.8, height = 0.85 },
		wrap = true,
		icons = icons,
	},
	diff = { cmd = "terminal_git" },
	performance = {
		reset_packpath = true,
		cache = { enabled = true },
		rtp = { disabled_plugins = disabled_plugins },
	},
	debug = false,
}))

vim.keymap.set("n", "<leader>ol", "<cmd>Lazy<cr>", { desc = "Lazy" })
vim.keymap.set("n", "<leader>om", "<cmd>Mason<cr>", { desc = "Mason" })

-- Helper command to disable plugins (useful for debugging)
api.nvim_create_user_command("LazyDisable", function()
	local config = require("lazy.core.config")
	local loader = require("lazy.core.loader")

	for _, plugin in pairs(config.plugins) do
		if plugin._.loaded then
			pcall(loader.deactivate, plugin)
		end
	end
	vim.notify("Attempted to unload all plugins.", vim.log.levels.INFO)
end, { desc = "Disable all loaded plugins" })
