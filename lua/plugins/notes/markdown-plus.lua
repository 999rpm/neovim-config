-- YousefHadder/markdown-plus.nvim: outliner-style editing for markdown lists, plus tables, checkboxes, links and inline
-- formatting. Lists (insert): <CR> next bullet, <Tab>/<S-Tab> indent/outdent the bullet, <BS> on an empty bullet removes
-- it, <A-CR> a new line inside the same bullet (Logseq's Shift+Enter); o/O (normal) open a bullet below/above. Outside a
-- list those keys keep their usual job, blink's <Tab>/<CR> included.
-- Buffer keys on <localleader> (\): mx toggle checkbox, lt + u/t/n/c change the list type, mb/mi/mS/m`/m= bold/italic/
-- strikethrough/code/highlight, h+/h- promote/demote a heading, ht table of contents, t + a table command (which-key
-- lists them). Tables (insert): <A-h>/<A-j>/<A-k>/<A-l> move between cells.
-- Two defaults go back to Neovim: insert-mode <C-t> (indent the line) and ]b/[b (next/previous buffer). ]]/[[ stay the
-- heading jumps because the markdown ftplugin maps them first.
local conflicts = { ["<C-T>"] = "i", ["]b"] = "n", ["[b"] = "n" }

local function hand_back(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	for lhs, mode in pairs(conflicts) do
		for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
			if map.lhs == lhs and (map.rhs or ""):find("MarkdownPlus", 1, true) then
				pcall(vim.keymap.del, mode, lhs, { buf = buf })
			end
		end
	end
end

return {
	"YousefHadder/markdown-plus.nvim",
	ft = "markdown",
	opts = {},
	config = function(_, opts)
		require("markdown-plus").setup(opts)
		vim.api.nvim_create_autocmd("FileType", {
			group = require("utils").augroup("markdown-plus-keys"),
			pattern = "markdown",
			desc = "999rpm: hand insert <C-t> and ]b/[b back to Neovim in markdown buffers",
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
