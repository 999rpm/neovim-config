-- nvim-lualine/lualine.nvim: statusline. Separators match the tabline (U+E0BA, U+E0BB, U+E0BC).
return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-mini/mini.nvim" },
	config = function()
		local lazy_status = require("lazy.status")
		local utils = require("utils")
		local fn = vim.fn

		local icons = {
			modes = {
				NORMAL = "󰨔 ",
				INSERT = "󰏫 ",
				VISUAL = "󰒆 ",
				["V-BLOCK"] = "󰕯 ",
				["V-LINE"] = "󰉢 ",
				REPLACE = "󰯍 ",
				COMMAND = "󰅪 ",
				TERMINAL = "󰞷 ",
			},
			diagnostics = { error = "󰃤 ", warn = "󰀦 ", info = "󰭷 ", hint = "󰌵 " },
			diff = { added = "✚ ", modified = " ", removed = "✖ " },
			git = { ahead = "󰮽", behind = "󰮷" },
		}

		local function hide_in_width()
			return vim.fn.winwidth(0) > 100
		end

		local git_status_cache = { fetch_success = false, behind_count = 0, ahead_count = 0 }

		local function async_cmd(cmd_str, on_exit)
			local cmd = vim.split(cmd_str, " ")
			vim.system(cmd, { text = true }, on_exit)
		end

		local function handle_git_output(key)
			return function(result)
				if result.code == 0 then
					git_status_cache[key] = tonumber(result.stdout:match("(%d+)")) or 0
				else
					git_status_cache[key] = 0
				end
			end
		end

		local update_git_status = utils.throttle(function()
			async_cmd("git fetch origin", function(res)
				if res.code == 0 then
					git_status_cache.fetch_success = true
					async_cmd("git rev-list --count HEAD..@{upstream}", handle_git_output("behind_count"))
					async_cmd("git rev-list --count @{upstream}..HEAD", handle_git_output("ahead_count"))
				end
			end)
		end, 30000)

		vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
			group = utils.augroup("lualine-git-status"),
			desc = "999rpm: refresh the statusline's ahead/behind counts (throttled)",
			callback = update_git_status,
		})

		local function get_git_ahead_behind()
			local msg = ""
			if git_status_cache.ahead_count > 0 then
				msg = msg .. icons.git.ahead .. "[" .. git_status_cache.ahead_count .. "] "
			end
			if git_status_cache.behind_count > 0 then
				msg = msg .. icons.git.behind .. "[" .. git_status_cache.behind_count .. "]"
			end
			return msg
		end

		local function virtual_env()
			if vim.bo.filetype ~= "python" then
				return ""
			end
			local venv = utils.get_virtual_env()
			return venv ~= "" and (" " .. venv) or ""
		end

		local function trailing_space()
			if not vim.bo.modifiable then
				return ""
			end
			return utils.buf_cached("trailing_space", function() -- whole-buffer search: once per edit, not once per statusline redraw
				local space = fn.search([[\s\+$]], "nwc")
				return space ~= 0 and "TW:" .. space or ""
			end)
		end

		local function scan_mixed_indent()
			local space_pat = [[\v^ +]]
			local tab_pat = [[\v^\t+]]
			local space_indent = fn.search(space_pat, "nwc")
			local tab_indent = fn.search(tab_pat, "nwc")
			local mixed = (space_indent > 0 and tab_indent > 0)
			local mixed_same_line
			if not mixed then
				mixed_same_line = fn.search([[\v^(\t+ | +\t)]], "nwc")
				mixed = mixed_same_line > 0
			end
			if not mixed then
				return ""
			end
			if mixed_same_line ~= nil and mixed_same_line > 0 then
				return "MI:" .. mixed_same_line
			end
			local space_indent_cnt = fn.searchcount({ pattern = space_pat, max_count = 1e3 }).total
			local tab_indent_cnt = fn.searchcount({ pattern = tab_pat, max_count = 1e3 }).total
			if space_indent_cnt > tab_indent_cnt then
				return "MI:" .. tab_indent
			else
				return "MI:" .. space_indent
			end
		end

		local function mixed_indent()
			if not vim.bo.modifiable then
				return ""
			end
			return utils.buf_cached("mixed_indent", scan_mixed_indent) -- up to four whole-buffer searches; cached like trailing_space above
		end

		local function get_lsp_clients()
			local clients = vim.lsp.get_clients()
			if #clients == 0 then
				return "No Active Lsp"
			end
			local names = {}
			for _, client in ipairs(clients) do
				names[client.name] = true
			end
			return "󰒋 " .. table.concat(vim.tbl_keys(names), ", ")
		end

		local components = {
			mode = {
				"mode",
				fmt = function(str)
					return (icons.modes[str] or " ") .. str
				end,
			},
			branch = {
				"branch",
				icon = "󰘬",
				color = { gui = "bold" },
			},
			git_status = {
				get_git_ahead_behind,
				cond = hide_in_width,
			},
			filename = {
				"filename",
				path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
				file_status = true, -- displays file status (readonly status, modified status)
				newfile_status = false,
				symbols = {
					modified = " ●",
					readonly = " 󰌾 ",
					unnamed = "[No Name]",
					newfile = "[New]",
				},
			},
			python_env = {
				virtual_env,
			},
			diagnostics = {
				"diagnostics",
				sources = { "nvim_diagnostic" },
				symbols = icons.diagnostics,
			},
			diff = {
				"diff",
				symbols = icons.diff,
				cond = hide_in_width,
			},
			lsp = {
				get_lsp_clients,
				cond = hide_in_width,
			},
			spaces = {
				trailing_space,
			},
			indent = {
				mixed_indent,
			},
			lazy = {
				lazy_status.updates,
				cond = lazy_status.has_updates,
			},
		}

		require("lualine").setup({
			options = {
				theme = "auto",
				globalstatus = true,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = { "alpha", "neo-tree", "Trouble", "lazy", "mason", "snacks_picker_list", "snacks_picker_input" },
					winbar = {},
				}, -- explicit shape: a bare list is copied into both by lualine's own normaliser, which is not what a global statusline wants
			},
			sections = {
				lualine_a = { components.mode },
				lualine_b = {
					components.branch,
					components.git_status,
					components.diff,
				},
				lualine_c = {
					components.filename,
					components.python_env,
				},
				lualine_x = {
					components.lazy,
					components.spaces,
					components.indent,
					components.diagnostics,
					components.lsp,
				},
				lualine_y = { "filetype", "encoding", "fileformat" },
				lualine_z = { "progress", "location" },
			},
		})
	end,
}
