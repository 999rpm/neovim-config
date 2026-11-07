-- saghen/blink.cmp: completion and signature help in insert mode and on the : command line. Insert keys act only
-- while blink's menu or documentation is open and otherwise fall through to the built-in key ("fallback"), so <Tab>
-- still indents or jumps a snippet field, <CR> breaks the line, <C-e> copies the character below, <C-k> starts a
-- digraph. On the command line <Tab>/<S-Tab> open blink's menu only where Neovim itself has completions for the line,
-- and are the built-in keys elsewhere, a literal Tab inside a string included. Owns no leader prefix.

---Command-line <Tab>/<S-Tab>: blink's menu where Neovim completes the line (getcompletion), else false, so the
---"fallback" after it runs the built-in key.
---@param select "select_next"|"select_prev"
local function cmdline_tab(select)
	return function(cmp)
		if cmp.is_visible() then
			return cmp[select]()
		end
		local kind = vim.fn.getcmdtype()
		if kind == ":" or kind == "@" then
			local ok, items =
				pcall(vim.fn.getcompletion, vim.fn.getcmdline(), kind == ":" and "cmdline" or vim.fn.getcmdcompltype())
			if not ok or #items == 0 then
				return false -- an input() prompt with no completion type raises; the built-in key handles both cases
			end
		end
		return cmp.show_and_insert_or_accept_single(
			select == "select_prev" and { initial_selected_item_idx = -1 } or nil
		)
	end
end

return {
	"saghen/blink.cmp",
	version = "*",
	dependencies = { "rafamadriz/friendly-snippets" }, -- blink scans 'runtimepath' for its snippet folders and no require loads them onto it; lazydev comes through its provider module below
	event = { "InsertEnter", "CmdlineEnter" }, -- the first : already completes through blink, not the built-in wildmenu

	opts = {
		fuzzy = {
			implementation = require("utils.core").executable("git") and "prefer_rust_with_warning" or "prefer_rust", -- without git blink cannot read its binary's version and takes its Lua matcher; only with git is that worth a warning
		},
		keymap = {
			preset = "none",

			["<Tab>"] = { "select_next", "snippet_forward", "fallback" }, -- i: next item, else next snippet field, else the built-in <Tab> (0.12's snippet jump or a tab)
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" }, -- i: previous item, else previous snippet field
			["<CR>"] = { "accept", "fallback" }, -- i: insert the selected item; with no menu a plain line break
			["<C-Space>"] = { "show", "hide", "fallback" }, -- i: open or close the menu by hand
			["<C-e>"] = { "hide", "fallback" }, -- i: close the menu; with none open, the built-in "copy the character below"
			["<C-k>"] = { "show_documentation", "hide_documentation", "fallback" }, -- i: the item's docs on and off; with no menu, the built-in digraph key
			["<M-k>"] = { "scroll_documentation_up", "fallback" }, -- i: scroll the docs up (<C-b> is tmux's prefix)
			["<M-j>"] = { "scroll_documentation_down", "fallback" }, -- i: scroll the docs down; insert-mode <C-f> stays the built-in re-indent
		},

		signature = { enabled = true },

		-- blink's own command-line keys (its "cmdline" preset), each the built-in key while the menu is closed: (c)
		-- <C-n>/<C-p> next/previous, <C-y> accept, <C-e> cancel, <C-Space> open the menu.
		cmdline = {
			keymap = {
				preset = "cmdline",
				["<Tab>"] = { cmdline_tab("select_next"), "fallback" }, -- c: upgrades built-in <Tab>: blink's fuzzy menu where Neovim has completions, else the built-in
				["<S-Tab>"] = { cmdline_tab("select_prev"), "fallback" }, -- c: upgrades built-in <S-Tab> the same way, from the last item
				["<Left>"] = false, -- c: false drops the preset key, so the arrow moves the cursor on the command line
				["<Right>"] = false, -- c: the same for the right arrow
				["<End>"] = false, -- c: <End> goes to the end of the line again
			},
		},

		sources = {
			per_filetype = {
				lua = { inherit_defaults = true, "lazydev" }, -- in the default list it loaded lazydev in markdown buffers too
			},
			providers = {
				lsp = {
					score_offset = 10,
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},

		completion = {
			menu = {
				draw = {
					treesitter = { "lsp" }, -- LSP labels highlighted as code; the border follows 'winborder'
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind", gap = 1 },
					},
				},
			},
			documentation = {
				auto_show = true,
			},
		},
	},
}
