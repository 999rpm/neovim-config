-- nvim-tree/nvim-web-devicons: filetype icons, used by bufferline/neo-tree/fzf-lua/telescope/
-- oil/alpha/render-markdown/trouble/etc. `lazy = true` with no `event`/`cmd`/`ft` trigger of its
-- own is deliberate: this file's only job is to be the ONE place that configures it (`opts`
-- below); every consumer still lists `"nvim-tree/nvim-web-devicons"` in its own `dependencies`
-- table — that's what actually triggers the lazy-load (lazy.nvim merges every spec referencing
-- the same plugin name into one resolved plugin, so all consumers get this file's `opts`
-- regardless of which one happens to load it first). Removing those per-consumer references
-- would NOT be "deduplicating" them — it would stop the plugin from ever loading at all. See
-- plugins/deps/shared.lua for the same pattern applied to plugins with nothing to configure.
return {
	"nvim-tree/nvim-web-devicons",
	lazy = true,
	opts = {
		default = true,
		strict = true,
	},
}
