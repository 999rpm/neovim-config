-- johmsalas/text-case.nvim: case conversion under gA (ga stays the native character-info command).
-- Keys: gA + letter converts the word under the cursor, gAo + letter takes a motion, gA. picks a case from a list.
local function pick_case()
	local visual = vim.fn.mode():find("[vV\22]") ~= nil
	if visual then
		vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false) -- sets '< and '> for plugin.visual()
	end
	local api = require("textcase").api
	local plugin = require("textcase.plugin.plugin")
	local methods = {
		api.to_upper_case,
		api.to_lower_case,
		api.to_snake_case,
		api.to_dash_case,
		api.to_title_dash_case,
		api.to_constant_case,
		api.to_dot_case,
		api.to_comma_case,
		api.to_phrase_case,
		api.to_camel_case,
		api.to_pascal_case,
		api.to_title_case,
		api.to_path_case,
	}
	vim.ui.select(methods, {
		prompt = "Convert case",
		format_item = function(method)
			return method.desc
		end,
	}, function(method)
		if not method then
			return
		end
		if visual then
			plugin.visual(method.method_name)
		else
			plugin.current_word(method.method_name)
		end
	end)
end

return {
	"johmsalas/text-case.nvim",
	lazy = false, -- which-key labels for the gA prefix need the plugin loaded
	keys = {
		{ "gA.", pick_case, mode = { "n", "x" }, desc = "Pick case" },
	},
	config = function()
		require("textcase").setup({ prefix = "gA" })
	end,
}
