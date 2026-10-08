-- DAmesberger/sc-im.nvim: opens the markdown table under the cursor in the sc-im terminal spreadsheet, formulas and
-- all, and writes the result back as markdown. Needs sc-im on $PATH, so the plugin stays off without it.
-- Keys (markdown buffers): <localleader>sc open the table with its linked .sc file (kept next to the page, so formulas
-- survive), sp open it as a plain table, st toggle the link between comment and markdown form, sr rename the .sc file,
-- su recalculate the markdown table, sU recalculate and save the .sc file. Outside a table, sc starts a new one.
-- In the sc-im terminal: <C-\><C-n> leaves terminal mode, then <localleader>sx closes sc-im without saving. No terminal-mode
-- key is mapped, since sc-im reads Space and \ itself.
-- Inside the notes graph the .sc file lands in pages/ or journals/; sp avoids it for a one-off table.
local function scim(name, ...)
	local args = { ... }
	return function()
		require("sc-im")[name](unpack(args))
	end
end

return {
	"DAmesberger/sc-im.nvim",
	main = "sc-im",
	cond = function()
		return require("utils.core").executable("sc-im")
	end,
	keys = {
		{ "<localleader>sc", scim("open_in_scim"), ft = "markdown", desc = "Open table in sc-im" },
		{ "<localleader>sp", scim("open_in_scim", false), ft = "markdown", desc = "Open plain table in sc-im" },
		{ "<localleader>st", scim("toggle"), ft = "markdown", desc = "Toggle sc-im link format" },
		{ "<localleader>sr", scim("rename"), ft = "markdown", desc = "Rename linked sc-im file" },
		{ "<localleader>su", scim("update"), ft = "markdown", desc = "Recalculate table" },
		{ "<localleader>sU", scim("update", true), ft = "markdown", desc = "Recalculate and save sc-im file" },
		{ "<localleader>sx", scim("close"), desc = "Close sc-im without saving" }, -- pressed in the terminal's normal mode, outside markdown
	},
	opts = {
		include_sc_file = true, -- link a .sc file so formatting and formulas survive reopening
		update_sc_from_md = true, -- markdown edits flow into sc-im; formulas stay untouched
		link_fmt = 1, -- link as an HTML comment, invisible when rendered
		split = "floating",
		float_config = { height = 0.9, width = 0.9, style = "minimal", border = "rounded", hl = "Normal", blend = 0 },
	},
}
