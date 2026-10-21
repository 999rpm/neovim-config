-- m4xshen/hardtime.nvim: counts rapid repeats of h j k l, - + gj gk, <CR> <C-n> <C-p> and names a faster motion in a
-- hint. Hint mode, so every key keeps its built-in move however often it is pressed, and the arrows stay enabled; the
-- plugin's default block mode swallows the fourth press and its defaults disable the arrows. The keys it wraps pass
-- straight through (counts and operators included), so no other file maps them. :Hardtime report lists the habits.
-- Owns <leader>oH.
return {
	"m4xshen/hardtime.nvim",
	lazy = false,
	opts = {
		restriction_mode = "hint", -- the count still runs and the hint still shows; the key is never blocked
		disabled_keys = { ["<Up>"] = false, ["<Down>"] = false, ["<Left>"] = false, ["<Right>"] = false }, -- false drops a default entry: the arrows move as usual
		disable_mouse = false, -- multicursor.lua adds cursors with Ctrl+Alt+click
		restricted_keys = {
			["-"] = { "n", "x" },
		},
		disabled_filetypes = { -- merged with the plugin's own list
			snacks_picker_list = true, -- pickers open in normal mode; j/k move through results
			snacks_picker_input = true,
			snacks_terminal = true,
			snacks_notif_history = true,
			dropbar_menu = true,
			harpoon = true,
			["grug-far"] = true,
			yazi = true,
			["nvim-undotree"] = true, -- mappings.lua <leader>uu
			molten_output = true, -- notebook/molten.lua's output window
		},
	},
	keys = {
		{ "<leader>oH", "<cmd>Hardtime toggle<CR>", desc = "Toggle hardtime" }, -- n: counting and hints on or off for the session
	},
}
