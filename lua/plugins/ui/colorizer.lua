-- catgoose/nvim-colorizer.lua: highlights color literals (#rrggbb, css rgb()/hsl(), named
-- colors, Tailwind classes) with their actual color. Standalone replacement for
-- mini.hipatterns' hex-color highlighter — see plugins/editor/mini.lua's note for why.
-- catgoose's fork is the actively-maintained continuation of the original norcalli/NvChad
-- lineage (verified current against its own README before adding this).
return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		options = {
			parsers = {
				names = { enable = false }, -- don't highlight bare CSS color names ("red", "blue", ...) — too noisy outside actual CSS
				tailwind = { enable = true }, -- highlight Tailwind classes (text-red-500, bg-blue-200, ...) in jsx/tsx/html
			},
		},
	},
}
