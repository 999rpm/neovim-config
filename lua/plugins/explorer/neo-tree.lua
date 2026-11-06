-- nvim-neo-tree/neo-tree.nvim: sidebar tree on the right with git status and diagnostics; barbar.lua shifts the
-- tabline beside it, and a tab left with only the tree closes (autocmds.lua). Renaming or moving a file there (r, m)
-- asks the language servers to update imports, before the move as the protocol has it, and tells them after it. The
-- tree's own keys below replace neo-tree's <Space> toggle, which would swallow the leader key. Owns <leader>ee and
-- <leader>er.

---Handler for neo-tree's move and rename events: workspace/willRenameFiles before the move, whose import edits are
---applied, and workspace/didRenameFiles after it. Snacks.rename calls client.supports_method, which 0.12 deprecates
---with a warning on its first use.
---@param method string workspace/willRenameFiles or workspace/didRenameFiles
---@return fun(args: { source: string, destination: string })
local function lsp_file_rename(method)
	return function(args)
		local params = {
			files = { { oldUri = vim.uri_from_fname(args.source), newUri = vim.uri_from_fname(args.destination) } },
		}
		for _, client in ipairs(vim.lsp.get_clients()) do
			if client:supports_method(method) then
				if method == "workspace/didRenameFiles" then
					client:notify(method, params)
				else
					local resp = client:request_sync(method, params, 1000) -- the move waits for the edits, at most a second
					if resp and resp.result then
						vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
					end
				end
			end
		end
	end
end

---The file under the cursor in a window picked by its letter (snacks' pick_win, as <leader>ew uses); neo-tree's own w
---needs nvim-window-picker, which this config does not install. A folder opens or closes as with <CR>.
---@param state table neo-tree's state of the tree window
local function open_in_picked_window(state)
	local node = state.tree:get_node()
	if node.type ~= "file" then
		return state.commands.open(state)
	end
	local win = Snacks.picker.util.pick_win({
		filter = function(_, buf)
			return vim.bo[buf].buftype == "" -- file windows only: not the tree itself, a terminal or a list
		end,
	})
	if win then
		vim.api.nvim_set_current_win(win)
		vim.cmd.edit(vim.fn.fnameescape(node.path))
	end
end

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	cmd = "Neotree",
	-- neo-tree's own keys in the tree, beside the ones set below: S/s open in a split/vsplit, t in a tab, C close the
	-- folder, z close every folder, A add a folder, T trash, U restore from trash, . make the folder the root, <BS> go
	-- up, H hidden files, / fuzzy-find, D fuzzy-find folders, # fuzzy-sort, f filter, <C-x> clear the filter, [g/]g
	-- previous/next changed file, i file details, b rename the base name, o then c/d/g/m/n/s/t order by
	-- created/diagnostics/git/modified/name/size/type, </> previous/next source.
	keys = {
		{ "<leader>ee", "<cmd>Neotree toggle<cr>", desc = "Toggle tree" }, -- n: open or close the sidebar (e for explore)
		{ "<leader>er", "<cmd>Neotree reveal<cr>", desc = "Reveal file in tree" }, -- n: open it on the current file
	},
	opts = {
		event_handlers = { -- a moved or renamed file asks the language servers to update imports
			{ event = "before_file_move", handler = lsp_file_rename("workspace/willRenameFiles") },
			{ event = "before_file_rename", handler = lsp_file_rename("workspace/willRenameFiles") },
			{ event = "file_moved", handler = lsp_file_rename("workspace/didRenameFiles") },
			{ event = "file_renamed", handler = lsp_file_rename("workspace/didRenameFiles") },
		},
		popup_border_style = "rounded",
		open_files_do_not_replace_types = { "terminal", "trouble", "qf" },

		filesystem = {
			hijack_netrw_behavior = "disabled",
			use_libuv_file_watcher = true,
			filtered_items = {
				hide_dotfiles = false,
				never_show = { ".DS_Store", ".git" },
			},
		},

		default_component_configs = {
			indent = {
				last_indent_marker = "╰",
				with_expanders = true,
				expander_collapsed = "󰅂",
				expander_expanded = "󰅀",
			},
			git_status = {
				symbols = { -- nf-md glyphs; neo-tree's own for these are older private-use ones
					modified = "󰏫",
					untracked = "󰘥",
					ignored = "󰈉",
					staged = "󰄬",
					conflict = "󰀩",
				},
			},
		},
		window = {
			position = "right",
			width = 30,
			mappings = {
				["<space>"] = "none", -- tree: Space stays the leader key
				["<Tab>"] = "toggle_node", -- tree: expand or collapse the folder, as Tab moves through every menu here
				["l"] = "open", -- tree: l, like moving right into the entry
				["h"] = "close_node", -- tree: h, like moving left out of it
				["<2-LeftMouse>"] = "open", -- tree: double click opens
				["<cr>"] = "open", -- tree: Enter opens the file or folder
				["w"] = { open_in_picked_window, desc = "open in a picked window" }, -- tree: each file window shows a letter; typing it opens the file there
				["<esc>"] = "cancel", -- tree: Esc closes a preview or prompt
				["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = false } }, -- tree: the file in a floating preview
				["a"] = { "add", config = { show_path = "none" } }, -- tree: new file; a name ending in / makes a folder
				["d"] = "delete", -- tree: delete after a prompt
				["r"] = "rename", -- tree: rename; imports follow
				["y"] = "copy_to_clipboard", -- tree: mark for copy, then p pastes
				["x"] = "cut_to_clipboard", -- tree: mark for move, then p pastes
				["p"] = "paste_from_clipboard", -- tree: paste the copied or cut entries here
				["c"] = "copy", -- tree: copy to a typed path
				["m"] = "move", -- tree: move to a typed path; imports follow
				["q"] = "close_window", -- tree: close the sidebar
				["R"] = "refresh", -- tree: reread the folders from disk
				["?"] = "show_help", -- tree: every key of the tree
			},
		},
	},
}
