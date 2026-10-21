-- mrcjkb/rustaceanvim: rust-analyzer client with runnables, debuggables and hover actions; rust_analyzer stays out of
-- lspconfig.lua. Its keys are buffer-local in rust buffers: K, and <leader>Tc and <leader>Dd in neotest.lua's and
-- dap.lua's groups. nvim-dap loads on the first debug action, not at startup.
return {
	"mrcjkb/rustaceanvim",
	version = "^9",
	lazy = false, -- loads itself per filetype
	init = function()
		vim.g.rustaceanvim = {
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
				if #vim.lsp.get_clients({ bufnr = 0, name = "rust-analyzer" }) > 0 then
					vim.cmd.RustLsp({ "hover", "actions" })
				else
					vim.cmd("normal! " .. (vim.v.count > 0 and vim.v.count or "") .. "K") -- :RustLsp exists only while the server runs
				end
			end,
			ft = "rust",
			desc = "Hover with actions (rust-analyzer)",
		}, -- n: upgrades built-in K: the hover adds runnable and debuggable actions; without rust-analyzer the built-in K, count included
		{
			"<leader>Tc",
			function()
				vim.cmd.RustLsp("runnables")
			end,
			ft = "rust",
			desc = "Cargo runnables",
		}, -- n: pick a cargo run, test or bench target and run it
		{
			"<leader>Dd",
			function()
				vim.cmd.RustLsp("debuggables")
			end,
			ft = "rust",
			desc = "Rust debuggables",
		}, -- n: pick a binary or test and start it under nvim-dap
	},
}
