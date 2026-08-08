-- lukas-reineke/indent-blankline.nvim (module name "ibl"): virtual-text indent guides, rainbow
-- colored to match plugins/treesitter/rainbow-delimiters.lua, with the current scope's guide
-- boundary-marked via treesitter. Replaces snacks.lua's `indent` module — see that file's note.
--
-- 2026-08-06: added this pass (config-wide audit, full scope in init.lua). What this plugin
-- can and can't do, verified against its own source/README before writing this, not assumed:
--   • RAINBOW — real: `indent.highlight`/`scope.highlight` cycle through the same
--     RainbowDelimiter* group names rainbow-delimiters.lua uses (shared list:
--     utils.rainbow_delimiter_groups), plus the official `scope_highlight_from_extmark` hook
--     so the current scope's guide always matches the exact color of its own bracket pair
--     rather than just "a" rainbow color — verified against ibl's README rainbow-delimiters
--     integration example.
--   • "TREE-LIKE" GUIDES — partially, and it's worth being precise about what actually
--     happens: ibl draws one virtual-text character per indent level per line (`char` below)
--     and marks the current scope's start/end lines with an UNDERLINE (`scope.show_start`/
--     `show_end`) — confirmed from ibl's own highlight source, which has no separate
--     corner-glyph rendering path at all. That underline reads as a boundary marker, similar
--     in spirit to a tree view's corner connectors, but it will not literally draw
--     "┌"/"└"/"├" box-drawing glyphs at exact structural positions the way a file tree does.
--     If that literal effect matters more than staying on indent-blankline specifically,
--     shellRaining/hlchunk.nvim's "chunk" module does draw real box-drawing corners — a
--     different plugin, not swapped in here since indent-blankline was asked for by name.
--   • ANIMATION — not available anywhere in this plugin. That's a snacks.indent/
--     mini.indentscope-specific feature with no indent-blankline equivalent; said plainly here
--     rather than faked, since it's the one part of the original ask this plugin can't do.
--   • FOLD (nvim-ufo) COMPATIBILITY — no special wiring needed: options.lua's `foldtext = ""`
--     (Nvim 0.10+'s extmark-based closed-fold rendering, already required for ufo's own
--     virtual-text fold summaries) is the same prerequisite indent-blankline needs to draw
--     guides correctly across a closed fold's line — confirmed against indent-blankline#901.
--     With that already set, closed folds just work; nothing to add here.
return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- scope detection is treesitter-backed
		"hiphish/rainbow-delimiters.nvim", -- must define its RainbowDelimiter* groups before this plugin references them by name
	},
	config = function()
		local rainbow = require("utils").rainbow_delimiter_groups
		local hooks = require("ibl.hooks")
		hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

		require("ibl").setup({
			indent = {
				char = "│",
				tab_char = "│",
				highlight = rainbow,
			},
			scope = {
				enabled = true,
				show_start = true, -- underline the line where the current scope opens
				show_end = true, -- underline the line where the current scope closes
				highlight = rainbow,
			},
			exclude = {
				-- ibl's own defaults (lspinfo/packer/checkhealth/help/man/gitcommit/
				-- TelescopePrompt/TelescopeResults/"") plus this config's own utility buffers
				-- that indent guides add no value in.
				filetypes = {
					"lspinfo",
					"packer",
					"checkhealth",
					"help",
					"man",
					"gitcommit",
					"TelescopePrompt",
					"TelescopeResults",
					"",
					"alpha",
					"neo-tree",
					"oil",
					"Trouble",
					"lazy",
					"mason",
					"notify",
				},
				buftypes = { "terminal", "nofile", "quickfix", "prompt" },
			},
		})
	end,
}
