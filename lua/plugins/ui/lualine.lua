-- nvim-lualine/lualine.nvim: global statusline with slanted separators, the same glyphs and edge colouring as barbar's tabline.
-- Ahead/behind counts compare HEAD with its upstream as last fetched (lazygit or `git fetch` updates them).
return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	config = function()
		local lazy_status = require("lazy.status")
		local status = require("utils.statusline")
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
			diff = { added = "✚ ", modified = "󰏫 ", removed = "✖ " },
			git = { ahead = "󰮽", behind = "󰮷" },
		}

		local function hide_in_width()
			return fn.winwidth(0) > 100
		end

		local git_status_cache = { behind_count = 0, ahead_count = 0 }

		local update_git_status = status.throttle(function()
			local dir = fn.expand("%:p:h")
			if fn.isdirectory(dir) == 0 then
				return
			end
			local cmd = { "git", "-C", dir, "rev-list", "--left-right", "--count", "HEAD...@{upstream}" } -- local refs only: no fetch racing lazygit for git's lock files
			vim.system(cmd, { text = true }, function(res)
				local ahead, behind = (res.code == 0 and res.stdout or ""):match("(%d+)%s+(%d+)")
				git_status_cache.ahead_count, git_status_cache.behind_count =
					tonumber(ahead) or 0, tonumber(behind) or 0
			end)
		end, 5000)

		vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
			group = require("utils.core").augroup("lualine-git-status"),
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
			local venv = status.virtual_env()
			return venv ~= "" and ("󰌠 " .. venv) or ""
		end

		local function trailing_space()
			if not vim.bo.modifiable then
				return ""
			end
			return status.buf_cached(
				"trailing_space",
				function() -- whole-buffer search: once per edit, not once per statusline redraw
					local space = fn.search([[\s\+$]], "nwc")
					return space ~= 0 and "TW:" .. space or ""
				end
			)
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
			return status.buf_cached("mixed_indent", scan_mixed_indent) -- up to four whole-buffer searches; cached like trailing_space above
		end

		local function kernel()
			local name = vim.b._999rpm_kernel -- set by notebook/molten.lua when a kernel starts; reading it costs no call into molten
			return name and ("󰘚 " .. name) or ""
		end

		local function get_lsp_clients()
			local clients = vim.lsp.get_clients({ bufnr = 0 }) -- this buffer's servers, not every server in the session
			if #clients == 0 then
				return ""
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
				path = 1, -- 0 = file name only, 1 = relative path, 2 = absolute path
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
			kernel = {
				kernel,
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
			showcmd = {
				"%S", -- 'showcmdloc' is statusline (options.lua): pending counts, registers and operators appear here
			},
		}

		require("lualine").setup({
			options = {
				theme = "auto",
				globalstatus = true,
				component_separators = { left = "\u{e0bb}", right = "\u{e0bb}" }, -- written as escapes: private-use glyphs do not survive every copy of this file
				section_separators = { left = "\u{e0bc}", right = "\u{e0ba}" },
				disabled_filetypes = {
					statusline = {
						"snacks_dashboard",
						"neo-tree",
						"trouble",
						"lazy",
						"mason",
						"snacks_picker_list",
						"snacks_picker_input",
					},
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
					components.showcmd,
					components.lazy,
					components.spaces,
					components.indent,
					components.diagnostics,
					components.kernel,
					components.lsp,
				},
				lualine_y = { "filetype", "encoding", "fileformat" },
				lualine_z = { "progress", "location" },
			},
		})
	end,
}
