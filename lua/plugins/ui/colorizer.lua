-- catgoose/nvim-colorizer.lua: paints colour codes and Tailwind classes in their own colour. It switches off 0.12's own
-- LSP colour highlighting in the buffers it paints, so each colour is drawn once. Needs 'termguicolors' (options.lua).
return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		options = {
			parsers = {
				names = { enable = false }, -- bare colour names ("red", "blue") stay plain: they fill prose and identifiers
				tailwind = { -- Tailwind classes (text-red-500, bg-blue-200, ...) in jsx/tsx/html
					enable = true,
					lsp = { enable = true }, -- tailwindcss-language-server's colours win where it runs, so the project's theme applies
					update_names = true, -- the server's colours also refresh the name lookup
				},
			},
		},
	},
}
