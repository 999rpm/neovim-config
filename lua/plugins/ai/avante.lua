-- yetone/avante.nvim: agentic AI sidebar (plan/edit/suggest against real project context, not
-- just single-line completions) — a different kind of assistance than plugins/completion/
-- copilot.lua's inline ghost-text, which stays untouched; the two don't compete for any key
-- below. `<leader>i*` ("AI"), not `<leader>a`: that prefix is already this config's parameter-
-- swap (plugins/editor/textobjects.lua, direct `<leader>a`/`<leader>A` bindings, not a group) —
-- reusing it here would force a timeoutlen wait onto that existing, frequently-used command
-- every time it's pressed, waiting to see if more keys follow. New group in which-key.lua.
--
-- Needs `make` (real build step; this repo's README.md already lists a C compiler as a
-- treesitter requirement, `make` itself is a separate, not-strictly-guaranteed prerequisite —
-- if the build step fails, avante still loads with reduced/no native-extension functionality
-- rather than breaking the rest of this config) and an API key — checked once below via
-- utils.warn_if_missing_env(), same shape as every other "external prerequisite" check in this
-- config (copilot.lua's Node version, dap.lua's Mason binaries, treesitter.lua's tree-sitter
-- CLI). `ANTHROPIC_API_KEY` is the standard env var name across most Claude-API integrations;
-- double-check against avante's own current docs if it prompts for a key despite this being set.
return {
	"yetone/avante.nvim",
	build = "make",
	event = "VeryLazy",
	version = false, -- avante's own docs: never pin this to "*", the plugin tracks Nvim API changes closely
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"echasnovski/mini.nvim",
	},
	opts = {
		provider = "claude",
		providers = {
			-- Anthropic's own current lineup uses undated rolling aliases rather than the
			-- fixed dated snapshots common through 2025 (e.g. the previous value here,
			-- claude-sonnet-4-20250514, a May 2025 pin over a year stale by this pass) --
			-- claude-sonnet-5 is the current fast/flagship-tier alias as of this pass; check
			-- Anthropic's own model list if this ever 404s rather than reverting to a dated pin.
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-sonnet-5",
			},
		},
		behaviour = {
			auto_suggestions = false, -- don't compete with copilot.lua's own ghost text
			auto_apply_diff_after_generation = false, -- review before applying, not automatic
			-- Without this, avante.setup() ALSO registers its own default `<leader>a*` keymaps
			-- (ask/toggle/zen_mode/refresh/focus/stop/select_model/…, from its own config.lua's
			-- `mappings` table) on top of the `<leader>i*` ones below — despite the header note
			-- above already choosing `<leader>i*` specifically to avoid `<leader>a` (textobjects.lua's
			-- parameter swap). avante's own "safe" keymap installer (avante/utils/init.lua's
			-- safe_keymap_set) only checks lazy.nvim's declarative `keys` registry for conflicts,
			-- which can't see textobjects.lua's plain `vim.keymap.set()` call — so it doesn't detect
			-- this one. Net effect confirmed live: `<leader>a` still runs the swap, but `<leader>aa`/
			-- `<leader>at`/etc. also exist, making `<leader>a` simultaneously a leaf and a prefix,
			-- which which-key resolves by descending into avante's group instead of firing the leaf.
			-- Sidebar-internal maps (diff resolution, jump, suggestion-accept) are unaffected — those
			-- are buffer-local to avante's own windows (see sidebar.lua's matching keymap.del on
			-- close), never global, so they were never part of this conflict.
			auto_set_keymaps = false,
		},
	},
	keys = {
		{
			"<leader>ia",
			function()
				require("avante").toggle()
			end,
			mode = { "n", "x" },
			desc = "Toggle Avante Sidebar",
		},
		{
			"<leader>ie",
			function()
				require("avante").edit()
			end,
			mode = { "n", "x" },
			desc = "Avante Edit Selection",
		},
		-- The rest of avante's own default actions (config.lua's `mappings` table — everything
		-- `auto_set_keymaps = false` above just turned off) given real, deliberate `<leader>i*`
		-- slots instead of living behind that flag by accident. Each calls straight into
		-- `avante.api` (the same public module avante's own default keymaps call, confirmed by
		-- reading avante/init.lua's `H.keymaps()` directly) rather than the `<Plug>` mappings —
		-- matching `ia`/`ie` above, which already call `require("avante")` directly instead of
		-- `<Plug>(AvanteToggle)`/`<Plug>(AvanteEdit)`. Letters avoid `a`/`e` (this file) and
		-- `o`/`c` (plugins/ai/opencode.lua, same `<leader>i` group) — none nest under `ia`/`ie`
		-- either, which would silently recreate the very `<leader>a` ambiguity bug this file's
		-- `auto_set_keymaps` comment above just fixed, one level deeper.
		{
			"<leader>iA",
			function()
				require("avante.api").ask()
			end,
			mode = { "n", "x" },
			desc = "Avante Ask",
		},
		{
			"<leader>in",
			function()
				require("avante.api").ask({ new_chat = true })
			end,
			mode = { "n", "x" },
			desc = "Avante New Chat",
		},
		{
			"<leader>is",
			function()
				require("avante.api").stop()
			end,
			desc = "Avante Stop Generation",
		},
		{
			"<leader>ir",
			function()
				require("avante.api").refresh()
			end,
			desc = "Avante Refresh",
		},
		{
			"<leader>if",
			function()
				require("avante.api").focus()
			end,
			desc = "Avante Focus Window",
		},
		{
			"<leader>im",
			function()
				require("avante.api").select_model()
			end,
			desc = "Avante Select Model",
		},
		{
			"<leader>ih",
			function()
				require("avante.api").select_history()
			end,
			desc = "Avante Select History",
		},
		{
			"<leader>ib",
			function()
				require("avante.api").add_buffer_files()
			end,
			desc = "Avante Add All Buffers",
		},
		{
			"<leader>iF",
			function()
				require("avante.api").add_selected_file(vim.api.nvim_buf_get_name(0))
			end,
			desc = "Avante Add Current File",
		},
		{
			"<leader>iz",
			function()
				require("avante.api").zen_mode()
			end,
			mode = { "n", "x" },
			desc = "Avante Zen Mode",
		},
		{
			"<leader>iR",
			function()
				require("avante.repo_map").show()
			end,
			desc = "Avante Show Repo Map",
		},
		-- Deliberately not given a slot: `toggle.suggestion` (config.lua) would add a manual
		-- override for the exact feature `behaviour.auto_suggestions = false` above turns off on
		-- purpose, to not compete with copilot.lua — binding it back in fights that same-file
		-- decision. `toggle.debug`/`toggle.selection` are real but narrow (internal debug
		-- logging; the ask/edit hint popup on visual selection) — low daily value, `:lua
		-- require("avante").toggle.debug()` / `.selection()` still work uncalled-for. `select_
		-- acp_model`/`select_acp_mode`/`switch_provider` are for avante's ACP bridge to *other*
		-- agent CLIs — this file's `provider = "claude"` above uses avante's direct Anthropic API
		-- instead, so these don't apply to the current setup.
	},
	config = function(_, opts)
		require("utils").warn_if_missing_env("ANTHROPIC_API_KEY", "avante.nvim")
		require("avante").setup(opts)
	end,
}
