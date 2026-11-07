-- YousefHadder/markdown-plus.nvim: outliner-style editing for markdown lists, plus tables, checkboxes, links and inline
-- formatting. Handed back to Neovim: insert-mode <C-t> (indent the line), ]b/[b (next/previous buffer) and gd, which
-- off a table-of-contents link did nothing; lspconfig.lua's gd follows links where markdown-oxide attaches. The
-- insert-mode <A-h/j/k/l> cell moves stay off, so copilot.lua's <M-l> keeps accepting a word. ]]/[[ stay the heading
-- jumps. Owns the markdown buffers' <localleader>m, l, h and t groups.
local conflicts = { ["<C-T>"] = "i", ["]b"] = "n", ["[b"] = "n", gd = "n" }

local function hand_back(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	for lhs, mode in pairs(conflicts) do
		for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
			if map.lhs == lhs and (map.rhs or ""):find("MarkdownPlus", 1, true) then
				vim.keymap.del(mode, lhs, { buf = buf })
			end
		end
	end
end

return {
	"YousefHadder/markdown-plus.nvim",
	ft = "markdown",
	-- markdown-plus's own keys in markdown buffers: (i) <CR> next bullet, <Tab>/<S-Tab> indent/outdent the bullet, <BS>
	-- on an empty bullet removes it, <A-CR> a new line inside the bullet (Logseq's Shift+Enter); (n) o/O a bullet
	-- below/above. Each upgrades built-in <CR>, <Tab>, <S-Tab>, <BS>, o and O inside a list, and does the built-in job
	-- elsewhere, blink's <Tab>/<CR> included. (n) \mx checkbox, \lt then u/t/n/c list type, \mb/\mi/\mS/\m`/\m=
	-- bold/italic/strikethrough/code/highlight, \h+/\h- promote/demote a heading, \ht table of contents, \t then a
	-- table command (which-key lists them).
	opts = {
		table = { keymaps = { insert_mode_navigation = false } },
	},
	config = function(_, opts)
		require("markdown-plus").setup(opts)
		vim.api.nvim_create_autocmd("FileType", {
			group = require("utils.core").augroup("markdown-plus-keys"),
			pattern = "markdown",
			desc = "999rpm: hand insert <C-t>, ]b/[b and gd back to Neovim in markdown buffers",
			callback = function(ev)
				vim.schedule(function()
					hand_back(ev.buf) -- scheduled: markdown-plus maps the buffer in its own FileType handler
				end)
			end,
		})
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[buf].filetype == "markdown" then
				vim.schedule(function()
					hand_back(buf)
				end)
			end
		end
	end,
}
