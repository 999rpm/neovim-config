-- 999rpm-projects: Visual Studio's start-window jobs. <leader>wn creates a project from a template (C and C++ with a
-- Makefile, Rust, Python through uv, JavaScript through npm, an empty folder) in the folder typed at its prompt, which
-- starts in the working directory, puts it under git and opens it; <leader>wp lists projects (folders with .git, a
-- Makefile or package.json under vim.g.projects_dir, options.lua, and the roots of recent files) and opens the chosen
-- one: its session comes back, or the files picker opens when no saved session shows a file of it. :ProjectNew
-- [template] [folder] does the same as wn. Each project keeps its own session (persistence.lua).
-- Settings: a .nvim.lua at the project root runs at startup after :trust approves it (options.lua 'exrc'); nvim-dap
-- reads .vscode/launch.json and overseer.lua .vscode/tasks.json, as in VS Code. Owns <leader>wn and <leader>wp.
return {
	"999rpm-projects", -- a name with no slash: lazy.nvim looks for no repository
	virtual = true, -- and adds no rtp entry; the code is utils/project.lua
	cmd = "ProjectNew",
	-- snacks' own keys in the projects picker: <CR> open (utils/project.lua's open() here), <C-f> files, <C-g> grep,
	-- <C-r> recent files, <C-e> explorer, <C-w> change the tab's directory only.
	keys = {
		{
			"<leader>wn",
			function()
				require("utils.project").new_project()
			end,
			desc = "New project",
		}, -- n: pick a template, then a folder; the prompt starts in the working directory
		{
			"<leader>wp",
			function()
				Snacks.picker.projects({
					dev = { vim.g.projects_dir },
					max_depth = 3, -- three levels: Coding/<group>/<project>
					confirm = require("utils.project").open,
				})
			end,
			desc = "Open project",
		}, -- n: type part of a project's name, then <CR> opens its folder with its session, or with the files picker
	},
	config = function()
		vim.api.nvim_create_user_command("ProjectNew", function(o)
			require("utils.project").new_project(o.fargs[1], o.fargs[2])
		end, { nargs = "*", desc = "Create a project: [template] [folder]" })
	end,
}
