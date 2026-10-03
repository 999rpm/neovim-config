-- Jupyter environment in stdpath("data")/999rpm-jupyter: pynvim, jupyter_client, jupytext, ipykernel and molten's image
-- packages. uv builds it when it is on $PATH (and fetches a Python of its own when none is installed), else python3's
-- venv and pip. Every step runs as an argument list from stdpath("data"), so neither 'shell' (zsh or nushell) nor a
-- project's .python-version, uv.toml or pip settings reach it.
local fn = vim.fn
local core = require("utils.core")

local M = {}

local PACKAGES = { "pynvim", "jupyter_client", "jupytext", "ipykernel", "nbformat", "cairosvg", "pillow" } -- molten's requirements and the jupytext CLI; ipykernel gives the environment a python3 kernel of its own

---@return string
function M.python() -- This util is used by options.lua, and jupytext and setup below
	return fn.stdpath("data") .. "/999rpm-jupyter/" .. (fn.has("win32") == 1 and "Scripts/python.exe" or "bin/python")
end

---@return string jupytext from the Jupyter environment, else the one on $PATH
function M.jupytext() -- This util is used by utils/notebook.lua
	local bin = vim.fs.dirname(M.python()) .. "/jupytext"
	return vim.uv.fs_stat(bin) and bin or "jupytext"
end

---Creates the environment, installs or upgrades its packages and registers molten's remote plugin.
function M.setup() -- This util is used by molten.lua
	local python = M.python()
	local dir = vim.fs.dirname(vim.fs.dirname(python))
	local uv = core.executable("uv")
	local base = core.executable("python3") and "python3" or core.executable("python") and "python" or nil
	local steps = {}
	if not vim.uv.fs_stat(python) then
		if not (uv or base) then
			return core.warn(
				"Neither uv nor python3 is on $PATH; one of them is needed once, to create " .. dir,
				"Jupyter"
			)
		end
		steps[1] = uv and { "uv", "venv", "--quiet", dir } or { base, "-m", "venv", dir } -- uv's environment has no pip of its own
	end
	local install = uv and { "uv", "pip", "install", "--quiet", "--upgrade", "--python", python }
		or { python, "-m", "pip", "install", "--quiet", "--upgrade" }
	steps[#steps + 1] = vim.list_extend(install, PACKAGES)
	steps[#steps + 1] = {
		python,
		"-c",
		"import os; from jupyter_core.paths import jupyter_runtime_dir as d; os.makedirs(d(), exist_ok=True)",
	} -- molten fails with ENOENT on a kernel-*.json while this folder is missing
	vim.notify(
		("Building the Jupyter environment in %s with %s"):format(dir, uv and "uv" or "pip"),
		vim.log.levels.INFO,
		{ title = "Jupyter" }
	)
	core.run_chain(steps, fn.stdpath("data"), "Jupyter", function()
		vim.g.loaded_python3_provider = nil -- options.lua turns the provider off while no environment exists
		vim.g.python3_host_prog = python
		local ok, err = pcall(vim.cmd.UpdateRemotePlugins)
		if ok then
			pcall(vim.cmd.source, fn.stdpath("data") .. "/rplugin.vim") -- the new manifest: molten's commands exist without a restart
		end
		local level = ok and vim.log.levels.INFO or vim.log.levels.ERROR
		vim.notify(ok and ("Jupyter environment ready in " .. dir) or tostring(err), level, { title = "Jupyter" })
	end)
end

---Registers the uv project around the current file (else the working directory) as a Jupyter kernel, the way uv's
---Jupyter guide does: ipykernel becomes a dev dependency, then the project's own Python writes the kernelspec, with
---VIRTUAL_ENV set so `!uv pip install` in a cell installs into the project. molten's picker lists it afterwards.
---@param name? string kernel name; defaults to the project folder's name
function M.kernel_add(name) -- This util is used by molten.lua
	if not core.executable("uv") then
		return core.warn("uv is not on $PATH.", "Jupyter")
	end
	local markers = { "pyproject.toml", "uv.lock" }
	local root = vim.fs.root(0, markers) or vim.fs.root(fn.getcwd(), markers)
	if not root then
		return core.warn(
			"No pyproject.toml above this file or the working directory; `uv init` creates one.",
			"Jupyter"
		)
	end
	local label = (name and name ~= "") and name or vim.fs.basename(root)
	local kernel = label:lower():gsub("[^%w._-]", "-") -- kernelspec names allow letters, digits, ".", "_" and "-"
	local install = { "uv", "run", "--quiet", "python", "-m", "ipykernel", "install", "--user", "--name", kernel }
	vim.list_extend(install, { "--display-name", label .. " (uv)", "--env", "VIRTUAL_ENV", root .. "/.venv" })
	core.run_chain({ { "uv", "add", "--quiet", "--dev", "ipykernel" }, install }, root, "Jupyter", function()
		vim.notify(
			("Kernel %q registered; <leader>ki lists it"):format(kernel),
			vim.log.levels.INFO,
			{ title = "Jupyter" }
		)
	end)
end

return M
