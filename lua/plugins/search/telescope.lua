-- nvim-telescope/telescope.nvim: fuzzy-finder for files/grep/LSP pickers/help/keymaps/etc,
-- extended with fzf's native sorter, a file browser, and vim.ui.select styling. This is the
-- comprehensive, `<leader>s*` picker; plugins/search/fzf.lua covers a faster `<leader>f*`
-- subset of the same territory for the handful of lookups where raw speed matters more than
-- breadth.
return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	cmd = "Telescope",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-ui-select.nvim",
	},

	keys = {
		{ "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
		{
			"<leader>sB",
			function()
				require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					previewer = false,
				}))
			end,
			desc = "Search in current buffer",
		},
		{
			"<leader>se",
			function()
				local telescope = require("telescope")
				local function telescope_buffer_dir()
					return vim.fn.expand("%:p:h")
				end
				telescope.extensions.file_browser.file_browser({
					path = "%:p:h",
					cwd = telescope_buffer_dir(),
					respect_gitignore = false,
					hidden = true,
					grouped = true,
					previewer = false,
					initial_mode = "normal",
					layout_config = { height = 40 },
				})
			end,
			desc = "Open File Browser",
		},
		{ "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Files" },
		{ "<leader>sg", "<cmd>Telescope git_files<cr>", desc = "Git Files" },
		{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
		{ "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
		{ "<leader>sl", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
		{
			"<leader>sn",
			function()
				require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Neovim Config",
		},
		{ "<leader>so", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
		{
			"<leader>sz",
			function()
				require("telescope.builtin").find_files({
					cwd = require("lazy.core.config").options.root,
				})
			end,
			desc = "Find Plugin File",
		},
		{ "<leader>ss", "<cmd>Telescope grep_string<cr>", desc = "Find current Word" },
		{ "<leader>s?", "<cmd>Telescope builtin<cr>", desc = "Telescope Builtin Pickers" },
		{ "<leader>sx", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
		{ "<leader>s.", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
		{
			"<leader>s/",
			function()
				require("telescope.builtin").live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end,
			desc = "Grep Open Files",
		},
	},

	opts = function()
		return {
			defaults = {
				wrap_results = false,
				prompt_prefix = " 󰍉  ",
				selection_caret = "󰍟 ",
				entry_prefix = "  ",
				sorting_strategy = "ascending",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
					},
					width = 0.90,
					height = 0.85,
				},

				file_ignore_patterns = {
					"node_modules",
					".git/",
					"dist",
					"build",
					"%.lock",
				},

				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
					},
					n = {
						["q"] = "close",
					},
				},
			},

			pickers = {
				find_files = {
					hidden = true,
					previewer = true,
				},

				live_grep = {
					previewer = true,
				},

				buffers = {
					theme = "dropdown",
					previewer = false,
				},

				colorscheme = {
					theme = "dropdown",
					previewer = false,
					enable_preview = true,
					ignore_builtins = true,
				},

				diagnostics = {
					layout_config = {
						preview_cutoff = 9999,
					},
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		}
	end,

	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)
		pcall(telescope.load_extension, "file_browser")
		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")

		vim.api.nvim_create_autocmd("LspAttach", {
			group = require("utils").augroup("telescope-lsp-attach"),
			callback = function(event)
				local builtin = require("telescope.builtin")
				local buf = event.buf

				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = buf, desc = "LSP: " .. desc })
				end

				map("<leader>sr", builtin.lsp_references, "Goto References")
				map("<leader>sp", builtin.lsp_implementations, "Goto Implementation")
				map("<leader>sd", builtin.lsp_definitions, "Goto Definition")
				map("<leader>st", builtin.lsp_type_definitions, "Type Definition")
				map("<leader>sy", builtin.lsp_document_symbols, "Document Symbols")
				map("<leader>sw", builtin.lsp_dynamic_workspace_symbols, "Workspace Symbols")
				map("<leader>sc", builtin.lsp_incoming_calls, "Incoming Calls")
				map("<leader>sC", builtin.lsp_outgoing_calls, "Outgoing Calls")
			end,
		})
	end,
}
