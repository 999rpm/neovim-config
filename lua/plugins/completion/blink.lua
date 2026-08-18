-- saghen/blink.cmp: completion engine (LSP/path/snippets/buffer + lazydev.lua's Lua-API
-- source), with its own signature-help popup — plugins/ui/noice.lua explicitly disables its
-- LSP signature integration in favor of this one (see noice.lua's `lsp.signature.enabled =
-- false`).
return {
	"saghen/blink.cmp",
	version = "*",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"folke/lazydev.nvim", -- full config in plugins/lsp/lazydev.lua; listed here for install/load ordering only
	},
	event = "InsertEnter", -- Better than VimEnter (loads only when you start typing)

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
				-- Reads friendly-snippets (this plugin's own dependency, VS-Code-format JSON)
				-- plus this repo's own user snippets — plugins/editor/nvim-scissors.lua's
				-- `snippetDir` writes to this exact same path, so anything added/edited there
				-- shows up here too, not just on disk.
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

		-- accept = { auto_brackets = { enabled = true } }, -- blink's own native "insert () after
		-- accepting a function/method completion" (added v0.7.0) — the modern replacement for
		-- wiring nvim-autopairs into the completion-accept event the old nvim-cmp way. Left off
		-- by default since it hasn't been verified conflict-free against autopairs.lua's normal
		-- typed-bracket pairing in this specific setup; uncomment to try it.
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
