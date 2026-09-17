-- saghen/blink.cmp: completion and signature help.
-- Keys: <Tab>/<S-Tab> next/previous item, <CR> accept, <C-Space> open menu, <C-e> hide, <C-k> documentation, <C-b>/<C-f> scroll docs.
return {
	"saghen/blink.cmp",
	version = "*",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"folke/lazydev.nvim", -- full config in plugins/lsp/lazydev.lua; listed here for install/load ordering only
	},
	event = "InsertEnter", -- later than VimEnter: nothing loads until insert mode actually starts

	opts = {
		keymap = {
			preset = "none",

			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-Space>"] = { "show", "hide", "fallback" },
			["<C-k>"] = { "show_documentation", "hide_documentation", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		signature = { enabled = true },

		sources = {
			default = { "lsp", "path", "snippets", "buffer", "lazydev" },
			providers = {
				lsp = {
					score_offset = 10,
				},
				snippets = {
					opts = {
						search_paths = { vim.fn.stdpath("config") .. "/snippets" },
					},
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
				border = "rounded",
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind", gap = 1 },
					},
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
			},
		},
	},
}
