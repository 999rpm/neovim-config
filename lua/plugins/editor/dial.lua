-- monaqa/dial.nvim: increment and decrement numbers, dates, booleans and semver. > and < replace the native <C-a>/<C-x>.
return {
	"monaqa/dial.nvim",
	config = function()
		local map = require("dial.map")

		vim.keymap.set("n", ">", function()
			map.manipulate("increment", "normal")
		end, { desc = "Increment (dial)" })
		vim.keymap.set("n", "<", function()
			map.manipulate("decrement", "normal")
		end, { desc = "Decrement (dial)" })
		vim.keymap.set("n", "g<C-a>", function()
			map.manipulate("increment", "gnormal")
		end, { desc = "Increment sequential (dial)" })
		vim.keymap.set("n", "g<C-x>", function()
			map.manipulate("decrement", "gnormal")
		end, { desc = "Decrement sequential (dial)" })

		vim.keymap.set("x", "<C-a>", function()
			map.manipulate("increment", "visual")
		end, { desc = "Increment (dial)" })
		vim.keymap.set("x", "<C-x>", function()
			map.manipulate("decrement", "visual")
		end, { desc = "Decrement (dial)" })
		vim.keymap.set("x", "g<C-a>", function()
			map.manipulate("increment", "gvisual")
		end, { desc = "Increment sequential (dial)" })
		vim.keymap.set("x", "g<C-x>", function()
			map.manipulate("decrement", "gvisual")
		end, { desc = "Decrement sequential (dial)" })
	end,
}
