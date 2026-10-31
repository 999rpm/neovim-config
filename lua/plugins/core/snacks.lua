-- folke/snacks.nvim: picker, terminals, notifier, indent guides, dashboard, scratch buffers, zen, lazygit, git browse,
-- reference highlighting, inline images and the on/off switches. Pickers open in the result list (normal mode), those
-- that start from a typed query (grep, lines, workspace symbols, projects) in the input, and rank by frecency;
-- terminals run the login shell (utils/shell.lua) while 'shell' stays sh. kitty draws markdown images and ```math
-- blocks inline; d2 diagrams come from lang/d2-diagrams.lua. Under Neovide, which draws no images and animates
-- scrolling itself, images and smooth scrolling are off.
-- Prefixes: <leader>f find files, <leader>s search contents, <leader>l LSP lists (lspconfig.lua adds lw), <leader>t
-- terminals, and parts of <leader>e explore, <leader>g git, <leader>u UI and <leader>o switches; ]r/[r references.
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
	["<Tab>"] = { "list_down", mode = { "i", "n" } }, -- i/n: next result; upstream marks with it, <C-Space> marks here
	["<S-Tab>"] = { "list_up", mode = { "i", "n" } }, -- i/n: previous result
	["<C-Space>"] = { "select_and_next", mode = { "i", "n" } }, -- i/n: mark for multi-select, then move on
	["<A-j>"] = { "preview_scroll_down", mode = { "i", "n" } }, -- i/n: scroll the preview; <C-b>, upstream's scroll up, is tmux's prefix
	["<A-k>"] = { "preview_scroll_up", mode = { "i", "n" } }, -- i/n: scroll the preview back
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
		scroll = { enabled = not vim.g.neovide }, -- Neovide animates scrolling itself
		words = { enabled = true }, -- underlines the symbol under the cursor where it recurs; ]r/[r walk them
		image = {
			enabled = not vim.g.neovide, -- markdown images and ```math blocks inline, through kitty's graphics protocol
			convert = { notify = true }, -- a failed conversion reports instead of leaving a blank
		},
		notifier = { enabled = true },
		indent = {
			enabled = true,
			indent = { hl = require("utils.core").rainbow_delimiter_groups },
			chunk = {
				enabled = true,
				char = {
					corner_top = "╭",
					corner_bottom = "╰",
					arrow = "╴",
				},
			},
		},
		picker = {
			enabled = true,
			focus = "list",
			matcher = { frecency = true, cwd_bonus = true }, -- files opened often and recently, and files under the cwd, rank first
			sources = {
				grep = { focus = "input" }, -- live sources need a query first
				grep_buffers = { focus = "input" },
				git_grep = { focus = "input" },
				lines = { focus = "input" },
				lsp_workspace_symbols = { focus = "input" },
				projects = { focus = "input" }, -- <leader>wp: a typed name filters at once; the list would take its letters as commands
				diagnostics = {
					filter = {
						filter = function(item)
							return not require("utils.notebook").is_cell_buffer(item.buf or item.file or "")
						end, -- otter's hidden cell buffers repeat what the notebook already shows
					},
				},
			},
			win = {
				input = { keys = menu_keys, b = { completion = false } },
				list = { keys = menu_keys },
			},
		},
		terminal = {
			shell = require("utils.shell").login_shell(), -- 'shell' is sh (options.lua); a terminal is where the login shell belongs
			win = { border = "rounded" },
		},
	},
	-- Keys inside snacks windows that come from snacks itself:
	--   picker (i/n): <CR> open, <S-CR> open in a picked window, <C-s>/<C-v>/<C-t> split/vsplit/tab, <C-q> results to
	--     quickfix, <C-a> mark all, <C-n>/<C-p> or <C-j>/<C-k> next/previous, <C-d>/<C-u> scroll the list, <C-f> scroll
	--     the preview, <C-g> live grep on/off, <A-h>/<A-i> hidden/ignored files, <A-p> preview, <A-m> maximize,
	--     <A-w> cycle windows, <C-Up>/<C-Down> query history; (n) i or / type a query, j/k move, gg/G top/bottom, ? help,
	--     q or <Esc> close; (i) <C-r><C-w> insert the word under the cursor, <C-c> close
	--   terminal: (t) <Esc><Esc> normal mode, a single <Esc> reaches the shell; (n) q hide, gf open the file under the cursor
	--   dashboard: f find file, n new file, g grep, r recent files, c config files, s restore session, L Lazy, q quit,
	--     digits open the recent file with that number
	keys = {
		{ "<leader>ff", pick("files"), desc = "Files" }, -- n: fuzzy-find a file under the working directory
		{ "<leader>fg", pick("git_files"), desc = "Git files" }, -- n: only files git tracks
		{ "<leader>fb", pick("buffers"), desc = "Buffers" }, -- n: switch to an open buffer
		{ "<leader>fr", pick("recent"), desc = "Recent files" }, -- n: files opened lately, any project
		{ "<leader>fc", pick("files", { cwd = vim.fn.stdpath("config") }), desc = "Config files" }, -- n: files of this Neovim config
		{
			"<leader>fp",
			function()
				Snacks.picker.files({ cwd = require("lazy.core.config").options.root })
			end,
			desc = "Plugin sources",
		}, -- n: files inside the installed plugins, to read their code or docs

		{
			"<leader>ed",
			function()
				Snacks.picker.files({ cwd = vim.fn.expand("%:p:h") })
			end,
			desc = "Files in buffer directory",
		}, -- n: like <leader>ff, rooted at the current file's folder
		{
			"<leader>ew",
			function()
				local win = Snacks.picker.util.pick_win()
				if win then
					vim.api.nvim_set_current_win(win)
				end
			end,
			desc = "Pick window",
		}, -- n: each window shows a letter; typing it moves there

		{ "<leader>/", pick("grep"), desc = "Grep" }, -- n: search file contents while typing, same as <leader>sg
		{ "<leader>sg", pick("grep"), desc = "Grep" }, -- n: live ripgrep over the working directory
		{ "<leader>sw", pick("grep_word"), mode = { "n", "x" }, desc = "Word or selection" }, -- n/x: grep for the word under the cursor or the selected text
		{ "<leader>sb", pick("lines"), desc = "Buffer lines" }, -- n: lines of this buffer
		{ "<leader>sB", pick("grep_buffers"), desc = "Grep open buffers" }, -- n: like sg, limited to open buffers
		{ "<leader>sh", pick("help"), desc = "Help pages" }, -- n: Neovim and plugin :help tags
		{ "<leader>sk", pick("keymaps"), desc = "Keymaps" }, -- n: every mapping with its description, to find a forgotten key
		{ "<leader>sc", pick("commands"), desc = "Commands" }, -- n: Ex commands
		{ "<leader>s:", pick("command_history"), desc = "Command history" }, -- n: past : lines, rerun on <CR>
		{ "<leader>s/", pick("search_history"), desc = "Search history" }, -- n: past / patterns
		{ "<leader>sd", pick("diagnostics"), desc = "Diagnostics" }, -- n: every open buffer's errors and warnings
		{ "<leader>sD", pick("diagnostics_buffer"), desc = "Buffer diagnostics" }, -- n: this buffer only
		{ "<leader>sH", pick("highlights"), desc = "Highlights" }, -- n: highlight groups and their colours
		{ "<leader>si", pick("icons"), desc = "Icons" }, -- n: insert a Nerd Font or emoji glyph
		{ "<leader>sj", pick("jumps"), desc = "Jumps" }, -- n: the jump list that <C-o>/<C-i> walk
		{ "<leader>s'", pick("marks"), desc = "Marks" }, -- n: marks set with m{letter}
		{ '<leader>s"', pick("registers"), desc = "Registers" }, -- n: register contents; <CR> pastes
		{ "<leader>sa", pick("autocmds"), desc = "Autocommands" }, -- n: autocommands and where they come from
		{ "<leader>sM", pick("man"), desc = "Man pages" }, -- n: system manual pages
		{ "<leader>sp", pick("lazy"), desc = "Plugin specs" }, -- n: the plugin specs in this config
		{ "<leader>sq", pick("qflist"), desc = "Quickfix list" }, -- n: the quickfix list as a picker
		{ "<leader>sl", pick("loclist"), desc = "Location list" }, -- n: the window's location list
		{ "<leader>su", pick("undo"), desc = "Undo history" }, -- n: undo states with a diff preview
		{ "<leader>sn", pick("notifications"), desc = "Notification history" }, -- n: every vim.notify popup of the session, errors included, after it fades
		{ "<leader>s.", pick("resume"), desc = "Resume last picker" }, -- n: reopen the last picker as it was
		{
			"<leader>s?",
			function()
				Snacks.picker()
			end,
			desc = "All pickers",
		}, -- n: list every picker source

		{ "<leader>ld", pick("lsp_definitions"), desc = "Definitions" }, -- n: where the symbol is defined, as a list
		{ "<leader>lD", pick("lsp_declarations"), desc = "Declarations" }, -- n: where it is declared
		{ "<leader>lr", pick("lsp_references"), nowait = true, desc = "References" }, -- n: every use of the symbol; nowait, no lr* key follows
		{ "<leader>li", pick("lsp_implementations"), desc = "Implementations" }, -- n: implementations of an interface or method
		{ "<leader>lt", pick("lsp_type_definitions"), desc = "Type definitions" }, -- n: the type of the symbol
		{ "<leader>ls", pick("lsp_symbols"), desc = "Document symbols" }, -- n: functions, classes and fields of this file
		{ "<leader>lS", pick("lsp_workspace_symbols"), desc = "Workspace symbols" }, -- n: symbols across the project, typed query first
		{ "<leader>lc", pick("lsp_incoming_calls"), desc = "Incoming calls" }, -- n: the functions that call the one under the cursor
		{ "<leader>lC", pick("lsp_outgoing_calls"), desc = "Outgoing calls" }, -- n: the functions the one under the cursor calls

		{
			"]r",
			function()
				Snacks.words.jump(vim.v.count1, true)
			end,
			desc = "Next reference",
		}, -- n: next underlined use of the symbol; ]] and [[ stay the built-in section motions
		{
			"[r",
			function()
				Snacks.words.jump(-vim.v.count1, true)
			end,
			desc = "Previous reference",
		}, -- n: previous underlined use; both take a count

		{
			"<leader>gl",
			function()
				Snacks.lazygit()
			end,
			desc = "LazyGit",
		}, -- n: lazygit in a float, for staging, commits and pushes
		{
			"<leader>gb",
			function()
				Snacks.gitbrowse()
			end,
			mode = { "n", "x" },
			desc = "Open in browser",
		}, -- n/x: the file, or the selected lines, on the git host's website
		{ "<leader>gc", pick("git_log"), desc = "Commits" }, -- n: repository history
		{ "<leader>gC", pick("git_log_file"), desc = "Commits (file)" }, -- n: history of this file only
		{ "<leader>gS", pick("git_status"), desc = "Status" }, -- n: changed files, <Tab> stages inside the picker
		{ "<leader>gB", pick("git_branches"), desc = "Branches" }, -- n: switch branch on <CR>
		{ "<leader>gd", pick("git_diff"), desc = "Changed hunks" }, -- n: every changed hunk with a preview

		{ "<C-,>", term("float"), mode = { "n", "t" }, desc = "Terminal (float)" }, -- n/t: show or hide the floating terminal; Ctrl+comma, which no shell binds
		{ "<leader>tf", term("float"), desc = "Float" }, -- n: the same floating terminal
		{ "<leader>tv", term("vertical"), desc = "Vertical split" }, -- n: a terminal on the right, 60 columns
		{ "<leader>th", term("horizontal"), desc = "Horizontal split" }, -- n: a terminal at the bottom, 15 lines
		{
			"<leader>tm",
			function()
				Snacks.terminal.toggle("btop")
			end,
			desc = "btop",
		}, -- n: system monitor (m for monitor)

		{
			"<leader>us",
			function()
				Snacks.scratch()
			end,
			desc = "Scratch buffer",
		}, -- n: a throwaway buffer kept between sessions
		{
			"<leader>uS",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select scratch buffer",
		}, -- n: pick one of the saved scratch buffers
		{
			"<leader>uz",
			function()
				Snacks.zen()
			end,
			desc = "Zen mode",
		}, -- n: centred, distraction-free view; again to leave
		{
			"<leader>uZ",
			function()
				Snacks.zen.zoom()
			end,
			desc = "Zoom window",
		}, -- n: this window full screen for a moment; again to restore
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss notifications",
		}, -- n: clear the notification popups
		{
			"<leader>ui",
			function()
				Snacks.image.hover()
			end,
			desc = "Image or diagram in a float",
		}, -- n: the image or math block under the cursor, larger
	},
	config = function(_, opts)
		require("snacks").setup(opts)
		local toggle = Snacks.toggle
		local function named(t, name) -- indent(), dim() and words() take no options, so the label is set on the toggle
			t.opts.name = name
			return t
		end
		toggle.option("number", { name = "line numbers" }):map("<leader>on") -- n: line numbers on or off
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
			:map("<leader>oN") -- n: relative numbers, uppercase twin of on
		toggle.option("wrap", { name = "wrap" }):map("<leader>ow") -- n: soft wrap of long lines
		toggle.option("spell", { name = "spelling" }):map("<leader>os") -- n: spell checking
		toggle.diagnostics({ name = "diagnostics" }):map("<leader>od") -- n: every diagnostic sign and message
		toggle.inlay_hints({ name = "inlay hints" }):map("<leader>oh") -- n: the grey type and parameter hints
		named(toggle.indent(), "indent guides"):map("<leader>oi") -- n: the vertical indent lines
		named(toggle.dim(), "dimming"):map("<leader>oD") -- n: dim everything outside the current scope
		named(toggle.words(), "reference highlights"):map("<leader>oR") -- n: the underline on other uses of the symbol
		vim.treesitter.query.set( -- the plugin's own query also hands ```mermaid blocks to mmdc, which needs a Chromium; math only here
			"markdown",
			"images",
			[[(fenced_code_block (info_string (language) @lang) (#eq? @lang "math") (code_fence_content) @image.content (#set! injection.language "latex") (#set! image.ext "math.tex")) @image]]
		)
	end,
}
