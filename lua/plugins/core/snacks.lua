-- folke/snacks.nvim: picker, terminals, notifier, indent guides, scratch, zen, lazygit, git browse and option toggles.
-- Picker: opens in the result list (normal mode). <Tab>/<S-Tab> next/previous, <C-Space> mark for multi-select,
-- <C-a> mark all, <CR> open, i or / type a query, <C-s>/<C-v>/<C-t> split/vsplit/tab, <C-q> to quickfix,
-- <A-h>/<A-i> hidden/ignored files, <A-p> preview, ? help, q or <Esc> close.
-- Terminal: <Esc><Esc> normal mode, q (normal mode) hide, gf open file under cursor.
-- Images: kitty draws markdown images and LaTeX math inline; <leader>ui opens the one under the cursor in a float.
-- d2 diagrams render through tree-sitter-d2.lua. Dashboard (bare `nvim`): f find, n new, g grep, r recent, c config,
-- s restore session, L Lazy, q quit; digits open the recent files listed below the keys. <leader>ew picks a window by letter.
local function term(layout)
	local win = {
		float = { position = "float" },
		vertical = { position = "right", width = 60 },
		horizontal = { position = "bottom", height = 15 },
	}
	return function()
		Snacks.terminal.toggle(nil, { env = { NVIM_999RPM_TERM = layout }, win = win[layout] }) -- env makes each layout a separate terminal
	end
end

local menu_keys = {
	["<Tab>"] = { "list_down", mode = { "i", "n" } },
	["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
	["<C-Space>"] = { "select_and_next", mode = { "i", "n" } },
}

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true, size = 512 * 1024 }, -- over 0.5 MB a file opens as ft=bigfile, without treesitter, LSP or syntax
		dashboard = {
			enabled = true,
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "recent_files", title = "Recent files", indent = 2, padding = 1 },
				{ section = "startup" },
			},
		},
		explorer = { enabled = false }, -- neo-tree, oil, yazi
		input = { enabled = false }, -- noice.lua
		statuscolumn = { enabled = false }, -- statuscol.lua
		quickfile = { enabled = true },
		scroll = { enabled = true },
		image = {
			enabled = true, -- markdown images and ```math blocks render inline through kitty's graphics protocol
			convert = { notify = true }, -- a failed conversion reports instead of leaving a blank
		},
		notifier = { enabled = true, timeout = 3000 },
		indent = {
			enabled = true,
			indent = { char = "│", hl = require("utils").rainbow_delimiter_groups },
			animate = { enabled = true, style = "out" },
			scope = { enabled = true },
			chunk = {
				enabled = true,
				char = { corner_top = "╭", corner_bottom = "╰", horizontal = "─", vertical = "│", arrow = "╴" },
			},
		},
		picker = {
			enabled = true,
			ui_select = true,
			focus = "list",
			sources = {
				grep = { focus = "input" }, -- live sources need a query first
				grep_buffers = { focus = "input" },
				git_grep = { focus = "input" },
				lines = { focus = "input" },
				lsp_workspace_symbols = { focus = "input" },
			},
			win = {
				input = { keys = menu_keys, b = { completion = false } },
				list = { keys = menu_keys },
			},
		},
		terminal = {
			win = { border = "rounded" },
		},
	},
	keys = {
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Files",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Git files",
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent files",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Config files",
		},
		{
			"<leader>fp",
			function()
				Snacks.picker.files({ cwd = require("lazy.core.config").options.root })
			end,
			desc = "Plugin files",
		},
		{
			"<leader>fP",
			function()
				Snacks.picker.projects()
			end,
			desc = "Projects",
		},
		{
			"<leader>ed",
			function()
				Snacks.picker.files({ cwd = vim.fn.expand("%:p:h") })
			end,
			desc = "Files in buffer directory",
		},
		{
			"<leader>ew",
			function()
				local win = Snacks.picker.util.pick_win()
				if win then
					vim.api.nvim_set_current_win(win)
				end
			end,
			desc = "Pick window",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>sw",
			function()
				Snacks.picker.grep_word()
			end,
			mode = { "n", "x" },
			desc = "Word or selection",
		},
		{
			"<leader>sb",
			function()
				Snacks.picker.lines()
			end,
			desc = "Buffer lines",
		},
		{
			"<leader>sB",
			function()
				Snacks.picker.grep_buffers()
			end,
			desc = "Grep open buffers",
		},
		{
			"<leader>sh",
			function()
				Snacks.picker.help()
			end,
			desc = "Help pages",
		},
		{
			"<leader>sk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<leader>sc",
			function()
				Snacks.picker.commands()
			end,
			desc = "Commands",
		},
		{
			"<leader>s:",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command history",
		},
		{
			"<leader>s/",
			function()
				Snacks.picker.search_history()
			end,
			desc = "Search history",
		},
		{
			"<leader>sd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>sD",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
			desc = "Buffer diagnostics",
		},
		{
			"<leader>sH",
			function()
				Snacks.picker.highlights()
			end,
			desc = "Highlights",
		},
		{
			"<leader>si",
			function()
				Snacks.picker.icons()
			end,
			desc = "Icons",
		},
		{
			"<leader>sj",
			function()
				Snacks.picker.jumps()
			end,
			desc = "Jumps",
		},
		{
			"<leader>s'",
			function()
				Snacks.picker.marks()
			end,
			desc = "Marks",
		},
		{
			'<leader>s"',
			function()
				Snacks.picker.registers()
			end,
			desc = "Registers",
		},
		{
			"<leader>sa",
			function()
				Snacks.picker.autocmds()
			end,
			desc = "Autocmds",
		},
		{
			"<leader>sM",
			function()
				Snacks.picker.man()
			end,
			desc = "Man pages",
		},
		{
			"<leader>sp",
			function()
				Snacks.picker.lazy()
			end,
			desc = "Plugin specs",
		},
		{
			"<leader>sq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix list",
		},
		{
			"<leader>sl",
			function()
				Snacks.picker.loclist()
			end,
			desc = "Location list",
		},
		{
			"<leader>su",
			function()
				Snacks.picker.undo()
			end,
			desc = "Undo history",
		},
		{
			"<leader>sn",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notifications",
		},
		{ "<leader>sm", "<cmd>Noice history<cr>", desc = "Message history" },
		{
			"<leader>s.",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume last picker",
		},
		{
			"<leader>s?",
			function()
				Snacks.picker()
			end,
			desc = "All pickers",
		},
		{
			"<leader>ld",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Definitions",
		},
		{
			"<leader>lD",
			function()
				Snacks.picker.lsp_declarations()
			end,
			desc = "Declarations",
		},
		{
			"<leader>lr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"<leader>li",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Implementations",
		},
		{
			"<leader>lt",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Type definitions",
		},
		{
			"<leader>ls",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "Document symbols",
		},
		{
			"<leader>lS",
			function()
				Snacks.picker.lsp_workspace_symbols()
			end,
			desc = "Workspace symbols",
		},
		{
			"<leader>lc",
			function()
				Snacks.picker.lsp_incoming_calls()
			end,
			desc = "Incoming calls",
		},
		{
			"<leader>lC",
			function()
				Snacks.picker.lsp_outgoing_calls()
			end,
			desc = "Outgoing calls",
		},
		{
			"<leader>gl",
			function()
				Snacks.lazygit()
			end,
			desc = "LazyGit",
		},
		{
			"<leader>gb",
			function()
				Snacks.gitbrowse()
			end,
			mode = { "n", "x" },
			desc = "Open in browser",
		},
		{
			"<leader>gc",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Commits",
		},
		{
			"<leader>gC",
			function()
				Snacks.picker.git_log_file()
			end,
			desc = "Commits (file)",
		},
		{
			"<leader>gS",
			function()
				Snacks.picker.git_status()
			end,
			desc = "Status",
		},
		{
			"<leader>gB",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "Branches",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.git_diff()
			end,
			desc = "Changed hunks",
		},
		{ "<C-,>", term("float"), mode = { "n", "t" }, desc = "Terminal (float)" },
		{ "<leader>tf", term("float"), desc = "Float" },
		{ "<leader>tv", term("vertical"), desc = "Vertical split" },
		{ "<leader>th", term("horizontal"), desc = "Horizontal split" },
		{
			"<leader>tm",
			function()
				Snacks.terminal.toggle("btop")
			end,
			desc = "btop",
		},
		{
			"<leader>us",
			function()
				Snacks.scratch()
			end,
			desc = "Scratch buffer",
		},
		{
			"<leader>uS",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select scratch buffer",
		},
		{
			"<leader>uz",
			function()
				Snacks.zen()
			end,
			desc = "Zen mode",
		},
		{
			"<leader>uZ",
			function()
				Snacks.zen.zoom()
			end,
			desc = "Zoom window",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss notifications",
		},
		{
			"<leader>ui",
			function()
				Snacks.image.hover()
			end,
			desc = "Image or diagram in a float",
		},
	},
	config = function(_, opts)
		require("snacks").setup(opts)
		Snacks.toggle.option("number", { name = "Line numbers" }):map("<leader>on")
		Snacks.toggle.option("relativenumber", { name = "Relative numbers" }):map("<leader>or")
		Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>ow")
		Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>oS")
		Snacks.toggle.indent():map("<leader>oi")
		Snacks.toggle.dim():map("<leader>oD")
		Snacks.toggle.diagnostics():map("<leader>ox")
		Snacks.toggle.inlay_hints():map("<leader>oh")
		vim.treesitter.query.set( -- the plugin's own query also hands ```mermaid blocks to mmdc, which needs a Chromium; math only here
			"markdown",
			"images",
			[[(fenced_code_block (info_string (language) @lang) (#eq? @lang "math") (code_fence_content) @image.content (#set! injection.language "latex") (#set! image.ext "math.tex")) @image]]
		)
	end,
}
