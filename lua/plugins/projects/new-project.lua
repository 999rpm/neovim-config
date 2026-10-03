-- 999rpm-projects: Visual Studio's start-window jobs. <leader>wn creates a project from a template (C and C++ with a
-- Makefile, Rust, Python through uv, JavaScript through npm, an empty folder) under vim.g.projects_dir (options.lua),
-- puts it under git and opens it; <leader>wp lists projects (folders with .git, a Makefile or package.json under the
-- projects folder, and the roots of recent files) and opens the chosen one. :ProjectNew [template] does the same as wn.
-- Projects picker: <CR> open (restores the folder's session when one exists), <C-f> files, <C-g> grep, <C-r> recent
-- files, <C-e> explorer, <C-w> change the tab's directory only. Each project keeps its own session (persistence.lua).
-- Settings: a .nvim.lua at the project root runs at startup after :trust approves it (options.lua 'exrc'); nvim-dap
-- reads .vscode/launch.json and overseer.lua .vscode/tasks.json, as in VS Code.
return {
	"999rpm-projects", -- a name with no slash: lazy.nvim looks for no repository
	virtual = true, -- and adds no rtp entry; the code is utils/project.lua
	cmd = "ProjectNew",
	keys = {
		{
			"<leader>wn",
			function()
				require("utils.project").new_project()
			end,
			desc = "New project",
		},
		{
			"<leader>wp",
			function()
				Snacks.picker.projects({ dev = { vim.g.projects_dir }, max_depth = 3 }) -- three levels: Coding/<group>/<project>
			end,
			desc = "Open project",
		},
	},
	config = function()
		vim.api.nvim_create_user_command("ProjectNew", function(o)
			require("utils.project").new_project(o.fargs[1], o.fargs[2])
		end, { nargs = "*", desc = "Create a project: [template] [folder]" })
	end,
}
