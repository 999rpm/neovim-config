-- benlubas/molten-nvim: Jupyter kernels inside Neovim. Code runs in a real kernel (Python, R, Julia, anything with a
-- kernelspec) and its output, plots included, appears as virtual lines under the cell; snacks.image draws the images
-- through kitty. The picker lists every installed kernelspec: a uv project joins it through <leader>kv, a micromamba or
-- venv environment after `python -m ipykernel install --user --name <env>` inside it. Notebooks open through ipynb.lua.
-- Keys (<leader>k): i start a kernel (the notebook's own, else a picker), r restart, x interrupt, q shut down, K info;
-- c run the cell (on a selection: run the selection), n run it and go to the next, a run every cell up to here, A run
-- all, l run the line, o run a motion (ko then ij runs the cell's code); e enter the output window (:q leaves it),
-- h hide it, d delete the cell's output, p open its image, b open HTML output in the browser, E/I export/import outputs
-- to/from the .ipynb, N new notebook, v register the uv project as a kernel (:JupyterKernelAdd [name]). The statusline
-- names the buffer's kernel. :JupyterSetup builds the Python side, with uv when it is on $PATH, else venv and pip.
local function util(name, ...)
	local args = { ... }
	return function()
		require("utils")[name](unpack(args))
	end
end

return {
	"benlubas/molten-nvim", -- main, not a tag: v1.9.2 (Jan 2025) predates the snacks.nvim image provider
	event = "VeryLazy", -- the remote-plugin manifest defines the commands at startup; the Lua half must be on 'rtp' by the first run
	build = util("jupyter_setup"), -- creates the Python environment once, then registers the remote plugin
	init = function()
		local g = vim.g
		g.molten_image_provider = "snacks.nvim" -- snacks.lua's image module; no image.nvim or ImageMagick binding needed
		g.molten_auto_open_output = false -- output stays as virtual lines under the cell; <leader>ke opens the window
		g.molten_virt_text_output = true
		g.molten_virt_lines_off_by_1 = true -- output starts below the closing ``` fence instead of covering it
		g.molten_wrap_output = true
		g.molten_output_win_max_height = 20
		g.molten_output_win_border = "rounded" -- same border as 'winborder'
		vim.api.nvim_create_user_command("JupyterSetup", util("jupyter_setup"), { desc = "Create or update the Jupyter environment" })
		vim.api.nvim_create_user_command("JupyterKernelAdd", function(o)
			require("utils").jupyter_kernel_add(o.args)
		end, { nargs = "?", desc = "Register the uv project as a Jupyter kernel" })
	end,
	keys = {
		{ "<leader>ki", util("notebook_kernel"), desc = "Start kernel" },
		{ "<leader>kr", "<Cmd>MoltenRestart!<CR>", desc = "Restart kernel, clear outputs" },
		{ "<leader>kx", "<Cmd>MoltenInterrupt<CR>", desc = "Interrupt kernel" },
		{ "<leader>kq", "<Cmd>MoltenDeinit<CR>", desc = "Shut down kernel" },
		{ "<leader>kK", "<Cmd>MoltenInfo<CR>", desc = "Kernel info" },
		{ "<leader>kc", util("notebook_run", "cell"), desc = "Run cell" },
		{ "<leader>kc", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = "x", silent = true, desc = "Run selection" }, -- ":" so '< and '> are set first
		{ "<leader>kn", util("notebook_run", "next"), desc = "Run cell, go to next" },
		{ "<leader>ka", util("notebook_run", "above"), desc = "Run cells up to here" },
		{ "<leader>kA", util("notebook_run", "all"), desc = "Run all cells" },
		{ "<leader>kl", "<Cmd>MoltenEvaluateLine<CR>", desc = "Run line" },
		{ "<leader>ko", "<Cmd>MoltenEvaluateOperator<CR>", desc = "Run motion (then a motion)" },
		{ "<leader>ke", "<Cmd>noautocmd MoltenEnterOutput<CR>", desc = "Enter output window" },
		{ "<leader>kh", "<Cmd>MoltenHideOutput<CR>", desc = "Hide output window" },
		{ "<leader>kd", "<Cmd>MoltenDelete<CR>", desc = "Delete cell output" },
		{ "<leader>kp", "<Cmd>MoltenImagePopup<CR>", desc = "Open output image" },
		{ "<leader>kb", "<Cmd>MoltenOpenInBrowser<CR>", desc = "Open HTML output in browser" },
		{ "<leader>kE", "<Cmd>MoltenExportOutput!<CR>", desc = "Export outputs to the .ipynb" },
		{ "<leader>kI", "<Cmd>MoltenImportOutput<CR>", desc = "Import outputs from the .ipynb" },
		{ "<leader>kN", util("notebook_new"), desc = "New notebook" },
		{ "<leader>kv", util("jupyter_kernel_add"), desc = "Register uv project as kernel" }, -- uv add --dev ipykernel, then the kernelspec
	},
	config = function()
		local group = require("utils").augroup("molten-kernel")
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
			desc = "999rpm: forget the buffer's kernel",
			callback = function(ev)
				vim.b[ev.buf]._999rpm_kernel = nil
				vim.b[ev.buf]._999rpm_ready = nil
			end,
		})
	end,
}
