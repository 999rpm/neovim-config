-- jake-stewart/multicursor.nvim: multiple cursors.
-- Keys: <C-Up>/<C-Down> add above/below, <M-LeftMouse> add or remove; <leader>m n/N add at next/previous match,
-- s/S skip a match, a add at every match, j/k skip a line, A align, q toggle, x delete, v restore, D duplicate,
-- i/I number sequence up/down, m add over a motion. With cursors active: <Left>/<Right> cycle, <Esc> clear.
-- <C-LeftMouse> stays the built-in jump to tag.
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
		end, { desc = "Add cursor above" })
		set({ "n", "x" }, "<C-Down>", function()
			mc.lineAddCursor(1)
		end, { desc = "Add cursor below" })

		set({ "n", "x" }, "<leader>mk", function()
			mc.lineSkipCursor(-1)
		end, { desc = "Skip line up" })
		set({ "n", "x" }, "<leader>mj", function()
			mc.lineSkipCursor(1)
		end, { desc = "Skip line down" })

		set({ "n", "x" }, "<leader>mn", function()
			mc.matchAddCursor(1)
		end, { desc = "Add at next match" })
		set({ "n", "x" }, "<leader>mN", function()
			mc.matchAddCursor(-1)
		end, { desc = "Add at previous match" })
		set({ "n", "x" }, "<leader>ms", function()
			mc.matchSkipCursor(1)
		end, { desc = "Skip next match" })
		set({ "n", "x" }, "<leader>mS", function()
			mc.matchSkipCursor(-1)
		end, { desc = "Skip previous match" })
		set({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors, { desc = "Add at every match" })

		set({ "n", "x" }, "<leader>mA", mc.alignCursors, { desc = "Align cursor columns" })
		set({ "n", "x" }, "<leader>mq", mc.toggleCursor, { desc = "Toggle cursors" })
		set({ "n", "x" }, "<leader>mx", mc.deleteCursor, { desc = "Delete main cursor" })
		set("n", "<leader>mv", mc.restoreCursors, { desc = "Restore cleared cursors" })
		set({ "n", "x" }, "<leader>mD", mc.duplicateCursors, { desc = "Duplicate cursors" })
		set({ "n", "x" }, "<leader>mi", mc.sequenceIncrement, { desc = "Number sequence up" })
		set({ "n", "x" }, "<leader>mI", mc.sequenceDecrement, { desc = "Number sequence down" })

		set("n", "<M-LeftMouse>", mc.handleMouse, { desc = "Add or remove cursor (mouse)" })
		set("n", "<M-LeftDrag>", mc.handleMouseDrag, { desc = "which_key_ignore" }) -- half of <M-LeftMouse> above, not a key to press on its own
		set("n", "<M-LeftRelease>", mc.handleMouseRelease, { desc = "which_key_ignore" })

		set({ "n", "x" }, "<leader>mm", mc.addCursorOperator, { desc = "Add cursor over a motion" })

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

		require("utils").on_colorscheme("multicursor-highlights", function()
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
