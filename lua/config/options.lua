-- Core `vim.opt`/`vim.g` settings. Companion files: autocmds.lua (behavior that reacts to
-- these settings rather than being a static option), mappings.lua (keymaps). Change history
-- and the reasoning behind why a setting exists in its *current* form lives in
-- AUDIT_SUMMARY.md — this file only carries comments that explain what a setting does today.
local utils = require("utils")

local g = vim.g
local opt = vim.opt

-- ─────────────────────────────────────────────────────────────────────────────
--  Global Variables
-- ─────────────────────────────────────────────────────────────────────────────
g.mapleader = " " -- Set the leader key to Space
g.maplocalleader = ";" -- Set the local leader key to semicolon
g.have_nerd_font = true -- Tell plugins that a Nerd Font is installed (for icons)
g.markdown_recommended_style = 0 -- Disable default markdown recommended style
g.yaml_indent_multiline_scalar = 1 -- Fix YAML indentation for multiline strings
g.no_gitrebase_maps = 1 -- Disable default mappings for git rebase
g.no_man_maps = 1 -- Disable default mappings for man pages

-- ─────────────────────────────────────────────────────────────────────────────
--  Providers
--  Disabling unused providers speeds up startup time significantly
-- ─────────────────────────────────────────────────────────────────────────────
g.loaded_perl_provider = 0 -- Disable Perl provider
g.loaded_ruby_provider = 0 -- Disable Ruby provider
g.loaded_node_provider = 0 -- Disable Node.js provider
g.loaded_python3_provider = 0 -- Disable Python 3 provider
g.loaded_netrw = 1 -- Disable the built-in netrw file explorer
g.loaded_netrwPlugin = 1 -- Disable the netrw plugin script

-- ─────────────────────────────────────────────────────────────────────────────
--  General Settings
-- ─────────────────────────────────────────────────────────────────────────────
-- Only sync with the system clipboard if a valid provider is available
if vim.fn["provider#clipboard#Executable"]() ~= "" then
	opt.clipboard:append("unnamedplus")
end

opt.mouse = "n" -- Enable mouse support in Normal mode only (use "a" for all modes)
opt.hidden = true -- Allow switching buffers without saving them first
opt.confirm = true -- Prompt to save changes before exiting a modified buffer

-- Use nushell as the interactive/terminal shell — but only if it's actually installed, and
-- only "nu" (see header note above for why this used to silently break every terminal).
if utils.executable("nu") then
	opt.shell = "nu"
	-- nushell isn't POSIX, and Nvim's 'shell' help section says non-POSIX shells need
	-- shellcmdflag/shellredir/shellpipe/etc. adjusted, or `:!`, `:grep` (grepprg below), and
	-- any string-form system()/jobstart() call can misbehave or hang. Values below are
	-- nushell's own recommended integration settings (nushell/integrations repo, also
	-- documented at kiils.dk/en/blog/2024-06-22-using-nushell-in-neovim).
	opt.shellcmdflag = "--login --stdin --no-newline -c"
	opt.shellredir = "out+err> %s"
	opt.shellpipe = "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"
	opt.shellquote = ""
	opt.shellxquote = ""
	opt.shellxescape = ""
	opt.shelltemp = false
end

-- shada (was "viminfo" — same option, current Nvim docs use "shada"): default is roughly
-- "!,'100,<50,s10,h" (persist uppercase globals, remember marks for 100 files, cap registers
-- at 50 lines/10KB, reset hlsearch on startup). Kept those defaults, only bumped the file-mark
-- count to 1000.
opt.shada = "!,'1000,<50,s10,h"
opt.secure = true -- Prevents shell/write commands in modelines and prevents autocmds from untrusted files
opt.modelines = 0 -- Disable modelines to prevent files from overriding editor settings
opt.iskeyword:append("-") -- Treat dash-separated words as a single keyword (e.g. kebab-case)
opt.runtimepath:remove("/usr/share/vim/vimfiles") -- Exclude system Vim files from the runtime path
opt.nrformats:append("alpha") -- Cycle through letters too to increment values

-- ─────────────────────────────────────────────────────────────────────────────
--  Encoding and Spelling
-- ─────────────────────────────────────────────────────────────────────────────
opt.encoding = "utf-8" -- Internal encoding used by Neovim
opt.fileencoding = "utf-8" -- Encoding written to file on save
opt.fileencodings = { -- Encoding detection order when reading files
	"ucs-bom",
	"utf-8",
	"cp936",
	"gb18030",
	"big5",
	"euc-jp",
	"euc-kr",
	"latin1",
}
opt.spelllang = { "en", "cjk" } -- Enable spell checking for English and CJK characters
opt.spellsuggest:append("9") -- Show at most 9 spelling suggestions to keep menus concise
opt.spelloptions:append("camel") -- Treat camelCase words as separate words for spell checking

-- ─────────────────────────────────────────────────────────────────────────────
--  File Handling
-- ─────────────────────────────────────────────────────────────────────────────
opt.autoread = true -- Automatically reload files that have been changed outside of Neovim
opt.autowrite = true -- Automatically write changes when switching buffers or running commands
opt.history = 500 -- Number of command and search history entries to retain
opt.startofline = false -- Keep the cursor in the same column when jumping (e.g. gg, G, Ctrl-D)
opt.fileformats = { "unix", "dos" } -- Prefer Unix line endings; also recognise DOS (CRLF)
opt.isfname:remove({ "=", "," }) -- Exclude '=' and ',' from characters valid in file names

-- ─────────────────────────────────────────────────────────────────────────────
--  Timing and Performance
-- ─────────────────────────────────────────────────────────────────────────────
opt.timeoutlen = 500 -- Milliseconds to wait for a mapped key sequence to complete
opt.ttimeoutlen = 0 -- Milliseconds to wait for a terminal key code sequence (instant)
opt.updatetime = 100 -- Milliseconds of inactivity before writing the swap file and triggering CursorHold
opt.redrawtime = 1500 -- Maximum time (ms) allowed for syntax highlighting per redraw
opt.synmaxcol = 240 -- Only highlight syntax up to column 240 (improves performance on long lines)

-- ─────────────────────────────────────────────────────────────────────────────
--  UI and Display
-- ─────────────────────────────────────────────────────────────────────────────
-- Cursor shapes: block in normal/visual/command, bar in insert, underline in replace
opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor2/lCursor2,r-cr:hor20,o:hor20"
opt.termguicolors = true -- Enable 24-bit RGB colour in the terminal UI
opt.title = true -- Set the terminal window title to the current file
opt.titlestring = "%{v:lua.require('utils').get_current_branch_name()} • %<%F %=%l/%L" -- Custom window title format: filepath and line/total

opt.showmode = false -- Hide the mode indicator (e.g. -- INSERT --); the statusline handles this
opt.laststatus = 3 -- Use a single global statusline shared across all windows
opt.showtabline = 2 -- Always show the tabline, even when only one tab is open
opt.tabclose:append({ "uselast" }) -- Jump to the last accessed tab when a tab is closed
opt.ruler = false -- Hide the cursor position ruler (redundant with a statusline plugin)
opt.showcmd = false -- Do not show partial commands in the last line of the screen
opt.cmdheight = 0 -- Collapse the command line when not in use (maximises editing space)
opt.showcmdloc = "statusline" -- Display partial commands in the statusline instead of the command line
opt.shortmess:append("sI") -- Suppress the startup/intro messages
opt.shortmess:append("c") -- Suppress insert-completion-menu messages (e.g. "match 1 of 2")
opt.shortmess:append("S") -- Suppress "[x/y]" match count during search

opt.errorbells = false -- Disable the error bell sound
opt.visualbell = false -- Disable the visual flash bell
opt.pumblend = 5 -- Pseudo-transparency for the popup completion menu (0 = opaque, 100 = invisible)
opt.winblend = 0 -- Pseudo-transparency for floating windows
opt.winborder = "rounded" -- Default border for floats that don't set their own (matches lazy.nvim/fzf-lua/neo-tree/LSP floats)
opt.emoji = false -- Prevent Neovim from assuming emoji are double-width (fixes alignment)

opt.smoothscroll = true -- Enable smooth scrolling with <C-d>/<C-u>
opt.mousemodel = "popup" -- Right-click opens a popup menu instead of extending visual selection — see autocmds.lua's MenuPopup entry for what's in it
opt.mousescroll = { "ver:3", "hor:3" } -- Mouse wheel scrolls 1 line vertically and 0 horizontally
opt.messagesopt = "hit-enter,history:500" -- Show hit-enter prompt for long messages; keep 500 in history

-- Characters used to draw window borders, separators, and fold indicators
opt.fillchars = {
	stl = " ", -- Fill character for the active statusline
	msgsep = "‾", -- Separator between the message area and the editor
	foldopen = "󰅀", -- Icon shown for an open fold
	foldclose = "󰅂", -- Icon shown for a closed fold
	fold = " ", -- Padding after a closed fold's own summary line (not the fold *column*) — blank so nvim-ufo's virtual-text summary isn't followed by a row of dots
	foldsep = " ", -- Fill character between fold levels in the fold column
	diff = "╱", -- Fill character for deleted lines in diff mode
	eob = " ", -- Hide the '~' markers after the end of the buffer
	horiz = "━", -- Horizontal window separator
	horizup = "┻", -- Horizontal separator with upward junction
	horizdown = "┳", -- Horizontal separator with downward junction
	vert = "┃", -- Vertical window separator
	vertleft = "┫", -- Vertical separator with left junction
	vertright = "┣", -- Vertical separator with right junction
	verthoriz = "╋", -- Crossroad junction for window separators
}

-- ─────────────────────────────────────────────────────────────────────────────
--  Windows and Splits
-- ─────────────────────────────────────────────────────────────────────────────
opt.splitbelow = true -- Open horizontal splits below the current window
opt.splitright = true -- Open vertical splits to the right of the current window
opt.splitkeep = "screen" -- Keep the same text visible on screen when splitting
opt.winminheight = 1 -- Minimum height for non-active windows
opt.winheight = 1 -- Minimum height for the active window
opt.winwidth = 30 -- Minimum width for the active window
opt.winminwidth = 0 -- Minimum width for non-active windows (allows them to collapse fully)
opt.helpheight = 0 -- Open help windows at a minimal height (resizes on demand)

-- ─────────────────────────────────────────────────────────────────────────────
--  Cursor and Line Numbers
-- ─────────────────────────────────────────────────────────────────────────────
opt.number = true -- Show absolute line numbers
opt.relativenumber = true -- Show relative line numbers for easy vertical motion
opt.numberwidth = 2 -- Width of the line number column (default is 4)
opt.signcolumn = "yes:1" -- Always show the sign column to prevent the text from jumping
opt.cursorline = true -- Highlight the line the cursor is on
opt.cursorlineopt = "number" -- Only highlight the line number, not the entire line
opt.cursorcolumn = false -- Do not highlight the column the cursor is in
opt.scrolloff = 15 -- Keep at least 15 lines visible above and below the cursor

-- statuscolumn itself is built by statuscol.lua (number + sign + fold segments); this file
-- only owns the prerequisite settings below (foldcolumn width, numberwidth, signcolumn).

-- ─────────────────────────────────────────────────────────────────────────────
--  Indentation
-- ─────────────────────────────────────────────────────────────────────────────
opt.expandtab = true -- Insert spaces when pressing Tab
opt.shiftwidth = 2 -- Number of spaces used for each level of (auto-)indentation
opt.tabstop = 2 -- Number of spaces a Tab character visually represents
opt.softtabstop = 2 -- Number of spaces a Tab inserts/removes during editing
opt.autoindent = true -- Copy indent from the current line when starting a new line
opt.smartindent = true -- Insert extra indent level after opening braces, keywords, etc.
opt.smarttab = true -- Use shiftwidth for Tab at the start of a line, tabstop elsewhere

-- ─────────────────────────────────────────────────────────────────────────────
--  Text Formatting and Wrapping
-- ─────────────────────────────────────────────────────────────────────────────
opt.formatoptions:remove({ "c", "r", "o", "t" }) -- Don't auto-insert comment leaders on Enter or 'o'/'O'
opt.formatoptions:append("mM") -- Correctly break lines at multi-byte characters (useful for CJK text)
opt.textwidth = 100 -- Hard-wrap lines at 100 characters when formatting with gq
opt.colorcolumn = "+0" -- Highlight the column at 'textwidth' as a visual guide
opt.wrap = false -- Do not visually wrap long lines (scroll horizontally instead)
opt.whichwrap:append("<>[]hl") -- Allow these keys to move across line boundaries
opt.breakindent = true -- Preserve indentation visually when lines are wrapped
opt.breakindentopt = "shift:2" -- Indent wrapped continuations by 2 extra spaces
opt.showbreak = "󱞩 " -- Prefix shown at the start of each wrapped line segment
opt.backspace = "indent,eol,start" -- Allow Backspace over indentation, line breaks, and insert-mode start
opt.linebreak = true -- Wrap long lines at word boundaries rather than mid-word
opt.shiftround = true -- Round indentation to the nearest multiple of 'shiftwidth'
opt.virtualedit = "block" -- Allow the cursor to move freely within a visual block selection
opt.tildeop = true -- Make '~' act as an operator so 'g~w' toggles case of a word
opt.matchpairs:append({ "<:>", "「:」", "『:』", "【:】", '":"', "':'", "《:》" }) -- Extend % to match these bracket pairs

-- ─────────────────────────────────────────────────────────────────────────────
--  Search
-- ─────────────────────────────────────────────────────────────────────────────
opt.ignorecase = true -- Case-insensitive search by default
opt.smartcase = true -- Switch to case-sensitive search when the pattern contains uppercase
opt.infercase = true -- Adjust completion case to match what has been typed so far
opt.hlsearch = true -- Highlight all matches for the current search pattern
opt.showmatch = true -- Briefly jump to the matching bracket when inserting one
opt.inccommand = "split" -- Preview :substitute replacements live in a split window
opt.incsearch = true -- Show the first match incrementally as you type the search pattern
opt.path:append("**") -- Make :find search recursively through all subdirectories
opt.gdefault = true -- Make :s/foo/bar/ behave like :s/foo/bar/g by default — avoids typing /g every time.

-- Use ripgrep as the grep backend if it is available
if utils.executable("rg") then
	opt.grepprg = "rg --vimgrep --no-heading --smart-case"
	opt.grepformat = "%f:%l:%c:%m"
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Completion
-- ─────────────────────────────────────────────────────────────────────────────
opt.pumheight = 10 -- Maximum number of items shown in the popup completion menu
opt.completeopt = "menu,menuone" -- Show a menu even for a single match; no auto-selection
opt.complete:append("kspell") -- Include spelling suggestions in insert-mode completion
opt.complete:remove({ "w", "b", "u", "t" }) -- Remove other-window buffers, unlisted buffers, and tags (reduce noise)
opt.completeopt:remove("preview") -- Disable the scratch preview window for completions

opt.wildmenu = true -- Enable the enhanced command-line completion menu
opt.wildmode = "list:longest,list:full" -- First complete to the longest common string, then cycle through all matches
opt.wildignorecase = true -- Ignore case when completing file names and paths
opt.wildignore:append(".,..") -- Ignore current and parent directory entries
opt.wildignore:append("*/node_modules/*") -- Node.js dependencies
opt.wildignore:append("*/.git/*") -- Git repository directory
opt.wildignore:append("*/dist/*") -- Build output directory
opt.wildignore:append(".git,.hg,.svn") -- Version control directories
opt.wildignore:append(".aux,*.out,*.toc") -- LaTeX auxiliary files
opt.wildignore:append(".o,*.obj,*.exe,*.dll,*.manifest,*.rbc,*.class") -- Compiled binaries and objects
opt.wildignore:append(".ai,*.bmp,*.gif,*.ico,*.jpg,*.jpeg,*.png,*.psd,*.webp") -- Images
opt.wildignore:append(".avi,*.divx,*.mp4,*.webm,*.mov,*.m2ts,*.mkv,*.vob,*.mpg,*.mpeg") -- Videos
opt.wildignore:append(".mp3,*.oga,*.ogg,*.wav,*.flac") -- Audio files
opt.wildignore:append(".eot,*.otf,*.ttf,*.woff") -- Font files
opt.wildignore:append(".doc,*.pdf,*.cbr,*.cbz") -- Document and ebook files
opt.wildignore:append(".zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz,*.kgb") -- Archives
opt.wildignore:append(".swp,.lock,.DS_Store,._*") -- Editor swap files and macOS metadata
opt.wildignore:append("*/__pycache__/*,*.pyc,*.pkl") -- Python bytecode and cache
opt.wildignore:append("*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz,*.xdv") -- LaTeX build artifacts
opt.wildignore:append({ "*.dylib", "*.bin", "*/build/**", "*.tiff", "*.svg" }) -- Misc binaries and assets

-- ─────────────────────────────────────────────────────────────────────────────
--  Backup, Undo, and Swap
-- ─────────────────────────────────────────────────────────────────────────────
g.backupdir = vim.fn.stdpath("data") .. "/backup//" -- Global var used to share backup path below

opt.backup = true -- Keep a backup copy of files before overwriting
opt.backupcopy = "yes" -- Overwrite the original backup file on each save (preserves inode)
opt.backupdir = vim.g.backupdir -- Directory where backup files are stored
opt.backupskip = vim.o.wildignore -- Skip backing up files that match the wildignore patterns
opt.backupskip:append({ "/tmp/*", "/private/tmp/*" })

opt.undofile = true -- Persist undo history across sessions
opt.undodir = vim.fn.stdpath("data") .. "/undo" -- Directory for persistent undo files

opt.swapfile = false -- Disable swap files (rely on undo + backup instead)
opt.writebackup = false -- Disable the temporary pre-write backup (not needed with backup=true)

opt.sessionoptions:remove({ "blank", "buffers", "terminal" }) -- Exclude empty windows, buffers, and terminals from sessions

-- ─────────────────────────────────────────────────────────────────────────────
--  Folding
-- ─────────────────────────────────────────────────────────────────────────────
-- foldmethod is intentionally left unset (stays at Nvim's own default, "manual") — nvim-ufo
-- (ufo.lua) manages folding itself and expects to own it; the settings below are just the
-- prerequisites it needs (high foldlevel/foldlevelstart, a narrow foldcolumn).
opt.foldlevel = 99 -- Open all folds when first entering a buffer
opt.foldlevelstart = 99 -- Start every new buffer with all folds fully open
opt.foldnestmax = 4 -- Limit fold nesting to 4 levels deep
-- "auto:4": sized dynamically up to 4 columns, matching foldnestmax above. statuscol.nvim's
-- foldfunc (statuscol.lua) renders `min(fold_level, width)` columns, one glyph per nesting
-- level — with width stuck at "1" nesting can never be shown at all, however deep the actual
-- folds go (confirmed by reading statuscol's builtin.foldfunc source directly: `range =
-- level < width and level or width`). "auto" keeps the column at 1 wide on lines/buffers with
-- no real nesting, so this doesn't cost horizontal space when there's nothing to show.
opt.foldcolumn = "auto:4"
opt.foldtext = "" -- Draw closed folds via the extmark path instead of the old foldtext() string — required for nvim-ufo's virtual-text summaries and snacks.indent's guides to render correctly across a closed fold's line

-- ─────────────────────────────────────────────────────────────────────────────
--  Invisibles and Special Characters
-- ─────────────────────────────────────────────────────────────────────────────
opt.list = true -- Show invisible characters defined in 'listchars'
opt.listchars = { -- Visual representation of invisible characters
	tab = "  ", -- Tabs are shown as two spaces (intentionally invisible)
	extends = "󰄾", -- Indicator when a line extends beyond the right edge
	precedes = "󰄽", -- Indicator when a line extends beyond the left edge
	conceal = "󰈉", -- Replacement character for concealed text
	trail = "·", -- Middle-dot for trailing whitespace
	nbsp = "󱁐", -- Visible marker for non-breaking spaces
}
opt.conceallevel = 2 -- Conceal marked text (e.g. hide URL syntax in Markdown links)
opt.concealcursor = "" -- Never conceal text on the cursor line (any mode)

-- ─────────────────────────────────────────────────────────────────────────────
--  Diff
-- ─────────────────────────────────────────────────────────────────────────────
-- Enable terminal undercurl and colour for diff/spell highlights
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

opt.diffopt:append({
	"internal", -- Use Neovim's built-in diff library
	"indent-heuristic", -- Use heuristics to reduce indentation-only diff noise
	"algorithm:histogram", -- Histogram algorithm produces cleaner, more readable diffs
	"context:3", -- Show 3 lines of context around each change
	"vertical", -- Always show diffs side-by-side in vertical splits
	"filler", -- Insert filler lines to keep both sides aligned on deleted lines
	"closeoff", -- Automatically turn off diff mode when one of the diff windows is closed
})

-- Character-level inline diff (Neovim 0.12+) or line-matching fallback
if vim.fn.has("nvim-0.12") == 1 then
	opt.diffopt:append("inline:char") -- Highlight individual changed characters within a line
else
	opt.diffopt:append("linematch:60") -- Match lines within a 60-line window for cleaner diffs
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Filetypes
--  Teach Neovim how to detect filetypes for non-standard file names and patterns
-- ─────────────────────────────────────────────────────────────────────────────
vim.filetype.add({
	extension = {
		mdx = "mdx", -- MDX (Markdown + JSX) files
		["todo.txt"] = "todotxt", -- todo.txt format
		["yarn.lock"] = "yaml", -- Yarn lockfile (structured as YAML)
		["helmfile.yaml"] = "yaml", -- Helm chart values file
		["buckconfig"] = "toml", -- Buck build system config
		["flowconfig"] = "ini", -- Flow type checker config
	},
	filename = {
		Brewfile = "ruby", -- Homebrew bundle file
		justfile = "just", -- just task runner (lowercase)
		Justfile = "just", -- just task runner (capitalised)
		Jenkinsfile = "groovy", -- Jenkins pipeline definition
		[".buckconfig"] = "toml", -- Buck build system config (dotfile variant)
		[".flowconfig"] = "ini", -- Flow type checker config (dotfile variant)
		[".jsbeautifyrc"] = "json", -- js-beautify formatter config
		[".jscsrc"] = "json", -- JSCS linter config
		[".watchmanconfig"] = "json", -- Watchman file watcher config
	},
	pattern = {
		["%.config/git/users/.*"] = "gitconfig", -- Per-user git config files
		["%.kube/config"] = "yaml", -- Kubernetes kubeconfig
		[".*%.js%.map"] = "json", -- JavaScript source maps
		[".*%.postman_collection"] = "json", -- Postman collection exports
		["Jenkinsfile.*"] = "groovy", -- Jenkinsfile variants (e.g. Jenkinsfile.prod)
		[".*%.rc"] = "json", -- Generic .rc configuration files
	},
})
-- (mdx is registered as a treesitter dialect of markdown in treesitter.lua's config function,
-- not here — it has to run after treesitter itself loads.)

-- ─────────────────────────────────────────────────────────────────────────────
--  Sudo Safety
--  Disable file-mutation options when Neovim is launched via sudo to avoid
--  accidentally writing root-owned files into the wrong user's directories.
-- ─────────────────────────────────────────────────────────────────────────────
local USER = vim.env.USER or ""
local SUDO_USER = vim.env.SUDO_USER or ""
if
	SUDO_USER ~= ""
	and USER ~= SUDO_USER
	and vim.env.HOME ~= vim.fn.expand("~" .. USER, true)
	and vim.env.HOME == vim.fn.expand("~" .. SUDO_USER, true)
then
	vim.opt_global.modeline = false -- Disable modeline (security risk when running as root)
	vim.opt_global.undofile = false -- Do not persist undo history when running as sudo
	vim.opt_global.swapfile = false -- Do not create swap files when running as sudo
	vim.opt_global.backup = false -- Do not create backup files when running as sudo
	vim.opt_global.writebackup = false -- Do not write a pre-save backup when running as sudo
	vim.opt_global.shadafile = "NONE" -- Do not read or write the shada file when running as sudo
end
