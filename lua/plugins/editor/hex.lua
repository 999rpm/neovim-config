-- RaafatTurki/hex.nvim: switches the buffer between hex and normal view (<leader>oX); writing in hex view re-assembles the file.
-- Needs xxd on $PATH. `nvim -b file` opens straight into hex view.
return {
	"RaafatTurki/hex.nvim",
	cmd = { "HexDump", "HexAssemble", "HexToggle" },
	keys = {
		{ "<leader>oX", "<cmd>HexToggle<cr>", desc = "Toggle Hex View" },
	},
	opts = {},
	config = function(_, opts)
		if require("utils").warn_if_missing_exec("xxd", "hex.nvim", "Install xxd (vim-common on most distros, or xxd-standalone).") then
			require("hex").setup(opts) -- without xxd the plugin's own setup aborts with a second, louder error
		end
	end,
}
