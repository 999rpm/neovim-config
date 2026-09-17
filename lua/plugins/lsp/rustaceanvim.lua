-- mrcjkb/rustaceanvim: rust-analyzer client with runnables, debuggables and hover actions (rust_analyzer is not enabled in lspconfig.lua).
return {
	"mrcjkb/rustaceanvim",
	version = "^9",
	lazy = false, -- loads itself per filetype
	dependencies = { "mfussenegger/nvim-dap" }, -- loaded first so rust-analyzer offers debug actions
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
