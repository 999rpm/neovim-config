-- nvim-neo-tree/neo-tree.nvim: sidebar tree with git status and diagnostics. barbar.lua shifts the tabline beside it.
-- Keys: <leader>ee toggle, <leader>er reveal the current file. In the tree: <Tab> expand, l/<CR> open, h collapse,
-- P float preview, a add, d delete, r rename, y/x/p copy/cut/paste, c copy to, m move, R refresh, q close, ? help.
return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-mini/mini.nvim",
		"MunifTanjim/nui.nvim",
	},
	cmd = "Neotree",
	keys = {
		{ "<leader>ee", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer (Tree)" },
		{ "<leader>er", "<cmd>Neotree reveal<cr>", desc = "Reveal File in Tree" },
	},
	opts = {
		close_if_last_window = false, -- autocmds.lua auto_close_win decides, for quickfix and Trouble windows too
		popup_border_style = "rounded",
		enable_git_status = true,
		enable_diagnostics = true,
		open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
		sort_case_insensitive = false,

		filesystem = {
			hijack_netrw_behavior = "disabled",
			use_libuv_file_watcher = true,
			filtered_items = {
				visible = false,
				hide_dotfiles = false,
				hide_gitignored = true,
				never_show = { ".DS_Store", ".git" },
			},
		},

		default_component_configs = {
			indent = {
				indent_size = 2,
				padding = 1,
				with_markers = true,
				indent_marker = "│",
				last_indent_marker = "╰",
				highlight = "NeoTreeIndentMarker",
				with_expanders = true,
				expander_collapsed = "󰅂",
				expander_expanded = "󰅀",
			},
			git_status = {
				symbols = {
					added = "✚",
					modified = "󰏫",
					deleted = "✖",
					renamed = "󰁕",
					untracked = "󰘥",
					ignored = "󰈉",
					unstaged = "󰄱",
					staged = "󰄬",
					conflict = "󰀩",
				},
			},
		},
		window = {
			position = "left",
			width = 30,
			mapping_options = { noremap = true, nowait = true },
			mappings = {
				["<space>"] = "none",
				["<Tab>"] = "toggle_node",
				["l"] = "open",
				["h"] = "close_node",
				["<2-LeftMouse>"] = "open",
				["<cr>"] = "open",
				["<esc>"] = "cancel",
				["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = false } },
				["a"] = { "add", config = { show_path = "none" } },
				["d"] = "delete",
				["r"] = "rename",
				["y"] = "copy_to_clipboard",
				["x"] = "cut_to_clipboard",
				["p"] = "paste_from_clipboard",
				["c"] = "copy",
				["m"] = "move",
				["q"] = "close_window",
				["R"] = "refresh",
				["?"] = "show_help",
			},
		},
	},
}
