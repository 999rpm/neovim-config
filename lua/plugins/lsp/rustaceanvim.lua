-- mrcjkb/rustaceanvim: Rust-specific LSP client management (rust-analyzer) plus runnables,
-- debuggables, and richer hover actions — lives in lsp/, not lang-tools/, since its actual job
-- is owning an LSP client the same way lspconfig.lua does for every other language, just scoped
-- to one. A previously-open candidate (AUDIT_SUMMARY.md), added now that a plugin addition is
-- an explicit ask rather than a verification-pass judgment call.
--
-- Upstream's own README carries an explicit warning: don't also configure `rust_analyzer`
-- through nvim-lspconfig/`vim.lsp.enable()`, since this plugin manages that client itself —
-- confirmed against a fresh clone, not assumed. `rust_analyzer` is therefore removed from
-- plugins/lsp/lspconfig.lua's own `servers` table (see that file's own note) rather than run
-- alongside this plugin; it stays in plugins/lsp/mason.lua's `ensure_installed` regardless,
-- since Mason's job there is only keeping the `rust-analyzer` binary installed; nothing about
-- that requires nvim-lspconfig to be the one starting it. `enable_clippy` below is this plugin's
-- own equivalent of the `check.command = "clippy"` override lspconfig.lua used to carry —
-- verified against current source (lua/rustaceanvim/config/internal.lua): defaults to `true`
-- (auto-detects a clippy install) already, restated explicitly for the same reason dap-ui.lua/
-- neo-tree.lua restate their own current upstream defaults rather than relying on them silently.
--
-- No `setup()` call by design — confirmed against the README, this is a filetype plugin that
-- configures itself once a `.rs`/`Cargo.toml` buffer loads; `vim.g.rustaceanvim` below is read
-- at that point. Keymaps are ft-scoped via lazy.nvim's own `keys[].ft` rather than
-- `after/ftplugin/rust.lua` (upstream's own suggested location) — this config centralizes
-- keymaps in the file that owns the plugin everywhere else, and lazy.nvim's `ft` field on a
-- `keys` entry achieves the same "only in a Rust buffer" scoping without a second file/location.
--
-- `K` is overridden a second time here, buffer-scoped to `rust` on top of lspconfig.lua's
-- generic `K` (border + size) — rustaceanvim's own `hover actions` view adds inline, actionable
-- buttons (go to definition of a hovered type, etc.) that the generic `vim.lsp.buf.hover()` call
-- can't. Native `gra` (code action) is deliberately left alone rather than replaced with
-- `RustLsp codeAction`: the only real upstream benefit is grouping related actions, native `gra`
-- already calls the same underlying LSP request and works correctly, and upstream's own
-- suggested key for this is `<leader>a` — already textobjects.lua's parameter swap in this
-- config, so copying it verbatim was never an option anyway. `<leader>Tc` (Cargo Runnables)
-- joins the existing `<leader>T` Test group (neotest's own Jest-only keys) rather than starting
-- a second, Rust-only group — no which-key.lua change needed, that group entry already exists.
-- Rust *debuggables* need no new keymap at all: `autoload_configurations` (upstream default,
-- left on) appends them straight into `dap.configurations.rust`, already reachable via
-- plugins/debug/dap.lua's existing `<leader>Dp` picker — see that file's own note on the
-- `vim.deepcopy()` fix this addition required there before anything could safely append to it.
return {
	"mrcjkb/rustaceanvim",
	version = "^9",
	lazy = false, -- upstream's own README: "implements proper lazy-loading internally, no need for lazy.nvim to lazy-load it"
	init = function()
		vim.g.rustaceanvim = {
			tools = {
				enable_clippy = true, -- upstream default, restated — see header note
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
			desc = "Hover Actions (rust-analyzer)",
		},
		{
			"<leader>Tc",
			function()
				vim.cmd.RustLsp("runnables")
			end,
			ft = "rust",
			desc = "Cargo Runnables",
		},
	},
}
