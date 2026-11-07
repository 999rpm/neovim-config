-- ThePrimeagen/harpoon: pin a few files and jump between them (harpoon2 branch). Owns <leader>h.
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
	}, -- n: pin the current file at the end of the list
	{
		"<leader>hd",
		function()
			list():remove()
		end,
		desc = "Remove file",
	}, -- n: unpin the current file
	{
		"<leader>hh",
		function()
			local harpoon = require("harpoon")
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end,
		desc = "Menu",
	}, -- n: the pinned list; editing its lines reorders or removes pins
	{
		"<leader>hn",
		function()
			cycle(1)
		end,
		desc = "Next file",
	}, -- n: the pin after the current file, wrapping at the end
	{
		"<leader>hp",
		function()
			cycle(-1)
		end,
		desc = "Previous file",
	}, -- n: the pin before it, wrapping at the start
}

for i = 1, 4 do
	table.insert(keys, {
		"<leader>h" .. i,
		function()
			list():select(i)
		end,
		desc = "File " .. i,
	}) -- n: <leader>h1 to <leader>h4 jump straight to that pin
end

return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	-- harpoon's own keys in its menu: <CR> open, q or <Esc> close.
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
				require("utils.core").menu_nav(cx.bufnr) -- menu: <Tab>/<S-Tab> down and up, as in the picker, quickfix and dropbar
				vim.keymap.set("n", "<C-v>", function()
					harpoon.ui:select_menu_item({ vsplit = true })
				end, { buf = cx.bufnr, desc = "Open in vsplit" }) -- menu: the entry in a vertical split, as in the picker
				vim.keymap.set("n", "<C-s>", function()
					harpoon.ui:select_menu_item({ split = true })
				end, { buf = cx.bufnr, desc = "Open in split" }) -- menu: in a horizontal split
			end,
		})
	end,
}
