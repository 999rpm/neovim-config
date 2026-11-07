-- RaafatTurki/hex.nvim: switches the buffer between hex and normal view; writing in hex view re-assembles the file.
-- Needs xxd on $PATH. `nvim -b file` opens straight into hex view: the plugin then loads before the file is read, since
-- its setup() creates the read hook. Once loaded, for the rest of the session, it also opens .bin, .out, .exe,
-- .dll, .png and .jpg files and any file read in a non-UTF-8 encoding in hex view. Owns <leader>ox.
return {
	"RaafatTurki/hex.nvim",
	cmd = { "HexDump", "HexAssemble", "HexToggle" },
	init = function()
		if vim.list_contains(vim.v.argv, "-b") then -- binary mode from the command line
			require("lazy").load({ plugins = { "hex.nvim" } })
		end
	end,
	keys = {
		{ "<leader>ox", "<cmd>HexToggle<cr>", desc = "Toggle hex view" }, -- n: the bytes as xxd prints them, and back again (x for hex)
	},
	opts = {},
	config = function(_, opts)
		if
			require("utils.core").warn_if_missing_exec(
				"xxd",
				"hex.nvim",
				"Install xxd (vim-common on most distros, or xxd-standalone)."
			)
		then
			require("hex").setup(opts) -- without xxd the plugin's own setup aborts with a second, louder error
		end
	end,
}
