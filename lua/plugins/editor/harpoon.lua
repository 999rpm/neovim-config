-- ThePrimeagen/harpoon (harpoon2): pin a few files and jump between them.
-- Menu keys: <Tab>/<S-Tab> down/up, <CR> open, <C-v>/<C-s> vsplit/split, q or <Esc> close; editing lines reorders or removes entries.
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
			},
		})
		harpoon:extend({
			UI_CREATE = function(cx)
				local function map(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buf = cx.bufnr, desc = desc })
				end
				map("<Tab>", "j", "Next entry")
				map("<S-Tab>", "k", "Previous entry")
				map("<C-v>", function()
					harpoon.ui:select_menu_item({ vsplit = true })
				end, "Open in vsplit")
				map("<C-s>", function()
					harpoon.ui:select_menu_item({ split = true })
				end, "Open in split")
			end,
		})

		local function cycle(step)
			local list = harpoon:list()
			local current = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0))
			if not current or #list.items == 0 then
				return
			end
			for i, item in ipairs(list.items) do
				if item.value and vim.uv.fs_realpath(item.value) == current then
					list:select((i - 1 + step) % #list.items + 1)
					return
				end
			end
		end

		local map = vim.keymap.set
		map("n", "<leader>ha", function()
			harpoon:list():add()
		end, { desc = "Add file" })
		map("n", "<leader>hd", function()
			harpoon:list():remove()
		end, { desc = "Remove file" })
		map("n", "<leader>hh", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Menu" })
		for i = 1, 4 do
			map("n", "<leader>h" .. i, function()
				harpoon:list():select(i)
			end, { desc = "File " .. i })
		end
		map("n", "<leader>hn", function()
			cycle(1)
		end, { desc = "Next file" })
		map("n", "<leader>hp", function()
			cycle(-1)
		end, { desc = "Previous file" })
	end,
}
