-- gregorias/coerce.nvim: case conversion under gA; ga stays the native character-info command. Owns gA.
return {
	"gregorias/coerce.nvim",
	-- coerce's own keys, typed after gA: c camelCase, p PascalCase, s snake_case, u UPPER_CASE, k kebab-case,
	-- d dot.case, / path/case, n numeronym, <Space> space case.
	keys = {
		{ "gA", "<Plug>(coerce-normal)", desc = "Change word case" }, -- n: gA then a case key converts the word under the cursor (A for alter)
		{ "gA", "<Plug>(coerce-visual)", mode = "x", desc = "Change selection case" }, -- x: the same for the selected text
	},
	opts = {},
}
