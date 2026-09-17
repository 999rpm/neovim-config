-- m4xshen/hardtime.nvim: blocks rapid repeats of hjkl-style keys and suggests a better motion. <leader>oH toggles it; :Hardtime report lists habits.
return {
	"m4xshen/hardtime.nvim",
	lazy = false,
	dependencies = { "MunifTanjim/nui.nvim" },
	opts = {
		disable_mouse = false, -- multicursor.lua uses <C-LeftMouse>
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
		},
	},
	keys = {
		{ "<leader>oH", "<cmd>Hardtime toggle<CR>", desc = "Hardtime" },
	},
}
