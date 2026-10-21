-- nvim-treesitter/nvim-treesitter-textobjects: select, swap and move by function, class, parameter and scope through
-- each language's treesitter queries (main branch); the parsers come from treesitter.lua. ]m [m ]M [M upgrade the
-- built-in method motions, which only follow Java-style braces, in normal and visual mode; a buffer without a parser
-- and operator-pending mode get the built-in, and the python and ruby ftplugins map their own, which win there.
-- Built-ins kept: ]f/[f open file, ]] [[ sections, as/is sentences. Owns <leader>a and <leader>A; the plugin maps no
-- keys itself.
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	event = { "BufReadPost", "BufNewFile", "BufWritePre" },
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
			},
		})

		local pick = require("nvim-treesitter-textobjects.select").select_textobject -- not `select`, which would hide Lua's own
		local swap = require("nvim-treesitter-textobjects.swap")
		local move = require("nvim-treesitter-textobjects.move")
		local map = vim.keymap.set
		local sel = { "x", "o" }
		local nav = { "n", "x", "o" }
		local method = { "n", "x" } -- not o: the plugin makes every move inclusive there, and the built-in ]m family is exclusive

		map(sel, "af", function()
			pick("@function.outer", "textobjects")
		end, { desc = "Function (outer)" }) -- x/o: the whole function, signature included (vaf, daf)
		map(sel, "if", function()
			pick("@function.inner", "textobjects")
		end, { desc = "Function (inner)" }) -- x/o: only the function body
		map(sel, "ac", function()
			pick("@class.outer", "textobjects")
		end, { desc = "Class (outer)" }) -- x/o: the whole class
		map(sel, "ic", function()
			pick("@class.inner", "textobjects")
		end, { desc = "Class (inner)" }) -- x/o: the class body
		map(sel, "aS", function()
			pick("@local.scope", "textobjects")
		end, { desc = "Scope" }) -- x/o: the enclosing scope; as/is stay the native sentence objects
		map(sel, "a,", function()
			pick("@parameter.outer", "textobjects")
		end, { desc = "Parameter (outer)" }) -- x/o: an argument with its comma (da,)
		map(sel, "i,", function()
			pick("@parameter.inner", "textobjects")
		end, { desc = "Parameter (inner)" }) -- x/o: the argument alone (ci,)

		map("n", "<leader>a", function()
			swap.swap_next("@parameter.inner")
		end, { desc = "Swap parameter with next" }) -- n: move the argument under the cursor one place right
		map("n", "<leader>A", function()
			swap.swap_previous("@parameter.inner")
		end, { desc = "Swap parameter with previous" }) -- n: one place left, uppercase twin

		---The treesitter move where the buffer's language has textobjects queries, else the built-in key; both keep the count.
		---@param builtin string
		---@param name string move.lua function
		local function method_motion(builtin, name)
			return function()
				local parser = vim.treesitter.get_parser()
				if not (parser and vim.treesitter.query.get(parser:lang(), "textobjects")) then
					return builtin
				end
				return ("<Cmd>lua require('nvim-treesitter-textobjects.move').%s('@function.outer', 'textobjects')<CR>"):format(
					name
				)
			end
		end
		map(method, "]m", method_motion("]m", "goto_next_start"), { expr = true, desc = "Next function start" }) -- n/x: upgrades built-in ]m: the next function in any language with a parser, else the built-in
		map(method, "[m", method_motion("[m", "goto_previous_start"), { expr = true, desc = "Previous function start" }) -- n/x: upgrades built-in [m the same way
		map(method, "]M", method_motion("]M", "goto_next_end"), { expr = true, desc = "Next function end" }) -- n/x: upgrades built-in ]M: the end of the next function
		map(method, "[M", method_motion("[M", "goto_previous_end"), { expr = true, desc = "Previous function end" }) -- n/x: upgrades built-in [M: the end of the previous one
		map(nav, "]k", function()
			move.goto_next_start("@class.outer", "textobjects")
		end, { desc = "Next class start" }) -- n/x/o: k for klass, since c is the diff-change motion
		map(nav, "[k", function()
			move.goto_previous_start("@class.outer", "textobjects")
		end, { desc = "Previous class start" }) -- n/x/o: the previous class
		map(nav, "]K", function()
			move.goto_next_end("@class.outer", "textobjects")
		end, { desc = "Next class end" }) -- n/x/o: the end of the next class
		map(nav, "[K", function()
			move.goto_previous_end("@class.outer", "textobjects")
		end, { desc = "Previous class end" }) -- n/x/o: the end of the previous class
		map(nav, "],", function()
			move.goto_next_start("@parameter.inner", "textobjects")
		end, { desc = "Next parameter" }) -- n/x/o: the next argument of a call or signature
		map(nav, "[,", function()
			move.goto_previous_start("@parameter.inner", "textobjects")
		end, { desc = "Previous parameter" }) -- n/x/o: the previous argument
		map(nav, "]j", function()
			move.goto_next_start("@jsx.element", "textobjects")
		end, { desc = "Next JSX element" }) -- n/x/o: j for JSX; notebook buffers use ]j for cells instead
		map(nav, "[j", function()
			move.goto_previous_start("@jsx.element", "textobjects")
		end, { desc = "Previous JSX element" }) -- n/x/o: the previous JSX element
	end,
}
