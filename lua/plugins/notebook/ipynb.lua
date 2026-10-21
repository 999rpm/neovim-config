-- 999rpm-ipynb: Jupyter notebooks (.ipynb) open as markdown through the jupytext CLI of :JupyterSetup's environment.
-- Markdown cells stay markdown (render-markdown draws them), code cells become ```python fences, and :w converts back
-- with --update, so outputs and metadata already in the file survive; outputs run in this session are exported into it.
-- Opening a notebook starts the kernel named in its metadata and shows its saved outputs (molten.lua). :NotebookNew or
-- <leader>kN creates one; `nvim new.ipynb` does too. Inside code cells the cells' own servers answer through otter.lua
-- (diagnostics, K, gd, grr, grn with a live preview, <C-s> signature help), and :w formats the code cells through
-- conform.lua; markdown-oxide stays out of notebooks (lspconfig.lua), since its rename would rename the .ipynb file.
-- Cell keys come from utils/notebook.lua's attach, in notebooks, quarto documents and any file split into cells by
-- "# %%" lines (jupytext's percent format): ]j/[j, <leader>ka/kb/kd/ks/kj, and <C-CR>/<S-CR> to run cells.
return {
	"999rpm-ipynb", -- a name with no slash: lazy.nvim looks for no repository
	virtual = true, -- and adds no rtp entry; the code is utils/notebook.lua
	lazy = true,
	init = function() -- init, not config: the BufReadCmd must exist before `nvim file.ipynb` reads the file
		local group = require("utils.core").augroup("ipynb") -- utils/notebook.lua itself loads on the first notebook
		vim.api.nvim_create_autocmd("BufReadCmd", {
			group = group,
			pattern = "*.ipynb",
			desc = "999rpm: open a notebook as markdown through jupytext",
			callback = function(ev)
				require("utils.notebook").read(ev)
			end,
		})
		vim.api.nvim_create_autocmd("BufWriteCmd", {
			group = group,
			pattern = "*.ipynb",
			desc = "999rpm: write a notebook back through jupytext, outputs kept",
			callback = function(ev)
				require("utils.notebook").write(ev)
			end,
		})
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = { "markdown", "quarto", "python" },
			desc = "999rpm: cell motions, and run keys in notebooks",
			callback = function(ev)
				require("utils.notebook").attach(ev.buf)
			end,
		})
		vim.api.nvim_create_user_command("NotebookNew", function(o)
			require("utils.notebook").new(o.args)
		end, { nargs = "?", complete = "file", desc = "Create and open a Python notebook" })
	end,
}
