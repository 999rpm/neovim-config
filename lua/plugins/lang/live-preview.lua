-- brianhuster/live-preview.nvim: browser preview for markdown, HTML, AsciiDoc and SVG, served by Neovim itself (no
-- Node or Python). Markdown, AsciiDoc and SVG update while typing, with KaTeX and Mermaid and a browser that scrolls
-- with the cursor; HTML updates when the file is written (auto-save.lua writes notes pages only, so :w or <C-s> there).
-- :LivePreview pick chooses a file, :LivePreview start {path} previews one, :checkhealth livepreview shows the server
-- root and config. Owns <leader>up and <leader>uP in those buffers; live-preview maps no keys itself.
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
		}, -- n: open the page in the browser; it follows edits and the cursor
		{
			"<leader>uP",
			"<cmd>LivePreview close<cr>",
			ft = { "markdown", "html", "asciidoc", "svg" },
			desc = "Stop browser preview",
		}, -- n: stop the server, uppercase twin of up
	},
}
