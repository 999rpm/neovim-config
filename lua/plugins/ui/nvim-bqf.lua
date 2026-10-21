-- kevinhwang91/nvim-bqf: quickfix window with preview, filters and item marks. Loads with the first quickfix window,
-- and its keys act inside that window only: <C-Space> marks items, as in the pickers, and <Tab>/<S-Tab> move to the
-- next/previous item (utils/core.lua). q closes the list (autocmds.lua). Owns no leader prefix.
return {
	"kevinhwang91/nvim-bqf",
	ft = "qf",
	opts = {
		-- bqf's own keys in the quickfix window: <CR> open, o open and close the list, O open with :drop and close, t/T
		-- open in a tab (T stays in the list), <C-t> tab and close, <C-x>/<C-v> split/vsplit, <C-p>/<C-n> previous/next
		-- file, </> older/newer list, '" last item visited, p preview the item, P auto preview, zp preview size, zo
		-- preview back to the item, zn/zN new list from the marked/unmarked items, zf fzf filter.
		func_map = {
			stoggledown = "<C-Space>", -- n: mark the item and move down; bqf's <Tab>, which moves here instead
			stoggleup = "", -- empty: no key, since <S-Tab> moves up
			stogglevm = "<C-Space>", -- x: mark every selected item
			stogglebuf = "'<C-Space>", -- n: mark every item of the same file
			sclear = "z<C-Space>", -- n: clear the marks of this list
			pscrolldown = "<M-j>", -- n: preview half a page down; bqf's <C-f>, moved with <C-b>, which is tmux's prefix
			pscrollup = "<M-k>", -- n: preview half a page up
		},
	},
	config = function(_, opts)
		require("bqf").setup(opts)
		vim.api.nvim_create_autocmd("FileType", {
			group = require("utils.core").augroup("qf-menu-keys"),
			pattern = "qf",
			desc = "999rpm: Tab/S-Tab move through quickfix items",
			callback = function(ev)
				require("utils.core").menu_nav(ev.buf)
			end,
		})
		if vim.bo.filetype == "qf" then
			require("utils.core").menu_nav(0) -- the buffer that triggered the lazy load
		end
	end,
}
