-- kevinhwang91/nvim-bqf: quickfix window with preview, filters and item marks.
-- Quickfix keys: <Tab>/<S-Tab> next/previous item, <C-Space> mark item, zn/zN keep/drop marked, <CR> open, o open and close,
-- p preview, P auto preview, <C-f>/<C-b> scroll preview, <C-x>/<C-v> split/vsplit, t tab, <C-p>/<C-n> previous/next file, </> older/newer list.
local function tab_nav(buf)
	vim.keymap.set("n", "<Tab>", "j", { buf = buf, desc = "Next item" })
	vim.keymap.set("n", "<S-Tab>", "k", { buf = buf, desc = "Previous item" })
end

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
				tab_nav(ev.buf)
			end,
		})
		if vim.bo.filetype == "qf" then
			tab_nav(0) -- the buffer that triggered the lazy load
		end
	end,
}
