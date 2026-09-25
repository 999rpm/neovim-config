-- lazy.nvim bootstrap and runtime settings. :Lazy or <leader>ol opens the manager; the statusline shows pending updates.
-- In the Lazy window: H home, I install, U update, S sync, X clean, C check, L log, R restore, P profile, D debug, ? help.
local fn = vim.fn
local api = vim.api
local uv = vim.uv

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

local has_git = fn.executable("git") == 1
local disabled_plugins = { -- names from 0.12's runtime/plugin; matchit stays on, so % also jumps between if/else/end words
	"gzip",
	"netrwPlugin", -- oil.lua opens directories
	"rplugin",
	"tarPlugin",
	"zipPlugin",
}

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

require("lazy").setup({
	spec = {
		{ import = "plugins.loader" }, -- resolves to lua/plugins/loader.lua; see that file's own header
	},
	defaults = { lazy = false, version = false },
	lockfile = fn.stdpath("config") .. "/lazy-lock.json",
	concurrency = 10,
	dev = { path = fn.stdpath("config") .. "/dev" },
	install = { missing = has_git, colorscheme = {} },
	checker = { enabled = has_git, notify = false }, -- lualine.lua shows the count; no startup notification
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
})

vim.keymap.set("n", "<leader>ol", "<cmd>Lazy<cr>", { desc = "Lazy" })

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
