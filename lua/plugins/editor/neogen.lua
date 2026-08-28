-- danymat/neogen: generate a docstring/annotation skeleton (params, return type, etc.) for the
-- function, class, or type under the cursor, from its treesitter node — a generation tool in
-- the same spirit as plugins/editor/nvim-scissors.lua (snippet insertion) and
-- plugins/editor/dial.lua (smarter in-place editing), not an LSP feature. `<leader>cn` joins
-- the existing `<leader>c` Code group (conform/treesj/nvim-scissors/tw-values already live
-- there) — no which-key.lua change needed, that group entry already exists.
return {
	"danymat/neogen",
	cmd = "Neogen",
	keys = {
		{
			"<leader>cn",
			function()
				require("neogen").generate()
			end,
			desc = "Generate Annotation",
		},
	},
	opts = {
		-- Neogen supports 5 engines (luasnip/snippy/vsnip/nvim/mini — verified against
		-- lua/neogen/snippet.lua); this config has none of the first three installed, and
		-- mini.nvim's own snippet module (plugins/editor/mini.lua) isn't one of the mini.*
		-- modules enabled there. "nvim" needs nothing extra at all — Neovim 0.10+'s own
		-- built-in `vim.snippet` (`:h vim.snippet`), which this config's 0.12+ requirement
		-- already satisfies.
		snippet_engine = "nvim",
	},
}
