-- monaqa/dial.nvim: increment and decrement numbers, dates, booleans and semver.
-- Keys: <C-a>/<C-x> increment/decrement, g<C-a>/g<C-x> step a visual block sequentially. Same keys as Nvim's own,
-- so the normal >/< indent operators stay untouched; dial only widens what those keys understand.
local function dial(direction, mode)
	return function()
		require("dial.map").manipulate(direction, mode)
	end
end

return {
	"monaqa/dial.nvim",
	keys = {
		{ "<C-a>", dial("increment", "normal"), desc = "Increment" },
		{ "<C-x>", dial("decrement", "normal"), desc = "Decrement" },
		{ "g<C-a>", dial("increment", "gnormal"), desc = "Increment sequential" },
		{ "g<C-x>", dial("decrement", "gnormal"), desc = "Decrement sequential" },
		{ "<C-a>", dial("increment", "visual"), mode = "x", desc = "Increment" },
		{ "<C-x>", dial("decrement", "visual"), mode = "x", desc = "Decrement" },
		{ "g<C-a>", dial("increment", "gvisual"), mode = "x", desc = "Increment sequential" },
		{ "g<C-x>", dial("decrement", "gvisual"), mode = "x", desc = "Decrement sequential" },
	},
}
