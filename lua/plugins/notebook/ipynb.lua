-- 999rpm-ipynb: Jupyter notebooks (.ipynb) open as markdown through the jupytext CLI of :JupyterSetup's environment.
-- Markdown cells stay markdown (render-markdown draws them), code cells become ```python fences, and :w converts back
-- with --update, so outputs and metadata already in the file survive; outputs run in this session are exported into it.
-- Opening a notebook starts the kernel named in its metadata and shows its saved outputs (molten.lua). :NotebookNew or
-- <leader>kN creates one; `nvim new.ipynb` does too.
-- Cells: ]j/[j next/previous cell, ij/aj select a cell's code without/with its fence (mini.lua), <leader>ka/<leader>kb add
-- an empty cell above/below in the language of the cell under the cursor and start insert mode in it (JupyterLab's a and
-- b), <leader>kd delete the cell into the registers like dd, so p pastes it elsewhere (JupyterLab's x), <leader>ks split
-- the cell at the cursor line, <leader>kj join it with the next cell (JupyterLab's Shift+M). This works in notebooks,
-- quarto documents and any file split into cells by "# %%" lines (jupytext's percent format, e.g. a plain .py script).
-- Notebook buffers: <S-CR> run the cell and go to the next (JupyterLab's Shift+Enter), <C-CR> run it in place.
-- Built-in keys that work inside code cells (otter.lua): K hover, gd definition, grr references, grn rename, gra code
-- action, <C-s> signature help in insert mode; gO lists the headings, zc/zo close/open a fold.
return {
	"999rpm-ipynb", -- a name with no slash: lazy.nvim looks for no repository
	virtual = true, -- and adds no rtp entry; the code is utils.lua's notebook_* helpers
	lazy = true,
	init = function() -- init, not config: the BufReadCmd must exist before `nvim file.ipynb` reads the file
		local utils = require("utils")
		local group = utils.augroup("ipynb")
		vim.api.nvim_create_autocmd("BufReadCmd", {
			group = group,
			pattern = "*.ipynb",
			desc = "999rpm: open a notebook as markdown through jupytext",
			callback = utils.notebook_read,
		})
		vim.api.nvim_create_autocmd("BufWriteCmd", {
			group = group,
			pattern = "*.ipynb",
			desc = "999rpm: write a notebook back through jupytext, outputs kept",
			callback = utils.notebook_write,
		})
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = { "markdown", "quarto", "python" },
			desc = "999rpm: cell motions, and run keys in notebooks",
			callback = function(ev)
				utils.notebook_attach(ev.buf)
			end,
		})
		vim.api.nvim_create_user_command("NotebookNew", function(o)
			utils.notebook_new(o.args)
		end, { nargs = "?", complete = "file", desc = "Create and open a Python notebook" })
	end,
}
