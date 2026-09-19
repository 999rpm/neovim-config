-- kylechui/nvim-surround: add, change and delete surrounding pairs.
-- Keys: ys{motion}{char} add, yss line, yS/ySS on new lines, ds{char} delete, cs{old}{new} change; S and gS in visual mode.
return {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
	config = function()
		vim.keymap.set({ "n", "x", "o" }, "s", "<Nop>", { desc = "Disabled (native substitute; cl covers it)" }) -- ys/ds/cs start with other keys, so nothing here is shadowed
		require("nvim-surround").setup({})
	end,
}
