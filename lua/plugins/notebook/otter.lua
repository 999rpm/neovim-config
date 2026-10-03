-- jmbuhr/otter.nvim: language servers inside the code cells of a markdown notebook. Each cell language gets a hidden
-- buffer that basedpyright, ruff and the rest attach to, and otter's in-process server forwards completion, K, gd, grr,
-- grn and diagnostics between the two. ipynb.lua activates it in notebook and quarto buffers.
return {
	"jmbuhr/otter.nvim",
	lazy = true, -- loaded by the first require from utils/notebook.lua's attach
	opts = {
		lsp = { diagnostic_update_events = { "BufWritePost", "InsertLeave" } }, -- cell diagnostics refresh on leaving insert mode too
		buffers = { set_filetype = true }, -- the hidden buffers get a real filetype, so vim.lsp.enable() attaches the usual servers
		handle_leading_whitespace = true,
	},
}
