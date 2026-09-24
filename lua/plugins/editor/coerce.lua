-- gregorias/coerce.nvim: case conversion under gA; ga stays the native character-info command.
-- Keys: gA then a case key converts the word under the cursor; gA in visual mode converts the selection.
-- Case keys: c camelCase, p PascalCase, s snake_case, u UPPER_CASE, k kebab-case, d dot.case, / path/case, n numeronym, <Space> space case.
return {
	"gregorias/coerce.nvim",
	keys = {
		{ "gA", "<Plug>(coerce-normal)", desc = "Change word case" },
		{ "gA", "<Plug>(coerce-visual)", mode = "x", desc = "Change selection case" },
	},
	opts = {},
}
