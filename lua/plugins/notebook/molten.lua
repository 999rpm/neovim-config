-- benlubas/molten-nvim: Jupyter kernels inside Neovim. Code runs in a real kernel (Python, R, Julia, anything with a
-- kernelspec) and its output, plots included, appears as virtual lines under the cell; snacks.image draws the images
-- through kitty; Neovide draws none, so there <leader>kp opens them in the system's image viewer. A DataFrame in the
-- output is an outlined table: kernels started here run ipython/outlined_tables.py through PYTHONSTARTUP
-- (utils/jupyter.lua). The picker lists every installed kernelspec: a uv project joins it through
-- <leader>kv, a micromamba or venv environment after `python -m ipykernel install --user --name <env>` inside it.
-- Notebooks open through ipynb.lua; in cell buffers utils/notebook.lua adds <leader>ka/kb/kd/ks/kj (add above/below,
-- delete, split, join). A kernel starts in its notebook's folder, as in JupyterLab, so the modules beside the notebook
-- import without os.chdir. Each notebook runs its own kernel: a second notebook on the same kernelspec gets molten's id
-- <name>_1, and the statusline names the buffer's kernels. :JupyterSetup builds the Python side, with uv when it is on
-- $PATH, else venv and pip. Owns <leader>k; molten maps no keys itself, and its output window closes with :q.
local function call(module, name, ...)
	local args = { ... }
	return function()
		require("utils." .. module)[name](unpack(args))
	end
end

return {
	"benlubas/molten-nvim", -- main, not a tag: v1.9.2 (Jan 2025) predates the snacks.nvim image provider
	event = "VeryLazy", -- the remote-plugin manifest defines the commands at startup; the Lua half must be on 'rtp' by the first run
	build = call("jupyter", "setup"), -- creates the Python environment once, then registers the remote plugin
	init = function()
		local g = vim.g
		g.molten_image_provider = vim.g.neovide and "none" or "snacks.nvim" -- snacks.lua's image module; no image.nvim needed
		g.molten_auto_open_output = false -- output stays as virtual lines under the cell; <leader>ke opens the window
		g.molten_virt_text_output = true -- under the cell's last code line: the markdown query hides the closing fence line, and its virtual lines with it
		g.molten_wrap_output = true
		g.molten_output_win_max_height = 20
		g.molten_output_win_border = "rounded" -- same border as 'winborder'
		vim.api.nvim_create_user_command(
			"JupyterSetup",
			call("jupyter", "setup"),
			{ desc = "Create or update the Jupyter environment" }
		)
		vim.api.nvim_create_user_command("JupyterKernelAdd", function(o)
			require("utils.jupyter").kernel_add(o.args)
		end, { nargs = "?", desc = "Register the uv project as a Jupyter kernel" })
	end,
	keys = {
		{ "<leader>ki", call("notebook", "kernel"), desc = "Start kernel" }, -- n: the notebook's own kernel, else a picker
		{
			"<leader>kr",
			function()
				require("utils.jupyter").kernel_cwd() -- the restarted process starts in the notebook's folder again
				vim.cmd("MoltenRestart!")
			end,
			desc = "Restart kernel, clear outputs",
		}, -- n: a fresh kernel; every output goes
		{ "<leader>kx", "<Cmd>MoltenInterrupt<CR>", desc = "Interrupt kernel" }, -- n: stop the running cell, like JupyterLab's i i
		{ "<leader>kq", "<Cmd>MoltenDeinit<CR>", desc = "Shut down kernel" }, -- n: end the kernel process (q for quit)
		{ "<leader>kK", "<Cmd>MoltenInfo<CR>", desc = "Kernel info" }, -- n: which kernels run and for which buffers
		{ "<leader>kc", call("notebook", "run", "cell"), desc = "Run cell" }, -- n: the code cell under the cursor
		{ "<leader>kc", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = "x", silent = true, desc = "Run selection" }, -- x: only the selected lines; ":" so '< and '> are set first
		{ "<leader>kn", call("notebook", "run", "next"), desc = "Run cell, go to next" }, -- n: JupyterLab's Shift+Enter
		{ "<leader>ku", call("notebook", "run", "above"), desc = "Run cells up to here" }, -- n: every cell above, then this one (u for up)
		{ "<leader>kA", call("notebook", "run", "all"), desc = "Run all cells" }, -- n: the whole notebook, top to bottom
		{ "<leader>kl", "<Cmd>MoltenEvaluateLine<CR>", desc = "Run line" }, -- n: the cursor line only
		{ "<leader>ko", "<Cmd>MoltenEvaluateOperator<CR>", desc = "Run motion (then a motion)" }, -- n: an operator: ko then ij runs the cell's code, kop a paragraph
		{ "<leader>ke", "<Cmd>noautocmd MoltenEnterOutput<CR>", desc = "Enter output window" }, -- n: into the output float, to scroll or copy; :q leaves it
		{ "<leader>kh", "<Cmd>MoltenHideOutput<CR>", desc = "Hide output window" }, -- n: close the output float
		{ "<leader>kD", "<Cmd>MoltenDelete<CR>", desc = "Delete cell output" }, -- n: remove this cell's output (D for delete)
		{ "<leader>kp", "<Cmd>MoltenImagePopup<CR>", desc = "Open output image" }, -- n: the plot in a larger float (p for picture)
		{ "<leader>kw", "<Cmd>MoltenOpenInBrowser<CR>", desc = "Open HTML output in browser" }, -- n: HTML output, which molten cannot draw (w for web)
		{ "<leader>kE", "<Cmd>MoltenExportOutput!<CR>", desc = "Export outputs to the .ipynb" }, -- n: write this session's outputs into the notebook file
		{ "<leader>kI", "<Cmd>MoltenImportOutput<CR>", desc = "Import outputs from the .ipynb" }, -- n: show the outputs saved in the notebook
		{ "<leader>kN", call("notebook", "new"), desc = "New notebook" }, -- n: create and open an .ipynb (N for new)
		{ "<leader>kv", call("jupyter", "kernel_add"), desc = "Register uv project as kernel" }, -- n: uv add --dev ipykernel, then the kernelspec (v for venv)
	},
	config = function()
		require("utils.jupyter").python_startup() -- before the first kernel starts, so it inherits the variable
		local group = require("utils.core").augroup("molten-kernel")
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "MoltenInitPre",
			desc = "999rpm: start the kernel in the folder of the buffer it is for",
			callback = function()
				require("utils.jupyter").kernel_cwd()
			end,
		})
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "MoltenInitPost",
			desc = "999rpm: remember the buffer's kernel for the statusline and notebook writes",
			callback = function(ev)
				local ok, names = pcall(vim.fn.MoltenRunningKernels, true)
				vim.b[ev.buf]._999rpm_kernel = ok and table.concat(names, ", ") or "kernel"
			end,
		})
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "MoltenDeinitPost",
			desc = "999rpm: refresh each buffer's kernel names once a kernel ends",
			callback = function()
				vim.schedule(function() -- molten drops the kernel after this event, which names the current buffer only
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.b[buf]._999rpm_kernel then
							local ok, names = false, {}
							if vim.api.nvim_buf_is_loaded(buf) then
								ok, names = pcall(vim.api.nvim_buf_call, buf, function()
									return vim.fn.MoltenRunningKernels(true)
								end)
							end
							if ok and #names > 0 then
								vim.b[buf]._999rpm_kernel = table.concat(names, ", ")
							else
								vim.b[buf]._999rpm_kernel = nil
								vim.b[buf]._999rpm_ready = nil
							end
						end
					end
				end)
			end,
		})
	end,
}
