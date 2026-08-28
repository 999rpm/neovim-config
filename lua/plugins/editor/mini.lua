-- echasnovski/mini.nvim: mini.ai (textobjects) and mini.icons (filetype/extension icon
-- provider). `lazy = false, priority = 1000` — not `event = "VeryLazy"` as this file used
-- before mini.icons joined it — because icons need to exist before the FIRST consumer asks for
-- one: plugins/ui/alpha.lua's dashboard renders on VimEnter, earlier than VeryLazy fires, and
-- every other icon consumer (bufferline, telescope, neo-tree, oil, trouble, fzf-lua, avante,
-- octo, render-markdown, lualine) could in principle load before VeryLazy too, depending on
-- what the very first buffer/command is. Matches plugins/ui/snacks.lua's own `lazy = false,
-- priority = 1000` for the identical reason (something else needs it ready from the start).
--
-- mini.icons replaces nvim-tree/nvim-web-devicons as this config's actual icon provider — a
-- previously-open candidate (yutkat/dotfiles' own live choice, AUDIT_SUMMARY.md), added now
-- that a provider swap is an explicit ask rather than a verification-pass judgment call.
-- `MiniIcons.mock_nvim_web_devicons()` (verified against current source,
-- lua/mini/icons.lua: registers itself into `package.preload`/`package.loaded` under the exact
-- name "nvim-web-devicons") is the reason none of the 11 files that `require("nvim-web-devicons")`
-- internally — or list it in their own `dependencies` table — needed to change their own
-- requiring code; every one of those `dependencies` entries was repointed at
-- "echasnovski/mini.nvim" instead (see each file's own note), so the real nvim-web-devicons
-- plugin is no longer installed at all rather than sitting alongside the mock unused.
--
-- mini.ai's builtin `f` textobject ("function call", e.g. `daf` deletes `foo(...)` including
-- the name) is disabled below: plugins/editor/textobjects.lua also maps `af`/`if` via
-- nvim-treesitter-textobjects, meaning "function DEFINITION" instead — both would otherwise
-- fire on the same keys, ambiguously, depending on typing speed relative to 'timeoutlen'.
-- Everything else mini.ai provides by default (brackets, quotes, tag, argument, etc.) is
-- untouched and doesn't collide with anything else.
return {
	"echasnovski/mini.nvim",
	version = "*",
	lazy = false,
	priority = 1000,
	config = function()
		-- Icons first: mock_nvim_web_devicons() must run before any consumer's own
		-- require("nvim-web-devicons") call, and this file's own lazy=false/priority=1000
		-- above is what guarantees "before" actually holds.
		require("mini.icons").setup({})
		require("mini.icons").mock_nvim_web_devicons()

		-- Examples: 'da(' deletes a function call, 'yi?' yanks inside a conditional
		require("mini.ai").setup({
			n_lines = 500,
			custom_textobjects = {
				f = false, -- disabled: collides with nvim-treesitter-textobjects' af/if (see note above)
			},
		})
	end,
}
