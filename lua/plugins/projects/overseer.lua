-- stevearc/overseer.nvim: build and task runner, the build and output side of a Visual Studio project. Tasks come from
-- the project: make targets, cargo, npm scripts, just recipes, .vscode/tasks.json and more; a lone C or C++ file builds
-- with clang, the flags in utils/run.lua and the file's own "// 999rpm-flags:" lines. A failed build fills the quickfix
-- list and opens it. nvim-dap runs a launch.json's preLaunchTask through it. Owns <leader>wb, <leader>wr, <leader>wt,
-- <leader>wl and <leader>wa.

---Runs the build task; without one (a plain folder) the template picker opens instead.
local function build()
	local overseer = require("overseer")
	overseer.run_task({ tags = { overseer.TAG.BUILD } }, function(task)
		if not task then
			vim.cmd("OverseerRun")
		end
	end)
end

---Restarts the newest task.
local function restart_last()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({ sort = require("overseer.task_list").sort_newest_first })
	if #tasks == 0 then
		return vim.notify("No task has run yet", vim.log.levels.INFO, { title = "Overseer" })
	end
	overseer.run_action(tasks[1], "restart")
end

local quickfix = { "on_output_quickfix", open_on_exit = "failure" } -- errors to the quickfix list, opened when the build fails

return {
	"stevearc/overseer.nvim",
	cmd = { "OverseerRun", "OverseerToggle", "OverseerOpen", "OverseerTaskAction" },
	-- overseer's own keys in the task list: (n) <CR> actions, o open the output, <C-v>/<C-s>/<C-t>/<C-f> the output in a
	-- vsplit/split/tab/float, p preview, {/} previous/next task, <C-k>/<C-j> scroll the output, dd dispose, <C-e> edit,
	-- <C-q> the output to quickfix, g. wrap lines, ? help, q close.
	keys = {
		{ "<leader>wb", build, desc = "Build" }, -- n: the project's build task (make, cargo build, npm run build); with none, the task picker
		{ "<leader>wr", "<Cmd>OverseerRun<CR>", desc = "Run a task" }, -- n: pick any task the project offers and run it
		{ "<leader>wt", "<Cmd>OverseerToggle<CR>", desc = "Task list" }, -- n: the task list at the bottom, each task with its state
		{ "<leader>wl", restart_last, desc = "Restart last task" }, -- n: run the newest task again (l for last)
		{ "<leader>wa", "<Cmd>OverseerTaskAction<CR>", desc = "Task action" }, -- n: pick a task, then restart, stop, watch or open its output
	},
	opts = {},
	config = function(_, opts)
		local overseer = require("overseer")
		overseer.setup(opts)
		local run = require("utils.run")
		overseer.register_template({ -- one provider: overseer v2 conditions match filetype and folder only
			name = "999rpm builds",
			generator = function(search, cb)
				local templates = {}
				local makefile = run.makefile(search.dir)
				if makefile then
					templates[#templates + 1] = {
						name = "make: build",
						desc = "make's default target",
						tags = { overseer.TAG.BUILD }, -- overseer's own make tasks carry no build tag
						builder = function()
							return {
								cmd = { "make" },
								cwd = vim.fs.dirname(makefile),
								components = { quickfix, "default" },
							}
						end,
					}
				end
				local file = vim.api.nvim_buf_get_name(0)
				if (search.filetype == "c" or search.filetype == "cpp") and file ~= "" and run.is_lone(file) then
					templates[#templates + 1] = {
						name = "clang: build file",
						desc = "the current file with clang, utils/run.lua's flags and its 999rpm-flags lines",
						tags = { overseer.TAG.BUILD },
						builder = function()
							return {
								cmd = run.build_cmd(file),
								cwd = vim.fs.dirname(file),
								components = { quickfix, "default" },
							}
						end,
					}
				end
				cb(templates)
			end,
		})
	end,
}
