-- kevinhwang91/nvim-bqf: quickfix window with preview, filters and item marks.
-- Quickfix keys: <Tab>/<S-Tab> next/previous item, <C-Space> mark item, zn/zN keep/drop marked, <CR> open, o open and close,
-- p preview, P auto preview, <C-f>/<C-b> scroll preview, <C-x>/<C-v> split/vsplit, t tab, <C-p>/<C-n> previous/next file, </> older/newer list.
return {
	"kevinhwang91/nvim-bqf",
	ft = "qf",
	opts = {
		preview = { border = "rounded" },
		func_map = {
			stoggledown = "<C-Space>", -- default <Tab> marks items; <Tab> moves instead, like every other menu here
			stoggleup = "",
			stogglevm = "<C-Space>",
			stogglebuf = "'<C-Space>",
			sclear = "z<C-Space>",
		},
	},
	config = function(_, opts)
		require("bqf").setup(opts)
		vim.api.nvim_create_autocmd("FileType", {
			group = require("utils").augroup("qf-menu-keys"),
			pattern = "qf",
			desc = "999rpm: Tab/S-Tab move through quickfix items",
			callback = function(ev)
				require("utils").menu_nav(ev.buf) -- shared helper; see utils.lua
			end,
		})
		if vim.bo.filetype == "qf" then
			require("utils").menu_nav(0) -- the buffer that triggered the lazy load
		end
	end,
}
