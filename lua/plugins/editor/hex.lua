-- RaafatTurki/hex.nvim: switches the buffer between hex and normal view; editing in hex view and writing re-assembles the file.
-- Needs xxd on $PATH. `nvim -b file` opens straight into hex view.
return {
	"RaafatTurki/hex.nvim",
	cmd = { "HexDump", "HexAssemble", "HexToggle" },
	keys = {
		{ "<leader>oX", "<cmd>HexToggle<cr>", desc = "Toggle Hex View" },
	},
	opts = {},
	config = function(_, opts)
		require("utils").warn_if_missing_exec(
			"xxd",
			"hex.nvim",
			"Install xxd (vim-common on most distros, or the xxd-standalone AUR package)."
		)
		require("hex").setup(opts)
	end,
}
