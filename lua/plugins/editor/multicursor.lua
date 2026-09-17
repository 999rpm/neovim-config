-- jake-stewart/multicursor.nvim: multiple cursors under <leader>m, plus <C-Up>/<C-Down> and <C-LeftMouse>.
-- Native <C-LeftMouse> (jump to tag) is still on g<LeftMouse>.
return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	event = "VeryLazy",
	config = function()
		local mc = require("multicursor-nvim")
		mc.setup()
		local set = vim.keymap.set

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

		set("n", "<C-LeftMouse>", mc.handleMouse, { desc = "Add/Remove Cursor (Mouse)" })
		set("n", "<C-LeftDrag>", mc.handleMouseDrag, { desc = "which_key_ignore" }) -- half of <C-LeftMouse> above, not a key to press on its own
		set("n", "<C-LeftRelease>", mc.handleMouseRelease, { desc = "which_key_ignore" })

		set({ "n", "x" }, "<leader>mm", mc.addCursorOperator, { desc = "Add Cursor (motion)" })

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
