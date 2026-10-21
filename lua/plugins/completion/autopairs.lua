-- windwp/nvim-autopairs: closes brackets and quotes, treesitter-aware.
return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	-- nvim-autopairs' own keys: (i) a typed bracket or quote adds its partner; <CR> between a pair opens an indented
	-- line, upgrades built-in <CR>; <BS> in an empty pair deletes both halves, upgrades built-in <BS>; elsewhere both
	-- keys do their built-in job.
	opts = {
		check_ts = true, -- consult the treesitter node before pairing; upstream's ts_config skips Lua and JavaScript strings
	},
}
