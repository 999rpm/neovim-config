-- folke/snacks.nvim: picker, terminals, notifier, indent guides, scratch, zen, lazygit, git browse, reference
-- highlighting and the option toggles under <leader>o.
-- Picker: opens in the result list (normal mode). <Tab>/<S-Tab> next/previous, <C-Space> mark for multi-select,
-- <C-a> mark all, <CR> open, i or / type a query, <C-s>/<C-v>/<C-t> split/vsplit/tab, <C-q> to quickfix,
-- <A-h>/<A-i> hidden/ignored files, <A-p> preview, ? help, q or <Esc> close. Results rank by frecency.
-- Terminal: <Esc><Esc> normal mode, q (normal mode) hide, gf open file under cursor.
-- Images: kitty draws markdown images and LaTeX math inline; <leader>ui opens the one under the cursor in a float.
-- d2 diagrams render through tree-sitter-d2.lua. Dashboard (bare `nvim`): f find, n new, g grep, r recent, c config,
-- s restore session, L Lazy, q quit; digits open the recent files listed below the keys. <leader>ew picks a window by letter.
-- snacks.words underlines every occurrence of the symbol under the cursor, and ]r/[r walk them.
local function pick(source, opts) -- one wrapper instead of a closure per key
	return function()
		Snacks.picker[source](opts)
	end
end

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
		words = { enabled = true, debounce = 200 }, -- underlines the symbol under the cursor where it recurs; ]r/[r walk them
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
			matcher = { frecency = true, cwd_bonus = true }, -- files opened often and recently, and files under the cwd, rank first
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
		{ "<leader>ff", pick("files"), desc = "Files" },
		{ "<leader>fg", pick("git_files"), desc = "Git files" },
		{ "<leader>fb", pick("buffers"), desc = "Buffers" },
		{ "<leader>fr", pick("recent"), desc = "Recent files" },
		{ "<leader>fc", pick("files", { cwd = vim.fn.stdpath("config") }), desc = "Config files" },
		{
			"<leader>fp",
			function()
				Snacks.picker.files({ cwd = require("lazy.core.config").options.root })
			end,
			desc = "Plugin sources",
		},
		{ "<leader>fP", pick("projects"), desc = "Projects" },

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

		{ "<leader>/", pick("grep"), desc = "Grep" },
		{ "<leader>sg", pick("grep"), desc = "Grep" },
		{ "<leader>sw", pick("grep_word"), mode = { "n", "x" }, desc = "Word or selection" },
		{ "<leader>sb", pick("lines"), desc = "Buffer lines" },
		{ "<leader>sB", pick("grep_buffers"), desc = "Grep open buffers" },
		{ "<leader>sh", pick("help"), desc = "Help pages" },
		{ "<leader>sk", pick("keymaps"), desc = "Keymaps" },
		{ "<leader>sc", pick("commands"), desc = "Commands" },
		{ "<leader>s:", pick("command_history"), desc = "Command history" },
		{ "<leader>s/", pick("search_history"), desc = "Search history" },
		{ "<leader>sd", pick("diagnostics"), desc = "Diagnostics" },
		{ "<leader>sD", pick("diagnostics_buffer"), desc = "Buffer diagnostics" },
		{ "<leader>sH", pick("highlights"), desc = "Highlights" },
		{ "<leader>si", pick("icons"), desc = "Icons" },
		{ "<leader>sj", pick("jumps"), desc = "Jumps" },
		{ "<leader>s'", pick("marks"), desc = "Marks" },
		{ '<leader>s"', pick("registers"), desc = "Registers" },
		{ "<leader>sa", pick("autocmds"), desc = "Autocommands" },
		{ "<leader>sM", pick("man"), desc = "Man pages" },
		{ "<leader>sp", pick("lazy"), desc = "Plugin specs" },
		{ "<leader>sq", pick("qflist"), desc = "Quickfix list" },
		{ "<leader>sl", pick("loclist"), desc = "Location list" },
		{ "<leader>su", pick("undo"), desc = "Undo history" },
		{ "<leader>sn", pick("notifications"), desc = "Notifications" },
		{ "<leader>sm", "<cmd>Noice history<cr>", desc = "Message history" },
		{ "<leader>s.", pick("resume"), desc = "Resume last picker" },
		{
			"<leader>s?",
			function()
				Snacks.picker()
			end,
			desc = "All pickers",
		},

		{ "<leader>ld", pick("lsp_definitions"), desc = "Definitions" },
		{ "<leader>lD", pick("lsp_declarations"), desc = "Declarations" },
		{ "<leader>lr", pick("lsp_references"), nowait = true, desc = "References" },
		{ "<leader>li", pick("lsp_implementations"), desc = "Implementations" },
		{ "<leader>lt", pick("lsp_type_definitions"), desc = "Type definitions" },
		{ "<leader>ls", pick("lsp_symbols"), desc = "Document symbols" },
		{ "<leader>lS", pick("lsp_workspace_symbols"), desc = "Workspace symbols" },
		{ "<leader>lc", pick("lsp_incoming_calls"), desc = "Incoming calls" },
		{ "<leader>lC", pick("lsp_outgoing_calls"), desc = "Outgoing calls" },

		{
			"]r",
			function()
				Snacks.words.jump(vim.v.count1, true)
			end,
			desc = "Next reference",
		}, -- ]] and [[ stay the built-in section motions
		{
			"[r",
			function()
				Snacks.words.jump(-vim.v.count1, true)
			end,
			desc = "Previous reference",
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
		{ "<leader>gc", pick("git_log"), desc = "Commits" },
		{ "<leader>gC", pick("git_log_file"), desc = "Commits (file)" },
		{ "<leader>gS", pick("git_status"), desc = "Status" },
		{ "<leader>gB", pick("git_branches"), desc = "Branches" },
		{ "<leader>gd", pick("git_diff"), desc = "Changed hunks" },

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
		local toggle = Snacks.toggle
		local function named(t, name) -- indent(), dim() and words() take no options, so the label is set on the toggle
			t.opts.name = name
			return t
		end
		toggle.option("number", { name = "line numbers" }):map("<leader>on")
		toggle
			.new({
				id = "relativenumber",
				name = "relative numbers",
				get = function()
					return vim.g._999rpm_relativenumber ~= false
				end,
				set = function(state)
					vim.g._999rpm_relativenumber = state -- read by autocmds.lua's number_toggle group, which would turn them back on
					vim.wo.relativenumber = state and vim.wo.number
				end,
			})
			:map("<leader>oN")
		toggle.option("wrap", { name = "wrap" }):map("<leader>ow")
		toggle.option("spell", { name = "spelling" }):map("<leader>os")
		toggle.diagnostics({ name = "diagnostics" }):map("<leader>od")
		toggle.inlay_hints({ name = "inlay hints" }):map("<leader>oh")
		named(toggle.indent(), "indent guides"):map("<leader>oi")
		named(toggle.dim(), "dimming"):map("<leader>oD")
		named(toggle.words(), "reference highlights"):map("<leader>oR")
		vim.treesitter.query.set( -- the plugin's own query also hands ```mermaid blocks to mmdc, which needs a Chromium; math only here
			"markdown",
			"images",
			[[(fenced_code_block (info_string (language) @lang) (#eq? @lang "math") (code_fence_content) @image.content (#set! injection.language "latex") (#set! image.ext "math.tex")) @image]]
		)
	end,
}
