-- Bridges Neovim to the `opencode` CLI agent — a terminal-native agent (runs as a real process
-- you talk to) rather than avante.lua's direct-API sidebar; different tool, kept alongside it
-- rather than instead of it per the original request.
--
-- DELIBERATE SUBSTITUTION: ecosse3/nvim uses sudo-tee/opencode.nvim, but that plugin's own
-- README currently states it is "in early development... not recommended for production use
-- yet." NickvanDyke/opencode.nvim is used here instead — same underlying `opencode` CLI, a more
-- established plugin — since installing something its own author flags as not production-ready
-- into a daily-driver config isn't a "verified solution," whatever its provenance.
--
-- The snacks.nvim dependency below does NOT copy this plugin's own README example (which passes
-- `opts = { input = {}, picker = {}, terminal = {} }` — bare `{}` enables a module at its
-- defaults). plugins/ui/snacks.lua already deliberately sets `input.enabled = false` and
-- `picker.enabled = false` (routed through noice.nvim / telescope.nvim instead) — lazy.nvim
-- merges every spec for the same plugin name, so copying that example verbatim would silently
-- re-enable both against this config's own settled choice. Explicit below instead: input/picker
-- stay off (reinforcing, not fighting, snacks.lua's own values), only `terminal` — which nothing
-- else in this config claims or disables — is actually opted in, since opencode.nvim's default
-- `toggle()` implementation needs it.
return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		{
			"folke/snacks.nvim",
			opts = {
				input = { enabled = false },
				picker = { enabled = false },
				terminal = {},
			},
		},
	},
	init = function()
		vim.o.autoread = true -- required for opencode.nvim's auto_reload; options.lua already sets this, restated here since this plugin depends on it specifically
	end,
	keys = {
		{
			"<leader>io",
			function()
				require("opencode").toggle()
			end,
			desc = "Toggle Opencode",
		},
		{
			"<leader>ic",
			function()
				require("opencode").ask("@this: ")
			end,
			mode = { "n", "x" },
			desc = "Ask Opencode About This",
		},
	},
}
