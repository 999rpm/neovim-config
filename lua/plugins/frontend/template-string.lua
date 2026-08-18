-- axelvc/template-string.nvim: typing `${` inside a plain JS/TS string auto-converts its
-- surrounding quotes to backticks (and back, if every `${}` is later removed) — fully
-- automatic, no keymap. Minimal config here (defaults only): kept deliberately small since this
-- plugin's exact option surface wasn't individually re-verified beyond confirming it's real and
-- current (in ecosse3/nvim's own plugin list) — its own defaults are sane for the common case.
return {
	"axelvc/template-string.nvim",
	ft = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	opts = {},
}
