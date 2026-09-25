-- mrcjkb/rustaceanvim: rust-analyzer client with runnables, debuggables and hover actions (rust_analyzer stays out of lspconfig.lua).
-- Keys in rust buffers: K hover actions (buffer-local, so 0.12 leaves its own LSP K out), <leader>Tc cargo runnables,
-- <leader>Dd debuggables. nvim-dap loads on the first debug action, not at startup.
return {
	"mrcjkb/rustaceanvim",
	version = "^9",
	lazy = false, -- loads itself per filetype
	init = function()
		vim.g.rustaceanvim = {
			tools = { enable_clippy = true },
			server = {
				default_settings = {
					["rust-analyzer"] = {
						diagnostics = {
							experimental = { enable = true }, -- unresolved macros/paths appear while editing; rustc errors still arrive with cargo check on save
						},
					},
				},
			},
		}
	end,
	keys = {
		{
			"K",
			function()
				vim.cmd.RustLsp({ "hover", "actions" })
			end,
			ft = "rust",
			desc = "Hover actions",
		}, -- replaces the LSP default K in rust buffers
		{
			"<leader>Tc",
			function()
				vim.cmd.RustLsp("runnables")
			end,
			ft = "rust",
			desc = "Cargo runnables",
		},
		{
			"<leader>Dd",
			function()
				vim.cmd.RustLsp("debuggables")
			end,
			ft = "rust",
			desc = "Rust debuggables",
		},
	},
}
