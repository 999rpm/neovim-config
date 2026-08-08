-- folke/lazydev.nvim: scoped `vim.*`/plugin-API completion and types for Lua files inside a
-- Neovim config/plugin directory (this repo included) — without leaking those globals into
-- every other Lua project lua_ls happens to open. plugins/completion/blink.lua wires this in
-- as a completion source; this file just owns lazydev's own setup. Its presence here is also
-- why plugins/lsp/lspconfig.lua's `lua_ls` settings deliberately do NOT add a static
-- `workspace.library` entry for `vim.*` — see that file's own note.
return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
}
