-- andymass/vim-matchup: % through treesitter, so it also pairs words (function/end, if/elseif/else/end, HTML tags) and
-- highlights the partner. Replaces the bundled matchit and matchparen, which lazy.lua disables.
-- Keys: % next partner, g% previous partner, [% / ]% enclosing open / close, z% into the next pair; a% / i% select a pair
-- with or without its delimiters, and every key above works after an operator (d%, c]%, yi%).
-- Loads at startup, as upstream asks: its start-up work is small, and it replaces two plugins that loaded there anyway.
return {
	"andymass/vim-matchup",
	lazy = false,
	init = function()
		vim.g.matchup_matchparen_offscreen = {} -- treesitter-context already shows an opening line scrolled off the top
		vim.g.matchup_matchparen_deferred = 1 -- highlight once the cursor settles, so j/k stay fast
		vim.g.matchup_treesitter_stopline = 500 -- stop looking for a partner 500 lines away
	end,
}
