-- catgoose/nvim-colorizer.lua: paints colour codes and Tailwind classes in their own colour.
return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		options = {
			parsers = {
				names = { enable = false }, -- don't highlight bare CSS color names ("red", "blue", ...); too noisy outside actual CSS
				tailwind = { enable = true }, -- highlight Tailwind classes (text-red-500, bg-blue-200, ...) in jsx/tsx/html
			},
		},
	},
}
