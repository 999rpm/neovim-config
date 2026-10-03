-- Editor options. Leader is Space, local leader is backslash. vim.g.notes_dir points the notes layer at a Logseq-style
-- graph folder, vim.g.projects_dir the new-project wizard at the projects folder. 'shell' follows the login shell from
-- the passwd database; nushell gets its own shell* flags (utils/shell.lua). The Python 3 provider runs only when
-- :JupyterSetup's environment exists (molten.lua needs it).
local core = require("utils.core")
local shell = require("utils.shell")
local jupyter_python = require("utils.jupyter").python()

local g = vim.g
local opt = vim.opt

g.mapleader = " "
g.maplocalleader = "\\" -- markdown, review, grug-far and Octo buffers keep their keys on it
g.have_nerd_font = true -- plugins that check it draw icons
g.markdown_recommended_style = 0 -- the markdown ftplugin leaves indentation alone
g.yaml_indent_multiline_scalar = 1 -- indent continuation lines of a multi-line YAML string
g.notes_dir = vim.env.NOTES_DIR or "~/notes" -- notes graph (journals/, pages/, assets/); $NOTES_DIR overrides
g.projects_dir = vim.env.PROJECTS_DIR or "~/Coding" -- new projects go here (utils/project.lua); $PROJECTS_DIR overrides

g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
if vim.uv.fs_stat(jupyter_python) then
	g.python3_host_prog = jupyter_python -- :JupyterSetup's environment runs molten.lua's remote plugin
else
	g.loaded_python3_provider = 0 -- no environment yet, so no provider probe at startup; :JupyterSetup turns it on
end

vim.schedule(function() -- the clipboard provider probe runs after the first screen draws instead of delaying startup
	if vim.fn["provider#clipboard#Executable"]() ~= "" then
		opt.clipboard:append("unnamedplus")
	end
end)

opt.mouse = "n" -- normal mode only; "a" would extend it to every mode
opt.confirm = true -- ask before leaving a modified buffer instead of failing

opt.shell = shell.login_shell() -- login shell from the passwd database, so chsh applies without a new login
shell.apply_shell_options() -- nushell needs its own shell* flags; every other shell keeps Neovim's defaults

opt.shada = "!,'1000,<50,s10,h,r/tmp/,r/private/" -- marks for 1000 files (default 100); the rest is the default
opt.exrc = true -- a project's .nvim.lua runs at startup once :trust approves it; :trust is the guard, Neovim has no 'secure'
opt.modelines = 0 -- files cannot set options through modelines
opt.iskeyword:append("-") -- kebab-case counts as one word for w, * and completion

opt.spelllang = { "en", "cjk" } -- cjk: East Asian characters are not flagged
opt.spellsuggest:append("9") -- at most 9 suggestions in z=
opt.spelloptions:append("camel") -- camelCase parts are checked as separate words

opt.autowrite = true -- write before :make, :next and similar commands
opt.jumpoptions = "stack,view,clean" -- browser-style jump stack, saved views, no entries for unloaded buffers
opt.isfname:remove({ "=", "," }) -- gf stops at = and ,

opt.timeoutlen = 500 -- ms to finish a mapped key sequence
opt.ttimeoutlen = 0 -- ms to finish a terminal key code
opt.updatetime = 100 -- ms of idle time before CursorHold
opt.redrawtime = 1500 -- ms of syntax highlighting per redraw before it gives up
opt.synmaxcol = 240 -- regex syntax stops at column 240; treesitter highlighting ignores it

opt.termguicolors = true -- 0.12 applies detected truecolor only at VimEnter; colorizer reads it on the first BufReadPre
opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor2/lCursor2,r-cr:hor20,o:hor20" -- block, bar in insert, underline in replace
opt.title = true -- terminal title shows the branch and the file
opt.titlestring = "%{v:lua.require('utils.statusline').branch_name()} • %<%F %=%l/%L"

opt.showmode = false -- lualine shows the mode
opt.laststatus = 3 -- one global statusline
opt.showtabline = 2 -- barbar's tabline is always visible
opt.tabclose:append({ "uselast" }) -- closing a tab returns to the last used one
opt.ruler = false -- lualine shows the position
opt.showcmd = true -- pending count, register or operator (2d, "a) while it is typed
opt.cmdheight = 0 -- no command line until it is used; noice draws it
opt.showcmdloc = "statusline" -- lualine places %S, since the command line is hidden
opt.shortmess:append("sIc") -- no "search hit BOTTOM", no intro screen, no "match 1 of 2"

opt.pumblend = 5 -- popup menu transparency
opt.winblend = 0 -- floating windows stay opaque
opt.winborder = "rounded" -- border for floats that set none (LSP floats, lazy.nvim, blink)
opt.pumborder = "rounded" -- border for the built-in popup menu, used before blink loads

opt.smoothscroll = true -- scroll by screen line through wrapped lines
opt.mousemodel = "popup" -- right click opens the menu autocmds.lua builds
opt.mousescroll = { "ver:3", "hor:3" }

opt.fillchars = {
	stl = " ",
	msgsep = "‾",
	foldopen = "󰅀",
	foldclose = "󰅂",
	fold = " ", -- blank, so ufo's fold summary is not followed by dots
	foldsep = " ",
	diff = "╱", -- deleted lines in diff mode
	eob = " ", -- no ~ after the end of the buffer
	horiz = "━",
	horizup = "┻",
	horizdown = "┳",
	vert = "┃",
	vertleft = "┫",
	vertright = "┣",
	verthoriz = "╋",
}

opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen" -- the text stays in place when a split opens
opt.switchbuf = "useopen,uselast" -- quickfix, Trouble and :sbuffer jumps reuse a window already showing the buffer
opt.winminheight = 1
opt.winheight = 1
opt.winwidth = 30 -- the focused window is at least 30 columns wide
opt.winminwidth = 0 -- other windows may collapse completely
opt.helpheight = 0 -- :help splits take their usual half

opt.number = true
opt.relativenumber = true -- autocmds.lua's number_toggle turns it off in unfocused windows and insert mode
opt.numberwidth = 2
opt.signcolumn = "yes:1" -- always one column, so text never shifts when a sign appears
opt.cursorline = true
opt.cursorlineopt = "number" -- only the line number is highlighted
opt.scrolloff = 15 -- lines kept above and below the cursor
opt.sidescrolloff = 8 -- columns kept left and right; 'wrap' is off, so long lines scroll sideways

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true -- extra indent after an opening brace; filetypes with an 'indentexpr' ignore it

opt.formatoptions:remove({ "c", "r", "o", "t" }) -- no comment leader on <CR> or o/O, no auto-wrap
opt.formatoptions:append("mM") -- line breaks between multi-byte characters (CJK text)
opt.textwidth = 100 -- gq wraps here
opt.colorcolumn = "+0" -- guide at 'textwidth'
opt.wrap = false -- prose filetypes turn it on (autocmds.lua)
opt.whichwrap:append("<>[]hl") -- these keys cross line ends
opt.breakindent = true -- wrapped lines keep their indent
opt.breakindentopt = "shift:2"
opt.showbreak = "󱞩 "
opt.linebreak = true -- wrap at word boundaries
opt.shiftround = true -- > and < round to a multiple of 'shiftwidth'
opt.virtualedit = "block" -- blockwise visual can extend past line ends
opt.matchpairs:append({ "<:>", "「:」", "『:』", "【:】", "《:》" }) -- % on angle and CJK brackets; a pair needs two different characters

opt.ignorecase = true
opt.smartcase = true -- an uppercase letter makes the search case-sensitive
opt.infercase = true -- keyword completion adapts to the typed case
opt.showmatch = true -- a typed bracket briefly shows its partner
opt.inccommand = "split" -- :s previews every change in a split
opt.path:append("**") -- :find searches subdirectories

if core.executable("rg") then
	opt.grepprg = "rg --vimgrep --no-heading --smart-case" -- 0.12's own rg default passes -uu, which searches ignored and hidden files
	opt.grepformat = "%f:%l:%c:%m"
end

opt.pumheight = 10
opt.completeopt = "menu,menuone" -- built-in completion: menu for a single match too, nothing preselected
opt.complete:append("kspell") -- spelling suggestions in keyword completion
opt.complete:remove({ "w", "b", "u", "t" }) -- current buffer only: no other windows, unlisted buffers or tags

opt.wildmode = "list:longest,list:full" -- longest common part first, then every match
opt.wildignorecase = true
opt.wildignore:append(".,..")
opt.wildignore:append("*/node_modules/*,*/.git/*,*/dist/*,.git,.hg,.svn")
opt.wildignore:append("*.aux,*.out,*.toc,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz,*.xdv") -- LaTeX
opt.wildignore:append("*.o,*.obj,*.exe,*.dll,*.manifest,*.rbc,*.class,*.dylib,*.bin") -- compiled files
opt.wildignore:append("*.ai,*.bmp,*.gif,*.ico,*.jpg,*.jpeg,*.png,*.psd,*.webp,*.tiff,*.svg") -- images
opt.wildignore:append("*.avi,*.divx,*.mp4,*.webm,*.mov,*.m2ts,*.mkv,*.vob,*.mpg,*.mpeg") -- video
opt.wildignore:append("*.mp3,*.oga,*.ogg,*.wav,*.flac") -- audio
opt.wildignore:append("*.eot,*.otf,*.ttf,*.woff,*.woff2") -- fonts
opt.wildignore:append("*.doc,*.pdf,*.cbr,*.cbz") -- documents
opt.wildignore:append("*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz,*.kgb") -- archives
opt.wildignore:append("*.swp,*.lock,.DS_Store,._*") -- swap files, lockfiles, macOS metadata
opt.wildignore:append("*/__pycache__/*,*.pyc,*.pkl,*/build/**") -- Python caches, build output

local backup_dir = vim.fn.stdpath("data") .. "/backup//"
core.may_create_dir(backup_dir) -- Neovim does not create 'backupdir'; without it no backup is written

opt.backup = true -- keep the previous version of a file
opt.backupcopy = "yes" -- copy, then overwrite the original, so its inode survives
opt.backupdir = backup_dir
opt.backupskip:append(opt.wildignore:get()) -- no backups of files 'wildignore' hides; the default temp-folder patterns stay
opt.backupskip:append({ "*/shm/*", "/private/tmp/*", "/private/var/*", "*.tmp", "*.bak", "COMMIT_EDITMSG", "MERGE_MSG" }) -- RAM disks, macOS temp, transient files

opt.undofile = true -- undo history survives a restart
opt.undolevels = 10000 -- 0.12 keeps 1000
opt.undodir = vim.fn.stdpath("data") .. "/undo" -- created on the first write

opt.swapfile = false -- undo files and backups cover recovery
opt.writebackup = false -- 'backup' already keeps the old version

opt.sessionoptions:remove({ "blank", "buffers", "terminal" }) -- sessions keep no empty windows, hidden buffers or terminals
opt.sessionoptions:append("globals") -- barbar.lua's buffer order and pins; persistence.lua fires SessionSavePre first

opt.foldlevel = 99 -- folds start open
opt.foldlevelstart = 99
opt.foldcolumn = "1" -- statuscol draws one glyph per fold start, whatever the depth
opt.foldtext = "" -- closed folds keep their highlighted text; ufo adds its line count

opt.list = true
opt.listchars = {
	tab = "  ", -- tabs stay invisible
	extends = "󰄾",
	precedes = "󰄽",
	conceal = "󰈉",
	trail = "·",
	nbsp = "󱁐",
}
opt.conceallevel = 2 -- render-markdown.lua sets markdown's own level
opt.concealcursor = "" -- the cursor line always shows the raw text

opt.diffopt = { -- assigned whole: 0.12 already carries linematch:40, and appending a second linematch left both
	"internal",
	"filler",
	"closeoff",
	"indent-heuristic",
	"algorithm:histogram",
	"context:3",
	"vertical",
	"inline:char", -- changed characters inside a changed line
	"linematch:60", -- aligns similar lines in hunks up to 60 lines
}

vim.filetype.add({
	extension = {
		mdx = "mdx",
		d2 = function()
			return "d2", function(buf)
				vim.bo[buf].commentstring = "# %s"
			end
		end, -- 0.12 detects neither the filetype nor its comment leader
		ipynb = function(_, buf)
			return vim.b[buf]._999rpm_notebook and "markdown" or "json"
		end, -- notebooks open as jupytext markdown (notebook/ipynb.lua), as JSON when the conversion fails
	},
	filename = { -- names 0.12.5 does not detect on its own
		buckconfig = "toml",
		flowconfig = "ini",
		[".buckconfig"] = "toml",
		[".flowconfig"] = "ini",
		[".jsbeautifyrc"] = "json",
		[".watchmanconfig"] = "json",
	},
	pattern = {
		["%.config/git/users/.*"] = "gitconfig",
		[".*%.js%.map"] = "json", -- source maps; 0.12.5 reads *.map as MapServer files
		[".*%.postman_collection"] = "json",
		["Jenkinsfile.*"] = "groovy", -- Jenkinsfile itself is detected; its variants are not
	},
})

local USER = vim.env.USER or ""
local SUDO_USER = vim.env.SUDO_USER or ""
if
	SUDO_USER ~= ""
	and USER ~= SUDO_USER
	and vim.env.HOME ~= vim.fn.expand("~" .. USER, true)
	and vim.env.HOME == vim.fn.expand("~" .. SUDO_USER, true)
then -- sudo with the invoking user's $HOME: nothing persists into that home
	vim.opt_global.modeline = false
	vim.opt_global.undofile = false
	vim.opt_global.swapfile = false
	vim.opt_global.backup = false
	vim.opt_global.writebackup = false
	vim.opt_global.shadafile = "NONE"
end
