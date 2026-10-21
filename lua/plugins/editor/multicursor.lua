-- jake-stewart/multicursor.nvim: multiple cursors, as in VS Code. Cursors come from the lines above and below, from
-- matches of the word or selection, from a motion, or from Ctrl+Alt+click; every cursor then repeats each normal-mode
-- edit and each insert. While cursors exist, <leader>mh/<leader>ml pick the previous/next one as the main cursor and
-- <Esc> clears them. Alt+click stays the built-in block selection and Ctrl+click the built-in tag jump. Owns <leader>m,
-- <C-Up>/<C-Down> and <C-M-LeftMouse>.
return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	event = "VeryLazy",
	config = function()
		local mc = require("multicursor-nvim")
		local set = vim.keymap.set
		for _, key in ipairs({ "<Left>", "<Right>" }) do
			set("i", key, function()
				return mc.numCursors() > 1 and "<C-g>U" .. key or key
			end, { expr = true, desc = key:sub(2, -2) .. " (one insert across cursors)" }) -- i: upgrades built-in <Left>/<Right>: with several cursors the arrow keeps the insert one step, so each cursor gets the whole text; with one, the built-in
		end
		mc.setup() -- after the arrows: setup maps them for every insert when they are free

		set({ "n", "x" }, "<C-Up>", function()
			mc.lineAddCursor(-1)
		end, { desc = "Add cursor above" }) -- n/x: a cursor on the line above, as VS Code's Ctrl+Alt+Up
		set({ "n", "x" }, "<C-Down>", function()
			mc.lineAddCursor(1)
		end, { desc = "Add cursor below" }) -- n/x: the same on the line below

		set({ "n", "x" }, "<leader>mk", function()
			mc.lineSkipCursor(-1)
		end, { desc = "Skip line up" }) -- n/x: move up a line without leaving a cursor there (k as in up)
		set({ "n", "x" }, "<leader>mj", function()
			mc.lineSkipCursor(1)
		end, { desc = "Skip line down" }) -- n/x: the same downwards (j as in down)

		set({ "n", "x" }, "<leader>mn", function()
			mc.matchAddCursor(1)
		end, { desc = "Add at next match" }) -- n/x: a cursor on the next copy of the word or selection, as VS Code's Ctrl+D
		set({ "n", "x" }, "<leader>mN", function()
			mc.matchAddCursor(-1)
		end, { desc = "Add at previous match" }) -- n/x: the same backwards, uppercase twin
		set({ "n", "x" }, "<leader>ms", function()
			mc.matchSkipCursor(1)
		end, { desc = "Skip next match" }) -- n/x: jump over the next copy without a cursor there
		set({ "n", "x" }, "<leader>mS", function()
			mc.matchSkipCursor(-1)
		end, { desc = "Skip previous match" }) -- n/x: the same backwards
		set({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors, { desc = "Add at every match" }) -- n/x: a cursor on every copy in the buffer, as VS Code's Ctrl+Shift+L

		set({ "n", "x" }, "<leader>mA", mc.alignCursors, { desc = "Align cursor columns" }) -- n/x: pad with spaces until every cursor sits in one column
		set({ "n", "x" }, "<leader>mq", mc.toggleCursor, { desc = "Toggle cursors" }) -- n/x: freeze the cursors so the main one moves alone, or wake them again
		set({ "n", "x" }, "<leader>mx", mc.deleteCursor, { desc = "Delete main cursor" }) -- n/x: drop the cursor under the main one
		set("n", "<leader>mv", mc.restoreCursors, { desc = "Restore cleared cursors" }) -- n: the cursors <Esc> cleared come back, as gv does for a selection
		set({ "n", "x" }, "<leader>mD", mc.duplicateCursors, { desc = "Duplicate cursors" }) -- n/x: a frozen copy of every cursor
		set({ "n", "x" }, "<leader>mi", mc.sequenceIncrement, { desc = "Number sequence up" }) -- n/x: the numbers under the cursors become 1, 2, 3 and so on
		set({ "n", "x" }, "<leader>mI", mc.sequenceDecrement, { desc = "Number sequence down" }) -- n/x: the same counting down

		set("n", "<C-M-LeftMouse>", mc.handleMouse, { desc = "Add or remove cursor (mouse)" }) -- n: Ctrl+Alt+click toggles a cursor at the click
		set("n", "<C-M-LeftDrag>", mc.handleMouseDrag, { desc = "which_key_ignore" }) -- half of <C-M-LeftMouse> above, not a key to press on its own
		set("n", "<C-M-LeftRelease>", mc.handleMouseRelease, { desc = "which_key_ignore" }) -- the other half

		set({ "n", "x" }, "<leader>mm", mc.addCursorOperator, { desc = "Add cursor over a motion" }) -- n/x: then a motion, so <leader>mmip puts a cursor on each line of the paragraph

		mc.addKeymapLayer(function(layer)
			layer({ "n", "x" }, "<leader>mh", mc.prevCursor, { desc = "Previous cursor" }) -- n/x, cursors only: the previous one becomes the main cursor (h as in left)
			layer({ "n", "x" }, "<leader>ml", mc.nextCursor, { desc = "Next cursor" }) -- n/x, cursors only: the next one (l as in right)
			layer("n", "<Esc>", mc.clearCursors, { desc = "Clear cursors" }) -- n, cursors only: clears the cursors, where mappings.lua's <Esc> clears the search highlight; <leader>mv brings them back
		end)

		require("utils.core").on_colorscheme("multicursor-highlights", function()
			local hl = vim.api.nvim_set_hl
			hl(0, "MultiCursorCursor", { reverse = true })
			hl(0, "MultiCursorVisual", { link = "Visual" })
			hl(0, "MultiCursorSign", { link = "SignColumn" })
			hl(0, "MultiCursorMatchPreview", { link = "Search" })
			hl(0, "MultiCursorDisabledCursor", { reverse = true })
			hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
			hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
		end)
	end,
}
