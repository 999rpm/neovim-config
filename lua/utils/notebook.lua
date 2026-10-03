-- Jupyter notebooks as jupytext markdown, and code cells in any buffer that has them: fenced blocks in notebooks and
-- quarto documents, "<comment> %%" lines in scripts (jupytext's percent format). molten-nvim runs the cells.
local fn = vim.fn
local api = vim.api
local core = require("utils.core")

local M = {}

---@param msg string
local function warn(msg)
	core.warn(msg, "Jupyter")
end

---@param cmd string[]
---@return boolean ok, string output stdout on success, the error otherwise
local function run_jupytext(cmd)
	local ok, res = pcall(function()
		return vim.system(cmd, { text = true }):wait()
	end)
	if not ok then
		return false, tostring(res) -- vim.system raises when the executable is missing
	end
	return res.code == 0, res.code == 0 and res.stdout or vim.trim(res.stderr ~= "" and res.stderr or res.stdout)
end

local TEMPLATE = { -- jupytext markdown for an empty Python notebook; the header carries the kernelspec into the .ipynb
	"---",
	"jupyter:",
	"  kernelspec:",
	"    display_name: Python 3",
	"    language: python",
	"    name: python3",
	"---",
	"",
	"```python",
	"",
	"```",
}

---Opens an .ipynb as jupytext markdown and fires the read events an :edit fires, so plugins that load on them do. A
---notebook jupytext cannot read opens as JSON instead. A notebook with saved outputs starts its kernel to show them.
---@param ev vim.api.keyset.create_autocmd.callback_args
function M.read(ev) -- This util is used by ipynb.lua
	local buf, path = ev.buf, fn.fnamemodify(ev.match, ":p")
	api.nvim_exec_autocmds("BufReadPre", { buffer = buf, modeline = false })
	local exists = vim.uv.fs_stat(path) ~= nil
	local lines, converted = TEMPLATE, true
	if exists then
		local ok, out = run_jupytext({ require("utils.jupyter").jupytext(), "--to", "md", "--output", "-", path })
		if ok then
			lines = vim.split((out:gsub("\n$", "")), "\n")
		else
			converted, lines = false, fn.readfile(path)
			warn(
				"jupytext could not convert the notebook, so it opens as JSON. :JupyterSetup installs jupytext.\n"
					.. out
			)
		end
	end
	vim.b[buf]._999rpm_notebook = converted
	local undolevels = vim.bo[buf].undolevels
	vim.bo[buf].undolevels = -1 -- the conversion is not an edit: u must not empty the buffer
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].undolevels = undolevels
	vim.bo[buf].modified = false
	api.nvim_exec_autocmds("BufReadPost", { buffer = buf, modeline = false }) -- filetype detection (options.lua) and lazy loading
	if vim.bo[buf].filetype == "" then -- vim.lsp.enable() fires FileType when lspconfig loads on BufReadPre, so :setf skips this nested read
		vim.bo[buf].filetype = vim.filetype.match({ buf = buf, filename = path }) or ""
	end
	if converted and exists then
		vim.schedule(function()
			M.kernel(buf, true)
		end)
	end
end

---Writes the buffer into the .ipynb through jupytext --update (inputs replaced, outputs and metadata kept), then exports
---the outputs molten produced in this session into the same file.
---@param ev vim.api.keyset.create_autocmd.callback_args
function M.write(ev) -- This util is used by ipynb.lua
	local buf, path = ev.buf, fn.fnamemodify(ev.match, ":p")
	local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
	if not vim.b[buf]._999rpm_notebook then -- opened as JSON: written back unchanged
		if fn.writefile(lines, path) == 0 then
			vim.bo[buf].modified = false
		end
		return
	end
	local tmp = fn.tempname() .. ".md"
	fn.writefile(lines, tmp)
	local cmd = { require("utils.jupyter").jupytext(), "--to", "ipynb", "--output", path, tmp }
	if vim.uv.fs_stat(path) then
		table.insert(cmd, 4, "--update") -- keeps the outputs and metadata already in the notebook
	end
	local ok, out = run_jupytext(cmd)
	os.remove(tmp)
	if not ok then
		return vim.notify("Notebook not written: " .. out, vim.log.levels.ERROR, { title = "Notebook" })
	end
	vim.bo[buf].modified = false
	if vim.b[buf]._999rpm_kernel then
		pcall(vim.cmd, "MoltenExportOutput!") -- ! replaces the outputs jupytext kept with the ones run here
	end
end

local queue = {} -- buffer -> cells pressed while its kernel was still starting

---Starts a kernel for the buffer: the notebook's own (metadata.kernelspec.name) when it is installed, else molten's
---picker. With auto (on open) it never prompts, and it imports the outputs saved in the notebook.
---@param buf? integer
---@param auto? boolean
---@return boolean running
function M.kernel(buf, auto) -- This util is used by molten.lua, and read and run in this file
	buf = buf or api.nvim_get_current_buf()
	if vim.b[buf]._999rpm_kernel then
		return true
	elseif buf ~= api.nvim_get_current_buf() then
		return false -- molten starts kernels for the current buffer only
	end
	pcall(require("lazy").load, { plugins = { "molten-nvim" } })
	if fn.exists(":MoltenInit") ~= 2 then
		if not auto then
			warn("molten's commands are not registered: run :JupyterSetup once.")
		end
		return false
	end
	local path, name = api.nvim_buf_get_name(buf), nil
	if path:match("%.ipynb$") and vim.uv.fs_stat(path) then
		local ok, nb = pcall(vim.json.decode, table.concat(fn.readfile(path), "\n"))
		name = ok and vim.tbl_get(nb, "metadata", "kernelspec", "name") or nil
	end
	if name and not vim.list_contains(fn.MoltenAvailableKernels(), name) then
		warn(("Kernel %q is not installed here; <leader>ki picks another."):format(name))
		name = nil
	end
	if not name then
		if not auto then
			vim.cmd("MoltenInit") -- molten's own picker; the cell runs on the next key press
		end
		return false
	end
	local ok, err = pcall(vim.cmd, "MoltenInit " .. name)
	if not ok or not vim.b[buf]._999rpm_kernel then -- molten reports its own failures through vim.notify
		if not ok then
			warn(tostring(err))
		end
		return false
	end
	local ids = fn.MoltenRunningKernels(true)
	local id = ids[#ids]
	vim.b[buf]._999rpm_ready = false -- output sent before the kernel answers is lost, so run queues cells until then
	api.nvim_create_autocmd("User", {
		group = core.augroup("molten-ready", false),
		pattern = "MoltenKernelReady",
		desc = "999rpm: run the cells queued while the kernel started",
		callback = function(ev)
			if vim.tbl_get(ev, "data", "kernel_id") ~= id then
				return
			end
			if api.nvim_buf_is_valid(buf) then
				vim.b[buf]._999rpm_ready = nil
			end
			local queued = queue[buf]
			queue[buf] = nil
			if queued then
				vim.schedule(queued)
			end
			return true -- one ready event per kernel: the autocommand removes itself
		end,
	})
	if auto then
		pcall(vim.cmd, "MoltenImportOutput")
	end
	return true
end

---How a buffer writes its cells: fenced blocks in markdown and quarto, "<comment> %%" lines elsewhere.
---@param buf integer
---@return boolean fenced
---@return string marker cell line for a new cell, e.g. "# %%"
---@return string pattern Lua pattern matching a cell line
local function cell_style(buf)
	local ft = vim.bo[buf].filetype
	local leader = vim.trim(vim.bo[buf].commentstring:match("^(.-)%%s") or "")
	leader = leader ~= "" and leader or "#"
	return ft == "markdown" or ft == "quarto", leader .. " %%", "^%s*" .. vim.pesc(leader) .. "%s*%%%%"
end

---Code cells in order: ```fences with a language in markdown and quarto, else the blocks between "<comment> %%" lines.
---Rows are 1-based; first > last marks an empty cell, stop is the last row the cell owns.
---@param buf integer
---@return { head: integer?, first: integer, last: integer, foot: integer?, stop: integer, lang: string?, fence: string? }[]
local function cells_of(buf)
	local lines, cells = api.nvim_buf_get_lines(buf, 0, -1, false), {}
	local fenced, _, marker = cell_style(buf)
	if fenced then
		for _, block in ipairs(require("utils.fences").blocks(lines)) do
			if block.lang ~= "" then
				cells[#cells + 1] = {
					head = block.open,
					first = block.open + 1,
					last = block.close - 1,
					foot = block.close,
					stop = block.close,
					lang = block.lang,
					fence = block.fence,
				}
			end
		end
		return cells
	end
	local heads = {}
	for i, line in ipairs(lines) do
		if line:match(marker) then
			heads[#heads + 1] = i
		end
	end
	local function add(head, first, stop)
		local last = stop
		while last >= first and lines[last]:match("^%s*$") do
			last = last - 1
		end
		cells[#cells + 1] = { head = head, first = first, last = last, stop = stop }
	end
	if heads[1] and heads[1] > 1 then
		add(nil, 1, heads[1] - 1) -- code above the first marker is a cell too, as jupytext reads it
	end
	for k, head in ipairs(heads) do
		add(head, head + 1, (heads[k + 1] or (#lines + 1)) - 1)
	end
	return cells
end

---@return integer? index, table? cell the cell owning the row
local function cell_at(cells, row)
	for i, cell in ipairs(cells) do
		if row >= (cell.head or cell.first) and row <= cell.stop then
			return i, cell
		end
	end
end

---Runs code cells in molten: "cell" the one under the cursor, "next" that one and then the cursor moves to the next
---cell, "above" every cell up to and including it, "all" every cell. A buffer with no kernel starts one first.
---@param scope "cell"|"next"|"above"|"all"
function M.run(scope) -- This util is used by molten.lua and attach below
	local buf = api.nvim_get_current_buf()
	local cells = cells_of(buf)
	local idx = cell_at(cells, api.nvim_win_get_cursor(0)[1])
	if not idx and scope ~= "all" then
		return warn("The cursor is not in a code cell.")
	elseif #cells == 0 or not M.kernel(buf) then
		return
	end
	local from, to = idx, idx
	if scope == "above" then
		from = 1
	elseif scope == "all" then
		from, to = 1, #cells
	end
	local function evaluate()
		if api.nvim_get_current_buf() ~= buf then
			return warn("The kernel is ready; the cell did not run because another buffer is current.")
		end
		for i = from, to do
			if cells[i].first <= cells[i].last then
				fn.MoltenEvaluateRange(cells[i].first, cells[i].last)
			end
		end
	end
	if vim.b[buf]._999rpm_ready == false then
		queue[buf] = evaluate -- kernel's MoltenKernelReady handler runs it
	else
		evaluate()
	end
	local after = scope == "next" and cells[idx + 1]
	if after then
		api.nvim_win_set_cursor(0, { math.min(after.first, api.nvim_buf_line_count(buf)), 0 })
	end
end

---Moves to the first code line of the next (dir 1) or previous (dir -1) cell; a count repeats it.
---@param dir 1|-1
function M.jump(dir) -- This util is used by attach below
	local buf = api.nvim_get_current_buf()
	local row = api.nvim_win_get_cursor(0)[1]
	local starts = vim.tbl_map(function(cell)
		return math.min(cell.first, api.nvim_buf_line_count(buf))
	end, cells_of(buf))
	for _ = 1, vim.v.count1 do
		local hit
		for i = dir > 0 and 1 or #starts, dir > 0 and #starts or 1, dir do
			if (dir > 0 and starts[i] > row) or (dir < 0 and starts[i] < row) then
				hit = starts[i]
				break
			end
		end
		if not hit then
			break
		end
		row = hit
	end
	api.nvim_win_set_cursor(0, { row, 0 })
end

---mini.ai textobject for the cell under the cursor, or the next one below it: ij its code, aj the code with its fence
---or "# %%" line.
---@param ai_type "a"|"i"
---@return table? region
function M.cell_region(ai_type) -- This util is used by mini.lua
	local buf = api.nvim_get_current_buf()
	local row = api.nvim_win_get_cursor(0)[1]
	local cells = cells_of(buf)
	local _, cell = cell_at(cells, row)
	for _, c in ipairs(cell and {} or cells) do
		if (c.head or c.first) > row then
			cell = c
			break
		end
	end
	if not cell then
		return nil
	end
	local first, last = cell.first, cell.last
	if ai_type == "a" then
		first, last = cell.head or cell.first, cell.foot or cell.last
	end
	if first > last then
		return nil
	end
	local text = api.nvim_buf_get_lines(buf, last - 1, last, false)[1] or ""
	return { from = { line = first, col = 1 }, to = { line = last, col = math.max(#text, 1) }, vis_mode = "V" }
end

---Opening and closing fence of a new code cell: the given cell's language, else the kernel language in the jupytext
---header, else python; quarto writes it as {lang}.
---@param buf integer
---@param cell? table
---@return string open
---@return string close
local function cell_fence(buf, cell)
	local lang = cell and cell.lang ~= "" and cell.lang or nil
	for _, line in ipairs(lang and {} or api.nvim_buf_get_lines(buf, 0, 20, false)) do
		lang = lang or line:match("^%s+language:%s*([%w_.+-]+)")
	end
	lang = lang or "python"
	local fence = cell and cell.fence or "```"
	return fence .. (vim.bo[buf].filetype == "quarto" and ("{" .. lang .. "}") or lang), fence
end

---Adds an empty code cell above (dir -1) or below (dir 1) the cell under the cursor, or at the cursor line outside a
---cell, and starts insert mode in it (JupyterLab's a and b).
---@param dir 1|-1
function M.cell_add(dir) -- This util is used by attach below
	local buf = api.nvim_get_current_buf()
	local row = api.nvim_win_get_cursor(0)[1]
	local lines, cells = api.nvim_buf_get_lines(buf, 0, -1, false), cells_of(buf)
	local _, cell = cell_at(cells, row)
	local fenced, marker, pattern = cell_style(buf)
	local at = dir > 0 and row or row - 1 -- the new cell goes below this row
	if cell then
		at = dir > 0 and cell.stop or (cell.head or cell.first) - 1
	end
	local new
	if fenced then
		local open, close = cell_fence(buf, cell or cells[1])
		new = { open, "", close }
		if lines[at + 1] and not lines[at + 1]:match("^%s*$") then
			new[#new + 1] = ""
		end
	else
		new = { marker, "" }
		if lines[at + 1] and not lines[at + 1]:match(pattern) then
			new[#new + 1] = marker -- the code below keeps a cell of its own
		end
	end
	local pad = at > 0 and not lines[at]:match("^%s*$")
	if pad then
		table.insert(new, 1, "")
	end
	api.nvim_buf_set_lines(buf, at, at, false, new)
	api.nvim_win_set_cursor(0, { at + (pad and 3 or 2), 0 })
	vim.cmd("startinsert")
end

---Deletes the cell under the cursor, fence or cell line included, into the registers like dd, so p pastes it elsewhere
---(JupyterLab's x); molten's output for the cell goes with it.
function M.cell_delete() -- This util is used by attach below
	local buf = api.nvim_get_current_buf()
	local _, cell = cell_at(cells_of(buf), api.nvim_win_get_cursor(0)[1])
	if not cell then
		return warn("The cursor is not in a code cell.")
	end
	if vim.b[buf]._999rpm_kernel then
		pcall(vim.cmd, "MoltenDelete") -- the output's extmarks would outlive the lines
	end
	local first, last = cell.head or cell.first, cell.stop
	if cell.foot then -- one blank line around a fenced cell goes too, so separators do not pile up
		local below = api.nvim_buf_get_lines(buf, last, last + 1, false)[1]
		local above = first > 1 and api.nvim_buf_get_lines(buf, first - 2, first - 1, false)[1]
		if below and below:match("^%s*$") then
			last = last + 1
		elseif above and above:match("^%s*$") then
			first = first - 1
		end
	end
	vim.cmd(("%d,%ddelete"):format(first, last))
end

---Splits the cell under the cursor in two; the cursor line starts the second cell.
function M.cell_split() -- This util is used by attach below
	local buf = api.nvim_get_current_buf()
	local row = api.nvim_win_get_cursor(0)[1]
	local _, cell = cell_at(cells_of(buf), row)
	if not cell or row <= cell.first or row > cell.last then
		return warn("A split needs the cursor on a code line below the first line of a cell.")
	end
	local fenced, marker = cell_style(buf)
	local insert = { "", marker }
	if fenced then
		local open, close = cell_fence(buf, cell)
		insert = { close, "", open }
	end
	api.nvim_buf_set_lines(buf, row - 1, row - 1, false, insert)
	api.nvim_win_set_cursor(0, { row + #insert, 0 })
end

---Joins the cell under the cursor with the next code cell (JupyterLab's Shift+M) when only blank lines part them.
function M.cell_join() -- This util is used by attach below
	local buf = api.nvim_get_current_buf()
	local cells = cells_of(buf)
	local i, cell = cell_at(cells, api.nvim_win_get_cursor(0)[1])
	local next_cell = i and cells[i + 1]
	if not next_cell then
		return warn("No code cell below this one.")
	end
	local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
	if not cell.foot then -- "# %%" cells: the next cell line goes
		local head = lines[next_cell.head]:lower()
		if head:find("[markdown]", 1, true) or head:find("[md]", 1, true) then
			return warn("The next cell is a markdown cell.")
		end
		return api.nvim_buf_set_lines(buf, next_cell.head - 1, next_cell.head, false, {})
	elseif next_cell.lang ~= cell.lang then
		return warn(("The next cell is %s, this one %s."):format(next_cell.lang, cell.lang))
	end
	for r = cell.foot + 1, next_cell.head - 1 do
		if not lines[r]:match("^%s*$") then
			return warn("Markdown text sits between the two cells.")
		end
	end
	api.nvim_buf_set_lines(buf, cell.foot - 1, next_cell.head, false, {})
end

---Cell keys for one buffer: ]j/[j and the <leader>k cell edits wherever cells can exist; in notebooks and quarto
---documents also <S-CR>/<C-CR> to run cells, and otter's language servers inside the code fences.
---@param buf integer
function M.attach(buf) -- This util is used by ipynb.lua
	local ft = vim.bo[buf].filetype
	local notebook = vim.b[buf]._999rpm_notebook or ft == "quarto"
	if
		vim.b[buf]._999rpm_cells
		or (ft == "markdown" and not notebook)
		or api.nvim_buf_get_name(buf):find("%.otter%.")
	then
		return -- plain markdown and the notes graph have no cells; otter's hidden buffers need no keys
	end
	vim.b[buf]._999rpm_cells = true
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buf = buf, desc = desc })
	end
	map({ "n", "x", "o" }, "]j", function()
		M.jump(1)
	end, "Next cell") -- buffer-local: elsewhere ]j/[j are textobjects.lua's JSX moves
	map({ "n", "x", "o" }, "[j", function()
		M.jump(-1)
	end, "Previous cell")
	map("n", "<leader>ka", function()
		M.cell_add(-1)
	end, "Add cell above")
	map("n", "<leader>kb", function()
		M.cell_add(1)
	end, "Add cell below")
	map("n", "<leader>kd", M.cell_delete, "Delete cell (p pastes it)")
	map("n", "<leader>ks", M.cell_split, "Split cell at cursor")
	map("n", "<leader>kj", M.cell_join, "Join cell with next")
	if not notebook then
		return
	end
	map("n", "<S-CR>", function()
		M.run("next")
	end, "Run cell, go to next")
	map("n", "<C-CR>", function()
		M.run("cell")
	end, "Run cell")
	map("i", "<S-CR>", "<Esc><Cmd>lua require('utils.notebook').run('next')<CR>", "Run cell, go to next")
	map("i", "<C-CR>", "<Esc><Cmd>lua require('utils.notebook').run('cell')<CR>", "Run cell")
	vim.b[buf].disable_autoformat = true -- conform: prettier would reflow the jupytext markdown
	vim.b[buf].disable_lint = true -- lint.lua: markdownlint flags the jupytext header
	vim.schedule(function()
		if api.nvim_get_current_buf() == buf then
			pcall(function()
				require("otter").activate()
			end)
		end
	end)
end

---Opens a new notebook (".ipynb" is added when missing); it starts as one empty Python cell.
---@param name? string
function M.new(name) -- This util is used by molten.lua and ipynb.lua
	local function open(file)
		file = vim.trim(file or "")
		if file ~= "" then
			vim.cmd.edit(fn.fnameescape(file:match("%.ipynb$") and file or (file .. ".ipynb")))
		end
	end
	if name and name ~= "" then
		return open(name)
	end
	vim.ui.input({ prompt = "New notebook: ", completion = "file" }, open)
end

return M
