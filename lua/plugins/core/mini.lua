-- nvim-mini/mini.nvim: mini.icons (icon provider, also stands in for nvim-web-devicons), mini.ai (text objects),
-- mini.align (alignment) and mini.hipatterns (pattern highlights; notes/logseq.lua hands graph buffers their own).
-- mini.align: gl{motion} (or gl on a selection) then a character aligns on it: glip= lines up a paragraph on =.
-- gL does the same with a live preview, where s enters a split pattern, j cycles the justify side, m sets the merge
-- text, f and i filter, <BS> undoes a step and <CR> accepts. gl/gL, since ga is the built-in character info and gA coerce.
-- mini.ai: a/i + b brackets, q quotes, t tag, a argument, g whole buffer (vag select all, yag yank all, =ig reindent),
-- j notebook cell (vij selects the code, <leader>ko then ij runs it), ? prompt; aN/iN and al/il pick the next/last match.
-- an/in stay 0.12's node selection and g] stays the built-in :tselect, so mini.ai's g[/g] edge jumps are off.
return {
	"nvim-mini/mini.nvim",
	version = "*",
	lazy = false,
	priority = 1000, -- icons must exist before the dashboard and barbar draw
	config = function()
		require("mini.icons").setup()
		require("mini.icons").mock_nvim_web_devicons()
		require("mini.ai").setup({
			n_lines = 500,
			custom_textobjects = {
				f = false, -- af/if come from textobjects.lua (function definition)
				g = require("mini.extra").gen_ai_spec.buffer(), -- whole buffer: vag selects it, yag yanks it
				j = function(ai_type)
					return require("utils").notebook_cell_region(ai_type)
				end, -- notebook cell: ij its code, aj the code with its fence or "# %%" line
			},
			mappings = {
				around_next = "aN", -- off an/in: 0.12 maps those in x and o to select the parent and child treesitter node
				inside_next = "iN",
				goto_left = "", -- empty disables; g] is the built-in :tselect
				goto_right = "",
			},
		})
		require("mini.align").setup({ mappings = { start = "gl", start_with_preview = "gL" } })
		require("mini.hipatterns").setup() -- no global highlighters; graph buffers get theirs through vim.b.minihipatterns_config
	end,
}
