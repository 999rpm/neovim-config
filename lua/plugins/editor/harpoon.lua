-- ThePrimeagen/harpoon (harpoon2): pin a few files and jump between them.
-- Keys: <leader>ha add, hd remove, hh menu, h1..h4 jump to a pinned file, hn/hp next/previous pinned file.
-- Menu: <Tab>/<S-Tab> down/up, <CR> open, <C-v>/<C-s> vsplit/split, q or <Esc> close; editing lines reorders or removes entries.
local function list()
	return require("harpoon"):list()
end

---Step to the next or previous pinned file, wrapping at the ends.
---@param step integer
local function cycle(step)
	local harpoon = require("harpoon")
	local items = harpoon:list()
	local current = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0))
	if not current or #items.items == 0 then
		return
	end
	for i, item in ipairs(items.items) do
		if item.value and vim.uv.fs_realpath(item.value) == current then
			items:select((i - 1 + step) % #items.items + 1)
			return
		end
	end
end

local keys = {
	{
		"<leader>ha",
		function()
			list():add()
		end,
		desc = "Add file",
	},
	{
		"<leader>hd",
		function()
			list():remove()
		end,
		desc = "Remove file",
	},
	{
		"<leader>hh",
		function()
			local harpoon = require("harpoon")
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end,
		desc = "Menu",
	},
	{
		"<leader>hn",
		function()
			cycle(1)
		end,
		desc = "Next file",
	},
	{
		"<leader>hp",
		function()
			cycle(-1)
		end,
		desc = "Previous file",
	},
}

for i = 1, 4 do
	table.insert(keys, {
		"<leader>h" .. i,
		function()
			list():select(i)
		end,
		desc = "File " .. i,
	})
end

return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = keys, -- lazy-loaded: the spec above is the only place the keys are declared
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
				require("utils.core").menu_nav(cx.bufnr) -- <Tab>/<S-Tab>, as in the picker, quickfix and dropbar
				vim.keymap.set("n", "<C-v>", function()
					harpoon.ui:select_menu_item({ vsplit = true })
				end, { buf = cx.bufnr, desc = "Open in vsplit" })
				vim.keymap.set("n", "<C-s>", function()
					harpoon.ui:select_menu_item({ split = true })
				end, { buf = cx.bufnr, desc = "Open in split" })
			end,
		})
	end,
}
