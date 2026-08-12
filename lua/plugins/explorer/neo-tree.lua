-- nvim-neo-tree/neo-tree.nvim: sidebar file-tree explorer, with git status and diagnostics
-- shown inline per file. The persistent-sidebar complement to plugins/explorer/oil.lua's
-- buffer-as-directory editing style — see that file's own header for the split between them.
return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	cmd = "Neotree",
	keys = {
		{ "<leader>ee", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer (Tree)" },
		{ "<leader>er", "<cmd>Neotree reveal<cr>", desc = "Reveal File in Tree" },
	},
	opts = {
		close_if_last_window = true,
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
				expander_collapsed = "",
				expander_expanded = "",
			},
			git_status = {
				symbols = {
					added = "", -- nf-fa-plus
					modified = "", -- nf-fa-pencil
					deleted = "", -- nf-fa-minus
					renamed = "", -- nf-fa-exchange
					untracked = "", -- nf-fa-question
					ignored = "", -- nf-fa-eye_slash
					unstaged = "", -- nf-fa-exclamation
					staged = "", -- nf-fa-check
					conflict = "", -- nf-fa-bug (or similar warning)
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
