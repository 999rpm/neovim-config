-- monaqa/dial.nvim: smarter increment/decrement — booleans (true/false), dates, weekdays,
-- markdown headers, and more, not just numbers. Ships zero keymaps of its own by design (its
-- README: "This plugin does not provide or override any default key-mappings"), so there is no
-- upstream default to conflict with.
--
-- Wired onto this config's EXISTING `>`/`<` increment/decrement (mappings.lua) rather than
-- given new keys — an upgrade in place, not an addition: same keys, smarter engine underneath.
-- mappings.lua's own `>`/`<` lines (which called the plain native `<C-a>`/`<C-x>` via noremap)
-- are superseded by this file's LspAttach-independent, always-on keymaps below; kept out of
-- mappings.lua entirely now rather than left as dead code that would win/lose by load order.
--
-- Visual-mode `<C-a>`/`<C-x>` were free before this file (mappings.lua only ever remapped
-- `<C-a>` in Normal mode, for "select all" — see that file's own note); dial takes those in
-- Visual mode only, so nothing existing loses a binding. `g<C-a>`/`g<C-x>` (both modes) were
-- always free — dial's own "sequence" variant, see its `:h dial-usage` for the dot-repeat
-- difference from the plain form.
return {
	"monaqa/dial.nvim",
	-- No lazy-load trigger on purpose: `>`/`<` need to work correctly on the very first press,
	-- and this config's own `lazy = false` global default (config/lazy.lua) already covers
	-- "just load it" — same choice already made for noice.lua/notify.lua/snacks.lua.
	config = function()
		local map = require("dial.map")

		vim.keymap.set("n", ">", function()
			map.manipulate("increment", "normal")
		end, { desc = "Increment (dial)" })
		vim.keymap.set("n", "<", function()
			map.manipulate("decrement", "normal")
		end, { desc = "Decrement (dial)" })
		vim.keymap.set("n", "g<C-a>", function()
			map.manipulate("increment", "gnormal")
		end, { desc = "Increment sequential (dial)" })
		vim.keymap.set("n", "g<C-x>", function()
			map.manipulate("decrement", "gnormal")
		end, { desc = "Decrement sequential (dial)" })

		vim.keymap.set("x", "<C-a>", function()
			map.manipulate("increment", "visual")
		end, { desc = "Increment (dial)" })
		vim.keymap.set("x", "<C-x>", function()
			map.manipulate("decrement", "visual")
		end, { desc = "Decrement (dial)" })
		vim.keymap.set("x", "g<C-a>", function()
			map.manipulate("increment", "gvisual")
		end, { desc = "Increment sequential (dial)" })
		vim.keymap.set("x", "g<C-x>", function()
			map.manipulate("decrement", "gvisual")
		end, { desc = "Decrement sequential (dial)" })

		-- No custom augends/groups configured here on purpose — dial's own built-in "default"
		-- group (decimal/hex/octal/binary numbers, common date formats, true<->false) is active
		-- with zero further setup once the keymaps above exist, and covers everything this
		-- config's native nrformats-based increment already did, plus more. Custom augends
		-- (e.g. per-filetype groups) are real dial.nvim features (`:h dial-config`) but weren't
		-- added speculatively here without a concrete need for one.
	end,
}
