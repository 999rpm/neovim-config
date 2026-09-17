-- nvim-treesitter/nvim-treesitter-textobjects (main branch): select, swap and move by function, class, parameter and scope.
-- Native motions kept: ]m [m ]M [M (method), ]] [[ (section), as/is (sentence), ]a [a (argument list), ]p [p (indented paste).
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	event = { "BufReadPost", "BufNewFile", "BufWritePre" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	init = function()
		vim.g.no_plugin_maps = true
	end,
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
				selection_modes = {
					["@function.outer"] = "V",
					["@function.inner"] = "V",
					["@class.outer"] = "V",
					["@class.inner"] = "V",
					["@parameter.outer"] = "v",
				},
				include_surrounding_whitespace = false,
			},
			move = { set_jumps = true },
		})

		local select = require("nvim-treesitter-textobjects.select").select_textobject
		local swap = require("nvim-treesitter-textobjects.swap")
		local move = require("nvim-treesitter-textobjects.move")
		local map = vim.keymap.set
		local sel = { "x", "o" }
		local nav = { "n", "x", "o" }

		map(sel, "af", function()
			select("@function.outer", "textobjects")
		end, { desc = "Function (outer)" })
		map(sel, "if", function()
			select("@function.inner", "textobjects")
		end, { desc = "Function (inner)" })
		map(sel, "ac", function()
			select("@class.outer", "textobjects")
		end, { desc = "Class (outer)" })
		map(sel, "ic", function()
			select("@class.inner", "textobjects")
		end, { desc = "Class (inner)" })
		map(sel, "aS", function()
			select("@local.scope", "textobjects")
		end, { desc = "Scope" }) -- as/is stay the native sentence objects
		map(sel, "a,", function()
			select("@parameter.outer", "textobjects")
		end, { desc = "Parameter (outer)" })
		map(sel, "i,", function()
			select("@parameter.inner", "textobjects")
		end, { desc = "Parameter (inner)" })

		map("n", "<leader>a", function()
			swap.swap_next("@parameter.inner")
		end, { desc = "Swap parameter with next" })
		map("n", "<leader>A", function()
			swap.swap_previous("@parameter.inner")
		end, { desc = "Swap parameter with previous" })

		map(nav, "]f", function()
			move.goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function start" })
		map(nav, "[f", function()
			move.goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Previous function start" })
		map(nav, "]F", function()
			move.goto_next_end("@function.outer", "textobjects")
		end, { desc = "Next function end" })
		map(nav, "[F", function()
			move.goto_previous_end("@function.outer", "textobjects")
		end, { desc = "Previous function end" })
		map(nav, "]k", function()
			move.goto_next_start("@class.outer", "textobjects")
		end, { desc = "Next class start" })
		map(nav, "[k", function()
			move.goto_previous_start("@class.outer", "textobjects")
		end, { desc = "Previous class start" })
		map(nav, "]K", function()
			move.goto_next_end("@class.outer", "textobjects")
		end, { desc = "Next class end" })
		map(nav, "[K", function()
			move.goto_previous_end("@class.outer", "textobjects")
		end, { desc = "Previous class end" })
		map(nav, "],", function()
			move.goto_next_start("@parameter.inner", "textobjects")
		end, { desc = "Next parameter" })
		map(nav, "[,", function()
			move.goto_previous_start("@parameter.inner", "textobjects")
		end, { desc = "Previous parameter" })
		map(nav, "]j", function()
			move.goto_next_start("@jsx.element", "textobjects")
		end, { desc = "Next JSX element" })
		map(nav, "[j", function()
			move.goto_previous_start("@jsx.element", "textobjects")
		end, { desc = "Previous JSX element" })
	end,
}
