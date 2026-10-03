-- New-project wizard, Visual Studio's "Create a new project": pick a template, type the folder, and the project is
-- created there, put under git and opened, with the working directory moved into it. Rust, Python and JavaScript
-- projects come from their own tools (cargo, uv, npm); C and C++ get a Makefile with build, release, run and clean
-- targets (overseer.lua lists them as tasks) and a compile_flags.txt, so clangd checks the flags the build uses. Every
-- command is an argument list, so zsh and nushell behave the same.
local fn = vim.fn
local core = require("utils.core")

local M = {}

local FLAGS = require("utils.run").flags

---Makefile, sources and clangd flags of a C or C++ project.
---@param lang "c"|"cpp"
---@param name string
---@return table<string, string[]>
local function native_files(lang, name)
	local cpp = lang == "cpp"
	local cc, flags_var = cpp and "CXX := clang++" or "CC := clang", cpp and "CXXFLAGS" or "CFLAGS"
	local compile = cpp and "$(CXX) $(CXXFLAGS)" or "$(CC) $(CFLAGS)"
	local std = cpp and "-std=c++20" or "-std=c17"
	local flags = table.concat(FLAGS, " ") .. " " .. std
	local main = cpp
			and {
				"#include <iostream>",
				"",
				"int main() {",
				'  std::cout << "Hello from ' .. name .. '\\n";',
				"  return 0;",
				"}",
			}
		or {
			"#include <stdio.h>",
			"",
			"int main(void) {",
			'  printf("Hello from ' .. name .. '\\n");',
			"  return 0;",
			"}",
		}
	return {
		["Makefile"] = { -- recipe lines start with a tab, as make requires
			cc,
			("%s := %s"):format(flags_var, flags),
			"RELEASE := -O2 -DNDEBUG",
			"NAME := " .. name,
			("SRC := $(wildcard src/*.%s)"):format(lang),
			"",
			".PHONY: build release run clean",
			"",
			"build: build/debug/$(NAME)",
			"",
			"build/debug/$(NAME): $(SRC)",
			"\t@mkdir -p $(@D)",
			"\t" .. compile .. " $^ -o $@",
			"",
			"release: $(SRC)",
			"\t@mkdir -p build/release",
			("\t%s $(RELEASE) $^ -o build/release/$(NAME)"):format(
				(compile:gsub("%$%((%u+)%)$", "$(filter-out -g,$(%1))"))
			),
			"",
			"run: build",
			"\t./build/debug/$(NAME)",
			"",
			"clean:",
			"\trm -rf build",
		},
		["src/main." .. lang] = main,
		["compile_flags.txt"] = vim.list_extend(vim.deepcopy(FLAGS), { std }), -- clangd reads one flag per line
		[".gitignore"] = { "build/" },
	}
end

---@class Template
---@field name string
---@field needs? string executable the template runs
---@field cmd? fun(dir: string, name: string): string[][] commands, run from the parent folder (the new one with mkdir)
---@field files? fun(name: string): table<string, string[]>
---@field open string file opened once the project exists
---@field git? boolean true when the tool already ran git init
---@field mkdir? boolean create the folder before the commands run

---@type Template[]
local TEMPLATES = {
	{
		name = "C (Makefile, clang)",
		needs = "clang",
		files = function(name)
			return native_files("c", name)
		end,
		open = "src/main.c",
	},
	{
		name = "C++ (Makefile, clang++)",
		needs = "clang++",
		files = function(name)
			return native_files("cpp", name)
		end,
		open = "src/main.cpp",
	},
	{
		name = "Rust (cargo)",
		needs = "cargo",
		cmd = function(dir)
			return { { "cargo", "new", "--quiet", dir } }
		end,
		open = "src/main.rs",
		git = true,
	},
	{
		name = "Python (uv)",
		needs = "uv",
		cmd = function(dir)
			return { { "uv", "init", "--quiet", dir } }
		end,
		open = "main.py",
		git = true,
	},
	{
		name = "JavaScript (npm)",
		needs = "npm",
		cmd = function(dir)
			return { { "npm", "init", "--yes" } } -- runs inside the new folder
		end,
		mkdir = true,
		files = function(name)
			return {
				["index.js"] = { ('console.log("Hello from %s");'):format(name) },
				[".gitignore"] = { "node_modules/" },
			}
		end,
		open = "index.js",
	},
	{
		name = "Empty folder",
		files = function(name)
			return { ["README.md"] = { "# " .. name } }
		end,
		open = "README.md",
	},
}

---Writes each file under dir, creating folders on the way.
---@param dir string
---@param files table<string, string[]>
local function write_files(dir, files)
	for rel, lines in pairs(files) do
		local path = dir .. "/" .. rel
		core.may_create_dir(vim.fs.dirname(path))
		fn.writefile(lines, path)
	end
end

---@param tpl Template
---@param dir string absolute folder of the new project
local function create(tpl, dir)
	local name = vim.fs.basename(dir)
	local parent = vim.fs.dirname(dir)
	core.may_create_dir(parent)
	if not tpl.cmd or tpl.mkdir then
		core.may_create_dir(dir)
	end
	local steps = tpl.cmd and tpl.cmd(dir, name) or {}
	core.run_chain(steps, tpl.mkdir and dir or parent, "New project", function()
		if tpl.files then
			write_files(dir, tpl.files(name))
		end
		local finish = function()
			vim.cmd.cd(fn.fnameescape(dir))
			vim.cmd.edit(fn.fnameescape(dir .. "/" .. tpl.open))
			vim.notify(("%s created in %s"):format(tpl.name, dir), vim.log.levels.INFO, { title = "New project" })
		end
		if tpl.git or not core.executable("git") then
			return finish()
		end
		core.run_chain({ { "git", "init", "--quiet" } }, dir, "New project", finish)
	end)
end

---Templates whose tool is on $PATH.
---@return Template[]
function M.templates() -- This util is used by new_project below
	return vim.tbl_filter(function(tpl)
		return not tpl.needs or core.executable(tpl.needs)
	end, TEMPLATES)
end

---Asks for a template, then for the folder (prefilled with vim.g.projects_dir), and creates the project. An existing
---folder that is not empty is refused, so nothing is overwritten.
---@param tpl_name? string template name, skipping the first question
---@param path? string project folder, skipping the second question
function M.new_project(tpl_name, path) -- This util is used by new-project.lua
	local function with_template(tpl)
		if not tpl then
			return
		end
		local function with_path(input)
			input = vim.trim(input or "")
			if input == "" then
				return
			end
			local dir = vim.fs.normalize(fn.fnamemodify(fn.expand(input), ":p")):gsub("/$", "")
			if vim.fs.basename(dir):find("%s") then
				return core.warn("A project name cannot hold spaces: make, cargo and npm reject them.", "New project")
			elseif vim.uv.fs_stat(dir) and next(fn.readdir(dir)) ~= nil then
				return core.warn(dir .. " already exists and is not empty.", "New project")
			end
			create(tpl, dir)
		end
		if path then
			return with_path(path)
		end
		local base = vim.fs.normalize(vim.g.projects_dir or "~/Coding")
		vim.ui.input({ prompt = tpl.name .. " in: ", default = base .. "/", completion = "dir" }, with_path)
	end
	local list = M.templates()
	if tpl_name then
		return with_template(vim.iter(list):find(function(tpl)
			return tpl.name:lower():find(tpl_name:lower(), 1, true) ~= nil
		end))
	end
	vim.ui.select(list, {
		prompt = "New project",
		format_item = function(tpl)
			return tpl.name
		end,
	}, with_template)
end

return M
