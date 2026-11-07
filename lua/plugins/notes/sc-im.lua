-- DAmesberger/sc-im.nvim: opens the markdown table under the cursor in the sc-im terminal spreadsheet, formulas and
-- all, and writes the result back as markdown. Needs sc-im on $PATH, so the plugin stays off without it.
-- Owns <localleader>sc, sp, st, sr, su and sU in markdown buffers, and <localleader>sx in sc-im's terminal, where
-- <C-\><C-n> leaves terminal mode first; no terminal-mode key is mapped, since sc-im reads Space and \ itself. Inside
-- the notes graph the .sc file lands in pages/ or journals/; sp avoids it for a one-off table.
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
		{ "<localleader>sc", scim("open_in_scim"), ft = "markdown", desc = "Open table in sc-im" }, -- n: the table under the cursor with its linked .sc file, kept next to the page so formulas survive; outside a table a new one
		{ "<localleader>sp", scim("open_in_scim", false), ft = "markdown", desc = "Open plain table in sc-im" }, -- n: the table alone, no .sc file (p for plain)
		{ "<localleader>st", scim("toggle"), ft = "markdown", desc = "Toggle sc-im link format" }, -- n: the link to the .sc file as an HTML comment or as markdown
		{ "<localleader>sr", scim("rename"), ft = "markdown", desc = "Rename linked sc-im file" }, -- n: a new name for the linked .sc file
		{ "<localleader>su", scim("update"), ft = "markdown", desc = "Recalculate table" }, -- n: the formulas' results written into the markdown table (u for update)
		{ "<localleader>sU", scim("update", true), ft = "markdown", desc = "Recalculate and save sc-im file" }, -- n: the same, and the .sc file saved too
		{ "<localleader>sx", scim("close"), desc = "Close sc-im without saving" }, -- n: in the sc-im terminal's normal mode, quit it unsaved (x for exit)
	},
	opts = {
		float_config = { border = "rounded" },
	},
}
