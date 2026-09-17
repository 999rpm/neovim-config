-- kylechui/nvim-surround: add, change and delete surrounding pairs.
-- Keys: ys{motion}{char} add, ds{char} delete, cs{old}{new} change; S in visual mode.
return {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
	config = function()
		vim.keymap.set({ "n", "v", "o" }, "s", "<Nop>", { desc = "Disabled (native substitute; c<motion> covers it)" }) -- free native substitute; doesn't conflict with S/gS below
		vim.g.nvim_surround_no_normal_mappings = true -- see header note: only Visual S/gS remain
		require("nvim-surround").setup({})
	end,
}
