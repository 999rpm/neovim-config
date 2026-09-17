-- lazy.nvim bootstrap and runtime settings. :Lazy opens the manager, <leader>ol is its key.
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
local disabled_plugins = {
	"gzip",
	"matchit",
	"netrwPlugin",
	"rplugin",
	"tarPlugin",
	"tohtml",
	"zipPlugin",
	"vimballPlugin",
	"2html_plugin",
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
})

vim.keymap.set("n", "<leader>ol", "<cmd>Lazy<cr>", { desc = "Lazy" })
vim.keymap.set("n", "<leader>om", "<cmd>Mason<cr>", { desc = "Mason" })

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
