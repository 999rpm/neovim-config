-- Dims the rest of the screen behind Telescope and floating toggleterm windows, using
-- folke/snacks.nvim's own `backdrop` primitive (Snacks.win({backdrop = ...}) — the same
-- mechanism its own picker/zen/scratch/dashboard windows use internally, verified by reading
-- lua/snacks/win.lua directly). No new plugin: snacks.nvim is already installed and loaded
-- eagerly (plugins/ui/snacks.lua), this file only adds two autocmds on top of it.
--
-- Deliberately its own file rather than folded into telescope.lua/toggleterm.lua/snacks.lua:
-- it depends on all three, but none of them need to depend on it or on each other, and neither
-- Telescope's nor toggleterm's own Lua API is called anywhere below — only generic
-- FileType/TermOpen/WinClosed events and `nvim_win_get_config` — so this keeps working across
-- version changes to either plugin without needing updates here.
--
-- Uses the fake local-plugin-spec pattern already established in plugins/ui/themes.lua (a
-- `dir`/`name` spec with no real remote repo) purely to get a lazy.nvim-managed `config`
-- callback at a sensible point in startup.
return {
	{
		dir = vim.fn.stdpath("config"),
		name = "999rpm-float-backdrop",
		dependencies = { "folke/snacks.nvim" },
		event = "VeryLazy",
		config = function()
			local augroup = require("utils").augroup

			-- Upvalue, not vim.g: this only needs to survive within this one Lua closure for
			-- one session, and a snacks.win object (a table with methods/metatables) doesn't
			-- round-trip safely through vim.g's Vimscript bridge the way a plain value would.
			local backdrop_win = nil

			local function show_backdrop()
				if backdrop_win then
					return
				end
				-- A visually-irrelevant 1x1 anchor window: the backdrop itself (a real,
				-- full-editor dim overlay) is what Snacks.win manages on this window's behalf,
				-- always one zindex below it — see lua/snacks/win.lua's `M:drop()`. zindex is
				-- set explicitly below default (50, same as most plugin floats including
				-- Telescope's and toggleterm's own) so the backdrop reliably renders behind
				-- them regardless of which window was actually created first.
				local ok, win = pcall(Snacks.win, {
					enter = false,
					focusable = false,
					backdrop = 60,
					width = 1,
					height = 1,
					row = 0,
					col = 0,
					border = "none",
					zindex = 45,
					bo = { buftype = "nofile", filetype = "snacks_999rpm_backdrop" },
				})
				if ok then
					backdrop_win = win
				end
			end

			local function hide_backdrop()
				if backdrop_win then
					pcall(function()
						backdrop_win:close()
					end)
					backdrop_win = nil
				end
			end

			-- Show the backdrop, then tear it down the moment this exact window closes —
			-- however it closes (Esc, <CR>, :close, toggling the terminal shut again) — via a
			-- one-shot autocmd keyed to its window id, rather than any plugin-specific "closed"
			-- event.
			local function watch(winid)
				show_backdrop()
				vim.api.nvim_create_autocmd("WinClosed", {
					pattern = tostring(winid),
					once = true,
					callback = hide_backdrop,
				})
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = augroup("float-backdrop-telescope"),
				pattern = "TelescopePrompt",
				callback = function()
					watch(vim.api.nvim_get_current_win())
				end,
			})

			-- toggleterm reuses the same terminal buffer across toggles, so TermClose (the
			-- process exiting) is the wrong signal — a toggle just hides the *window*, the
			-- buffer/job stays alive. Checking `relative ~= ""` on the window itself (true only
			-- for a floating window) is what distinguishes a `direction=float` terminal from a
			-- split/vertical one, without asking toggleterm for that information directly.
			vim.api.nvim_create_autocmd("TermOpen", {
				group = augroup("float-backdrop-toggleterm"),
				callback = function()
					local win = vim.api.nvim_get_current_win()
					if vim.api.nvim_win_get_config(win).relative ~= "" then
						watch(win)
					end
				end,
			})
		end,
	},
}
