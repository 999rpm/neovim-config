-- catgoose/nvim-colorizer.lua: paints colour codes and Tailwind classes in their own colour. It switches off 0.12's own
-- LSP colour highlighting in the buffers it paints, so each colour is drawn once. Needs 'termguicolors' (options.lua).
return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		options = {
			parsers = {
				names = { enable = false }, -- don't highlight bare CSS color names ("red", "blue", ...); too noisy outside actual CSS
				tailwind = { -- Tailwind classes (text-red-500, bg-blue-200, ...) in jsx/tsx/html
					enable = true,
					lsp = { enable = true }, -- tailwindcss-language-server's colours win where it runs, so the project's theme applies
					update_names = true, -- and feed back into the fast name lookup
				},
			},
		},
	},
}
