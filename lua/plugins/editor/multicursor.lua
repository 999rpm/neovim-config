-- jake-stewart/multicursor.nvim: real multiple cursors (as opposed to Visual-block `I`/`A`,
-- which only ever inserts, or `:s`/macros, which don't show you what's about to happen). Ships
-- zero keymaps by design — its own README: "Requires users to define all keymaps in their
-- Neovim config" — so every binding below is a deliberate choice against this config's full
-- existing keymap surface, not upstream defaults.
--
-- Upstream's own example config uses bare `<up>`/`<down>`/`<c-q>`/`<leader>n`/`<leader>s`/
-- `<leader>a`/`<leader>t`/`[d`/`]d` for various actions — every one of those is already taken in
-- this config (window resize, Quit, the No-yank/Search group prefixes, the parameter-swap
-- keys, the Toggle/Test group prefixes, native diagnostic-jump). None of upstream's suggested
-- keys survive unchanged below; see each binding's own comment for where it actually landed.
--
-- Two different key classes here:
--   1. Top-level (always active) — need genuinely free keys, all live under a new `<leader>m`
--      "Multicursor" group (which-key.lua) except the mouse handlers (unused elsewhere).
--   2. Layered (`mc.addKeymapLayer` below) — only exist while 2+ cursors are already active, so
--      reusing an otherwise-busy key here is genuinely safe, not a conflict: outside multicursor
--      mode the existing binding is completely untouched. `<left>`/`<right>`/`<esc>` below are
--      upstream's own suggested layer bindings, kept as-is (window-resize arrows and nohlsearch
--      Esc are exactly what they were outside multicursor mode; inside it, arrows aren't a loss
--      since h/j/k/l/motions still move each cursor normally).
return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	event = "VeryLazy",
	config = function()
		local mc = require("multicursor-nvim")
		mc.setup()
		local set = vim.keymap.set

		-- Add cursor above/below (line). <C-Up>/<C-Down>, not bare arrows — those are already
		-- window-resize (mappings.lua) at the top level, unconditionally, so they can't be
		-- reused here the way <left>/<right> can be below (this needs to work with 0 or 1
		-- cursors already active, i.e. it can't be layer-scoped).
		set({ "n", "x" }, "<C-Up>", function()
			mc.lineAddCursor(-1)
		end, { desc = "Add Cursor Above" })
		set({ "n", "x" }, "<C-Down>", function()
			mc.lineAddCursor(1)
		end, { desc = "Add Cursor Below" })

		set({ "n", "x" }, "<leader>mk", function()
			mc.lineSkipCursor(-1)
		end, { desc = "Skip Line Up" })
		set({ "n", "x" }, "<leader>mj", function()
			mc.lineSkipCursor(1)
		end, { desc = "Skip Line Down" })

		-- Add/skip a cursor by matching the word/selection under the cursor.
		set({ "n", "x" }, "<leader>mn", function()
			mc.matchAddCursor(1)
		end, { desc = "Match Add Next" })
		set({ "n", "x" }, "<leader>mN", function()
			mc.matchAddCursor(-1)
		end, { desc = "Match Add Prev" })
		set({ "n", "x" }, "<leader>ms", function()
			mc.matchSkipCursor(1)
		end, { desc = "Match Skip Next" })
		set({ "n", "x" }, "<leader>mS", function()
			mc.matchSkipCursor(-1)
		end, { desc = "Match Skip Prev" })
		set({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors, { desc = "Match Add All" })

		set({ "n", "x" }, "<leader>mA", mc.alignCursors, { desc = "Align Cursor Columns" })
		set({ "n", "x" }, "<leader>mq", mc.toggleCursor, { desc = "Toggle Cursors On/Off" })
		set({ "n", "x" }, "<leader>mx", mc.deleteCursor, { desc = "Delete Main Cursor" })
		set("n", "<leader>mv", mc.restoreCursors, { desc = "Restore Cleared Cursors" })
		set({ "n", "x" }, "<leader>mD", mc.duplicateCursors, { desc = "Duplicate Cursors" })
		set({ "n", "x" }, "<leader>mi", mc.sequenceIncrement, { desc = "Sequence Increment" })
		set({ "n", "x" }, "<leader>mI", mc.sequenceDecrement, { desc = "Sequence Decrement" })

		-- Add and remove cursors with the mouse (Ctrl + left click) — unused elsewhere.
		set("n", "<C-LeftMouse>", mc.handleMouse, { desc = "Add/Remove Cursor (Mouse)" })
		set("n", "<C-LeftDrag>", mc.handleMouseDrag)
		set("n", "<C-LeftRelease>", mc.handleMouseRelease)

		-- Operator-pending: `gmip` adds a cursor on every line of a paragraph, `gm` + any
		-- motion/textobject generally. Native `gm` (go to screen-middle column-wise) is rarely
		-- used and is overridden here on purpose — the same trade already made for `gc`/`ga` in
		-- comment.lua/text-case.lua once real value replaces it.
		set({ "n", "x" }, "gm", mc.addCursorOperator, { desc = "Add Cursor (motion)" })

		-- Only active once 2+ cursors already exist — see header note on why this is safe.
		mc.addKeymapLayer(function(layerSet)
			layerSet({ "n", "x" }, "<left>", mc.prevCursor)
			layerSet({ "n", "x" }, "<right>", mc.nextCursor)
			layerSet("n", "<esc>", function()
				if not mc.cursorsEnabled() then
					mc.enableCursors()
				else
					mc.clearCursors()
				end
			end)
		end)

		-- Cursor appearance — matches this config's real installed groups (utils.rainbow_
		-- delimiter_groups isn't relevant here; these are nvim-dap.lua-style plain `link`s so
		-- they follow the active theme instead of a hardcoded hex).
		local hl = vim.api.nvim_set_hl
		hl(0, "MultiCursorCursor", { reverse = true })
		hl(0, "MultiCursorVisual", { link = "Visual" })
		hl(0, "MultiCursorSign", { link = "SignColumn" })
		hl(0, "MultiCursorMatchPreview", { link = "Search" })
		hl(0, "MultiCursorDisabledCursor", { reverse = true })
		hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
		hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
	end,
}
