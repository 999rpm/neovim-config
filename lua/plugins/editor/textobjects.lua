-- nvim-treesitter/nvim-treesitter-textobjects: select/swap/move by treesitter node (function,
-- class, parameter, local scope) instead of line/word-based Vim motions.
--
-- Three keymap choices below deliberately avoid Neovim's own built-ins rather than shadow them:
-- parameter swap is on `<leader>a`/`<leader>A` (not `]p`/`[p`, Neovim's built-in indent-
-- adjusted paste — matches this plugin's own README-suggested swap keymap); class start/end
-- navigation is on `]m`/`[m`/`]M`/`[M` (not lowercase `]c`/`[c`, Neovim's *native* diff-mode
-- navigation, which genuinely lives inside plugins/git/diffview.lua's windows — freed-up `]c`/
-- `[c` belongs to gitsigns.nvim's own hunk navigation instead, see plugins/git/gitsigns.lua's
-- note); and parameter start navigation is on `],`/`[,` (not `]a`/`[a`, Neovim's built-in
-- argument-list navigation, `:next`/`:previous` — confirmed against this config's real installed
-- runtime, $VIMRUNTIME/lua/vim/_core/defaults.lua's "vim-unimpaired style mappings" block; `,`
-- matches this same file's own `a,`/`i,` parameter-select textobjects below, so "," stays the
-- one mnemonic for "parameter" throughout this file). `]]`/`[[` (jsx element nav, below) also
-- technically shadows Vim's ancient section-jump default (`{` at column 1) — left as-is since
-- that convention essentially never matches in this config's actual filetypes (JS/TS/Python/
-- Lua/Rust/etc. under 2-space indent), unlike the other two, which fire in any buffer.
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	event = { "BufReadPost", "BufNewFile", "BufWritePre" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	init = function()
		vim.g.no_plugin_maps = true
	end,
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
				selection_modes = {
					["@function.outer"] = "V",
					["@function.inner"] = "V",
					["@class.outer"] = "V",
					["@class.inner"] = "V",
					["@parameter.outer"] = "v",
				},
				include_surrounding_whitespace = false,
			},
			move = {
				set_jumps = true,
			},
		})

		-- 1. Selection Keymaps
		local select = require("nvim-treesitter-textobjects.select")
		vim.keymap.set({ "x", "o" }, "af", function()
			select.select_textobject("@function.outer", "textobjects")
		end, { desc = "Select outer part of a function" })
		vim.keymap.set({ "x", "o" }, "if", function()
			select.select_textobject("@function.inner", "textobjects")
		end, { desc = "Select inner part of a function" })
		vim.keymap.set({ "x", "o" }, "ac", function()
			select.select_textobject("@class.outer", "textobjects")
		end, { desc = "Select outer part of a class" })
		vim.keymap.set({ "x", "o" }, "ic", function()
			select.select_textobject("@class.inner", "textobjects")
		end, { desc = "Select inner part of a class" })
		vim.keymap.set({ "x", "o" }, "as", function()
			select.select_textobject("@local.scope", "textobjects")
		end, { desc = "Select local scope" })
		vim.keymap.set({ "x", "o" }, "a,", function()
			select.select_textobject("@parameter.outer", "textobjects")
		end, { desc = "Select outer part of a parameter" })
		vim.keymap.set({ "x", "o" }, "i,", function()
			select.select_textobject("@parameter.inner", "textobjects")
		end, { desc = "Select inner part of a parameter" })

		-- 2. Swap Keymaps — <leader>a/<leader>A, not ]p/[p (native indent-paste; see header note)
		local swap = require("nvim-treesitter-textobjects.swap")
		vim.keymap.set("n", "<leader>a", function()
			swap.swap_next("@parameter.inner")
		end, { desc = "Swap parameter with next" })
		vim.keymap.set("n", "<leader>A", function()
			swap.swap_previous("@parameter.inner")
		end, { desc = "Swap parameter with previous" })

		-- 3. Movement Keymaps (Goto Start)
		local move = require("nvim-treesitter-textobjects.move")
		vim.keymap.set({ "n", "x", "o" }, "]f", function()
			move.goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function start" })
		vim.keymap.set({ "n", "x", "o" }, "]m", function()
			move.goto_next_start("@class.outer", "textobjects")
		end, { desc = "Next class start" })
		vim.keymap.set({ "n", "x", "o" }, "],", function()
			move.goto_next_start("@parameter.inner", "textobjects")
		end, { desc = "Next parameter start" })
		vim.keymap.set({ "n", "x", "o" }, "]]", function()
			move.goto_next_start("@jsx.element", "textobjects")
		end, { desc = "Next jsx element start" })

		vim.keymap.set({ "n", "x", "o" }, "[f", function()
			move.goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Previous function start" })
		vim.keymap.set({ "n", "x", "o" }, "[m", function()
			move.goto_previous_start("@class.outer", "textobjects")
		end, { desc = "Previous class start" })
		vim.keymap.set({ "n", "x", "o" }, "[,", function()
			move.goto_previous_start("@parameter.inner", "textobjects")
		end, { desc = "Previous parameter start" })
		vim.keymap.set({ "n", "x", "o" }, "[[", function()
			move.goto_previous_start("@jsx.element", "textobjects")
		end, { desc = "Previous jsx element start" })

		-- 4. Movement Keymaps (Goto End)
		vim.keymap.set({ "n", "x", "o" }, "]F", function()
			move.goto_next_end("@function.outer", "textobjects")
		end, { desc = "Next function end" })
		vim.keymap.set({ "n", "x", "o" }, "]M", function()
			move.goto_next_end("@class.outer", "textobjects")
		end, { desc = "Next class end" })

		vim.keymap.set({ "n", "x", "o" }, "[F", function()
			move.goto_previous_end("@function.outer", "textobjects")
		end, { desc = "Previous function end" })
		vim.keymap.set({ "n", "x", "o" }, "[M", function()
			move.goto_previous_end("@class.outer", "textobjects")
		end, { desc = "Previous class end" })
	end,
}
