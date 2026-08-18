-- ThePrimeagen/harpoon (harpoon2 branch): pin a handful of files, jump between them fast.
-- All keymaps live under `<leader>h*`, matching which-key.lua's "Harpoon" group.
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

		vim.keymap.set("n", "<leader>ha", function()
			harpoon:list():add()
		end, { desc = "Harpoon Add File" })

		vim.keymap.set("n", "<leader>hh", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon Menu" })

		vim.keymap.set("n", "<leader>hd", function()
			harpoon:list():remove()
		end, { desc = "Harpoon Remove File" })

		vim.keymap.set("n", "<leader>h1", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon File 1" })
		vim.keymap.set("n", "<leader>h2", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon File 2" })
		vim.keymap.set("n", "<leader>h3", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon File 3" })
		vim.keymap.set("n", "<leader>h4", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon File 4" })

		----------------------------------------------------------------
		-- Context-Aware Cycling (<leader>hp / <leader>hn)
		----------------------------------------------------------------
		local function cycle(dir)
			local list = harpoon:list()
			local items = list.items
			if not items or #items == 0 then
				return
			end

			local current = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0))
			if not current then
				return
			end

			for i, item in ipairs(items) do
				local item_path = item.value and vim.uv.fs_realpath(item.value)
				if item_path == current then
					local next_index = i + dir
					if next_index < 1 then
						next_index = #items
					elseif next_index > #items then
						next_index = 1
					end
					list:select(next_index)
					return
				end
			end
		end

		vim.keymap.set("n", "<leader>hp", function()
			cycle(-1)
		end, { desc = "Harpoon Previous File" })

		vim.keymap.set("n", "<leader>hn", function()
			cycle(1)
		end, { desc = "Harpoon Next File" })
	end,
}
