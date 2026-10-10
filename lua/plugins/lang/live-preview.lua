-- brianhuster/live-preview.nvim: browser preview for markdown, HTML, AsciiDoc and SVG, served by Neovim itself (no Node or
-- Python). Markdown, AsciiDoc and SVG update as you type, with KaTeX and Mermaid and a browser that scrolls with the
-- cursor; HTML updates when the file is written (auto-save.lua writes notes pages only, so :w or <C-s> there).
-- Keys in those buffers: <leader>up start the preview, <leader>uP stop the server. :LivePreview pick chooses a file,
-- :LivePreview start {path} previews one, :checkhealth livepreview shows the server root and config.
-- The server root is the working directory, so a page's relative links (../assets/...) resolve from there; start Neovim
-- in the project or graph folder, or set dynamic_root = true to serve each file's own folder.
return {
	"brianhuster/live-preview.nvim",
	cmd = "LivePreview",
	keys = {
		{
			"<leader>up",
			"<cmd>LivePreview start<cr>",
			ft = { "markdown", "html", "asciidoc", "svg" },
			desc = "Start browser preview",
		},
		{
			"<leader>uP",
			"<cmd>LivePreview close<cr>",
			ft = { "markdown", "html", "asciidoc", "svg" },
			desc = "Stop browser preview",
		},
	},
	opts = {
		port = 5500,
		sync_scroll = true, -- the browser follows the cursor in markdown
	},
	config = function(_, opts)
		require("livepreview.config").set(opts) -- the plugin has no setup(); this is its documented entry point
	end,
}
