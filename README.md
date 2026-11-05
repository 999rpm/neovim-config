# 999rpm's Neovim config

Personal Neovim configuration for Neovim 0.12 and later, managed by [lazy.nvim](https://github.com/folke/lazy.nvim).
One plugin per file, almost all of them lazy-loaded. Besides code editing it covers three extra jobs: a Logseq-style
notes graph on plain markdown, Jupyter notebooks that run against real kernels, and Visual Studio-style projects that are
created from templates, opened from a list and built as tasks.

Written for Neovim 0.12.6 on Linux, with kitty as the terminal, zsh or nushell as the login shell, and tmux optional.
It also runs on macOS and Windows, and in [Neovide](https://neovide.dev) as a GUI.

## Features

- Language servers through Neovim's own `vim.lsp`, installed by [mason.nvim](https://github.com/mason-org/mason.nvim);
  Rust through [rustaceanvim](https://github.com/mrcjkb/rustaceanvim)
- Completion with [blink.cmp](https://github.com/saghen/blink.cmp), inline suggestions from
  [copilot.lua](https://github.com/zbirenbaum/copilot.lua)
- Formatting with [conform.nvim](https://github.com/stevearc/conform.nvim), linting with
  [nvim-lint](https://github.com/mfussenegger/nvim-lint)
- Pickers, terminals, notifications, dashboard and images from [snacks.nvim](https://github.com/folke/snacks.nvim)
- Treesitter highlighting, text objects and context through
  [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (main branch)
- Git: [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [codediff.nvim](https://github.com/esmuellert/codediff.nvim),
  [octo.nvim](https://github.com/pwntester/octo.nvim), lazygit
- Debugging with [nvim-dap](https://github.com/mfussenegger/nvim-dap), tests with
  [neotest](https://github.com/nvim-neotest/neotest) (jest, pytest, cargo)
- File explorers: [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim), [oil.nvim](https://github.com/stevearc/oil.nvim),
  [yazi.nvim](https://github.com/mikavilpas/yazi.nvim)
- Dependency versions inline for `Cargo.toml` ([crates.nvim](https://github.com/saecki/crates.nvim)) and `package.json`
  ([package-info.nvim](https://github.com/vuki656/package-info.nvim)); root-owned files written with `:SudaWrite`
  ([vim-suda](https://github.com/lambdalisue/vim-suda))
- [d2](https://d2lang.com) diagrams in `.d2` files and in markdown blocks, highlighted through nvim-treesitter and drawn
  by the d2 binary as an image (`<leader>ud`) or as text (`<leader>uD`)
- Notes graph: journals, pages, `[[links]]`, backlinks, tasks, agenda and templates on top of
  [markdown-oxide](https://github.com/Feel-ix-343/markdown-oxide), drawn by
  [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
- Jupyter notebooks through [molten-nvim](https://github.com/benlubas/molten-nvim) and
  [otter.nvim](https://github.com/jmbuhr/otter.nvim): `.ipynb` files open as markdown, the code cells get diagnostics,
  rename with a live preview and format on save, pandas DataFrames print as outlined tables, and cells are added, cut,
  split and joined with JupyterLab's letters
- Projects: a new-project wizard (C and C++ with a Makefile, Rust, Python through uv, JavaScript through npm), a project
  list from [snacks.nvim](https://github.com/folke/snacks.nvim), builds and tasks through
  [overseer.nvim](https://github.com/stevearc/overseer.nvim) (make, cargo, npm scripts, `.vscode/tasks.json`), and
  `<leader>cr` to build and run the project or the current file
- AI: [avante.nvim](https://github.com/avante-corp/avante.nvim), [opencode.nvim](https://github.com/NickvanDyke/opencode.nvim),
  [mcphub.nvim](https://github.com/ravitemer/mcphub.nvim)
- Themes: tokyonight, catppuccin, kanagawa and monokai-pro, switched and remembered across restarts

## Requirements

- Neovim 0.12+ (tested on 0.12.6), git, a C compiler, `make`, curl, ripgrep, fd, a POSIX `sh` on `$PATH` (Linux and
  macOS) and a [Nerd Font](https://www.nerdfonts.com)
- The tree-sitter CLI for parser builds (Mason installs it)
- Node.js 22+ for Copilot and the JavaScript tooling; python3 or [uv](https://github.com/astral-sh/uv) for the Jupyter setup
- Optional: lazygit, yazi, `gh`, [d2](https://d2lang.com), ImageMagick, xxd, btop, npm
- kitty, or another terminal with the kitty graphics protocol, for images, math and notebook plots; tmux optional, with
  extended keys and passthrough on
- zsh or nushell as the login shell; both behave the same here
- macOS: kitty sends the Alt keys (`<M-j>`, `<M-h>` and the rest) only with `macos_option_as_alt left` in kitty.conf
- Windows: PowerShell for avante.nvim's build; 'shell' stays cmd.exe
- Optional GUI: Neovide 0.13 or later with Lilex Nerd Font installed (kitty.conf's font, size 11)

## Install

The archive holds one folder, `nvim`, with the whole config and the plugin lockfile it was tested with. Extracting it
replaces `~/.config/nvim` (`%LOCALAPPDATA%\nvim` on Windows; `:echo stdpath('config')` shows the folder), so the old
folder is backed up or removed first:

```sh
mv ~/.config/nvim ~/.config/nvim.bak
unzip nvim.zip -d ~/.config
nvim
```

The first start clones lazy.nvim (its `stable` branch) and every other plugin at the commits in `lazy-lock.json`, builds
the treesitter parsers and lets Mason install the servers, formatters and linters. `:checkhealth` reports anything
missing. `:JupyterSetup` builds the Python environment the notebooks use, and `:NotesInit` creates the notes folders.

## Layout

```
init.lua              entry point
lua/config/           options, autocommands, keymaps, lazy.nvim bootstrap, Neovide settings
lua/plugins/<group>/  one file per plugin: core, lsp, completion, treesitter, editor, ui, git,
                      explorer, debug, test, projects, lang, notes, notebook, ai, deps
lua/utils/            shared helpers by subject: core, shell, statusline, debugger, fences,
                      d2, notes, jupyter, notebook, run, project, themes
ipython/              the startup file Jupyter kernels run (outlined pandas tables)
after/queries/        markdown folds that keep a bullet with its children
snippets/             markdown snippets for the notes graph
```

## Plugins

One line per file under `lua/plugins/`; each file's header says more.

- core: tokyonight, catppuccin, kanagawa and monokai-pro colour schemes with the 999rpm-themer switcher;
  nvim-mini/mini.nvim (icons, text objects, alignment, pattern highlights); folke/snacks.nvim (picker, terminals,
  notifier, indent guides, dashboard, lazygit, images, toggles); folke/which-key.nvim (lists what follows a prefix)
- lsp: neovim/nvim-lspconfig (server definitions for `vim.lsp.enable`); mason-org/mason.nvim (installs servers, formatters,
  linters, debug adapters), with mason-org/mason-lspconfig.nvim and WhoIsSethDaniel/mason-tool-installer.nvim keeping
  their lists installed; mrcjkb/rustaceanvim (rust-analyzer with runnables and hover actions); smjonas/inc-rename.nvim
  (rename with a live preview); folke/lazydev.nvim (Neovim API completion in this config); Wansmer/symbol-usage.nvim
  (reference counts above functions)
- completion: saghen/blink.cmp (completion and signature help, also on the command line); zbirenbaum/copilot.lua
  (inline suggestions); windwp/nvim-autopairs (closes brackets and quotes)
- treesitter: nvim-treesitter/nvim-treesitter (parsers and highlighting); nvim-treesitter/nvim-treesitter-textobjects
  (select, swap and move by function, class, parameter); nvim-treesitter/nvim-treesitter-context (pins the enclosing
  function); m-demare/hlargs.nvim (parameters in their own colour); hiphish/rainbow-delimiters.nvim (brackets by depth);
  Wansmer/treesj (split or join a node); windwp/nvim-ts-autotag (HTML and JSX tags)
- editor: max397574/better-escape.nvim (jj/jk leave insert mode); gregorias/coerce.nvim (case conversion under `gA`);
  monaqa/dial.nvim (wider increment and decrement); folke/flash.nvim (jump by label); MagicDuck/grug-far.nvim (search and
  replace across files); nmac427/guess-indent.nvim (indentation from the file); m4xshen/hardtime.nvim (hints for faster
  motions); ThePrimeagen/harpoon (pinned files); RaafatTurki/hex.nvim (hex view); andymass/vim-matchup (`%` through
  treesitter); jake-stewart/multicursor.nvim (multiple cursors); danymat/neogen (docstrings); nacro90/numb.nvim (peek at
  `:42`); chrisgrieser/nvim-scissors (snippet editing); folke/persistence.nvim (sessions per folder and branch);
  lambdalisue/vim-suda (writes files that need root); kylechui/nvim-surround (surrounding pairs);
  folke/todo-comments.nvim (TODO highlights); folke/ts-comments.nvim (comment style per treesitter node)
- ui: romgrk/barbar.nvim (buffer tabline); nvim-lualine/lualine.nvim (statusline); folke/noice.nvim (command line,
  messages, LSP progress); kevinhwang91/nvim-bqf (quickfix preview, filters, marks); kevinhwang91/nvim-ufo (folds from
  LSP and treesitter); folke/trouble.nvim (diagnostics and symbol lists); Bekaboo/dropbar.nvim (breadcrumbs);
  lewis6991/satellite.nvim (scrollbar with marks); luukvbaal/statuscol.nvim (status column);
  rachartier/tiny-inline-diagnostic.nvim (inline diagnostics); nvim-zh/colorful-winsep.nvim (active window border,
  off in Neovide); catgoose/nvim-colorizer.lua (colour codes); mawkler/modicator.nvim (line number in the mode colour);
  stevearc/stickybuf.nvim (utility windows keep their buffer)
- git: lewis6991/gitsigns.nvim (signs, hunks, blame); esmuellert/codediff.nvim (review workspace);
  linrongbin16/gitlinker.nvim (permalinks); pwntester/octo.nvim (GitHub issues and pull requests)
- explorer: nvim-neo-tree/neo-tree.nvim (sidebar tree); stevearc/oil.nvim (edit a folder as a buffer);
  mikavilpas/yazi.nvim (the yazi file manager in a float)
- debug: mfussenegger/nvim-dap (debugger client); rcarriga/nvim-dap-ui (panels); mfussenegger/nvim-dap-python (Python
  configurations); theHamsta/nvim-dap-virtual-text (values inline)
- test: nvim-neotest/neotest (tests from the editor)
- projects: 999rpm-projects (new-project wizard and project picker); stevearc/overseer.nvim (builds and tasks)
- lang: stevearc/conform.nvim (format on save); mfussenegger/nvim-lint (linters); saecki/crates.nvim (Cargo.toml);
  vuki656/package-info.nvim (package.json versions); hat0uma/csvview.nvim (CSV and TSV as columns); 999rpm-d2 (d2
  diagrams); brianhuster/live-preview.nvim (browser preview); Kenzo-Wada/boundary.nvim (React server/client boundaries);
  axelvc/template-string.nvim (template literals); MaximilianLloyd/tw-values.nvim (CSS behind Tailwind classes)
- notes: 999rpm-notes (the Logseq-style graph); MeanderingProgrammer/render-markdown.nvim (rendered markdown);
  YousefHadder/markdown-plus.nvim (outliner lists); dominic-righthere/markdown-pipetable.nvim (pipe tables);
  DAmesberger/sc-im.nvim (tables in the sc-im spreadsheet); HakonHarnes/img-clip.nvim (pasted images);
  okuuva/auto-save.nvim (saves graph pages)
- notebook: 999rpm-ipynb (`.ipynb` through jupytext); benlubas/molten-nvim (Jupyter kernels); jmbuhr/otter.nvim (language
  servers inside code cells)
- ai: avante-corp/avante.nvim (Claude sidebar); NickvanDyke/opencode.nvim (opencode TUI); ravitemer/mcphub.nvim (MCP
  servers)
- deps (`deps/shared.lua`, loaded on first require): nvim-lua/plenary.nvim, MunifTanjim/nui.nvim, nvim-neotest/nvim-nio,
  kevinhwang91/promise-async, gregorias/coop.nvim, ColinKennedy/mega.cmdparse, ColinKennedy/mega.logging,
  b0o/schemastore.nvim, rafamadriz/friendly-snippets, nvim-neotest/neotest-jest, nvim-neotest/neotest-python,
  nvim-telescope/telescope-fzf-native.nvim

## Keys

Leader is `Space`, local leader is `\`. Press the leader and wait for which-key to list what follows, or `<leader>sk`
to search every mapping. Built-in keys keep their jobs, except the upgrades listed below.

| Prefix | Group | Prefix | Group |
| --- | --- | --- | --- |
| `<leader>f` | Find files | `<leader>s` | Search contents |
| `<leader>e` | Explorers | `<leader>b` | Buffers |
| `<leader>c` | Code | `<leader>l` | LSP lists |
| `<leader>d` | Diagnostics | `<leader>D` | Debug |
| `<leader>g` | Git | `<leader>G` | Review (codediff) |
| `<leader>t` | Terminals | `<leader>T` | Tests |
| `<leader>n` | Notes graph | `<leader>k` | Jupyter kernel and cells |
| `<leader>o` | Toggles | `<leader>u` | UI and themes |
| `<leader>h` | Harpoon | `<leader>m` | Multicursor |
| `<leader>r` | Replace across files | `<leader>y` | Yank and registers |
| `<leader>i` | AI | `<leader>q` | Sessions and quit |
| `<leader>p` | Plugins and tools | `<leader><Tab>` | Tabs |
| `<leader>w` | Projects and tasks | | |

Outside the leader: `<M-h>`/`<M-l>` previous/next buffer, `<M-w/a/s/d>` move between windows (normal mode), `<M-j>`/`<M-k>` move a
line (and scroll documentation and previews in completion menus and pickers), `<C-s>` write, `<C-,>` floating terminal,
`]e`/`[e` and `]w`/`[w` errors and warnings, `]r`/`[r` references. Multicursor adds cursors with `<C-Up>`/`<C-Down>` or
Ctrl+Alt+click; while cursors exist, `<leader>mh`/`<leader>ml` pick the main one and `<Esc>` clears them. The quickfix
list closes with `q`; help, man and checkhealth windows close with `:q` (help keeps `q` for macros, man and checkhealth
have their own `q`). The header of `lua/config/mappings.lua` lists the built-in keys worth knowing, and each plugin file
lists its own.

Inside Neovide (`lua/config/neovide.lua`): `<C-=>` and `<C-->` make the text larger and smaller, `<C-0>` resets it. On
macOS `<D-c>` copies the selection and `<D-v>` pastes in every mode. Elsewhere `<C-S-c>` copies and `<C-S-v>` pastes in
normal, visual and terminal mode; insert and command-line mode keep the built-in CTRL-SHIFT-V (the next key
literally), so `<C-r>+` pastes there.

## Built-in keys kept as upgrades

Each key still does its built-in job and falls back to it where the plugin cannot act.

| Key | Plugin or file | Added |
| --- | --- | --- |
| `n` `N` | mappings.lua | the match is centred and its fold opened |
| `<Esc>` | mappings.lua | the search highlight is cleared |
| `grn` | inc-rename.nvim | live preview of the rename |
| `gd` `gD` | lspconfig.lua | the server's definition and declaration where one is found |
| `]c` `[c` | gitsigns.nvim | git hunks outside diff mode, counts kept |
| `]m` `[m` `]M` `[M` | nvim-treesitter-textobjects | function starts and ends in any parsed language (normal and visual) |
| `zR` `zM` | nvim-ufo | open and close every fold from the fold provider |
| `<C-a>` `<C-x>` | dial.nvim | dates and true/false when one comes first from the cursor; numbers stay built-in |
| `%` `g%` `[%` `]%` | vim-matchup | word pairs such as `if`/`end` and HTML tags |
| `a` `i` text objects | mini.nvim (mini.ai) | more objects, and the next or last one with `aN`/`iN`, `al`/`il` |
| `K` | rustaceanvim | hover actions in Rust buffers |
| `gf` `<C-w>f` | logseq.lua | `[[links]]`, tags and block references in the notes graph |
| insert `<BS>` `<CR>` | nvim-autopairs | pair-aware delete and line break |
| `o` `O`, insert `<CR>` `<Tab>` `<S-Tab>` `<BS>` | markdown-plus.nvim | list items continue and indent in markdown |
| `<LeftMouse>` | satellite.nvim | dragging the scrollbar |
| insert `<Tab>` `<CR>` `<C-e>` `<C-k>` | blink.cmp | completion while its menu is open |
| insert `<C-l>` | copilot.lua | the grey suggestion while one shows; the popup menu keeps its `<C-l>` |
| command-line `<Tab>` `<S-Tab>` `<C-n>` `<C-p>` `<C-e>` `<C-y>` | blink.cmp | its menu where Neovim has completions |
| insert `,` `.` `;` | mappings.lua | an undo step per clause |
| insert `<Left>` `<Right>` | multicursor.lua | one insert across several cursors |

## Notes and notebooks

The notes graph lives in `~/notes` (or `$NOTES_DIR`) and keeps Logseq's layout: `journals/`, `pages/`, `assets/`, so
the Logseq app can open the same folder. `<leader>nn` opens today's journal, `<leader>nb` lists backlinks,
`<leader>nt` open tasks, `<leader>na` the agenda.

`nvim file.ipynb` opens a notebook as markdown, starts its kernel and shows the saved outputs. `<C-CR>` runs a cell in
place, `<leader>kn` runs it and moves to the next one (`<S-CR>` does the same in insert mode), and `:w` formats the code
cells and writes a normal notebook back, outputs included. The cells' language servers answer through otter: diagnostics,
`K`, `gd`, `grr`, and `grn` with a live preview. A kernel starts in its notebook's folder, as in JupyterLab, so a module
beside the notebook imports by its bare name (`import hfpy_utils`), ahead of a package of the same name. basedpyright
resolves it the same way: the cells get a basedpyright rooted at the notebook's folder, with the project's `.venv`
Python, and their diagnostics follow every edit, normal-mode ones included. Each notebook runs its own kernel; a second
notebook on the same kernelspec shows in the statusline as `<name>_1`, molten's id for a second instance. Kernels
started here print pandas DataFrames as outlined tables.
`<leader>ka`/`<leader>kb` add an empty cell above/below, `<leader>kd` cuts the cell (`p` pastes it elsewhere),
`<leader>ks` splits it at the cursor and `<leader>kj` joins it with the next one; the same keys work in quarto
documents and `# %%` scripts.

## Projects

`<leader>wn` asks for a template and a folder (the prompt starts in the working directory), creates the project, puts it
under git and opens it. C and C++ projects get a Makefile with `build`, `release`, `run` and `clean` targets; its
`CXXFLAGS` (`CFLAGS` in C), `LDFLAGS` and `LDLIBS` lines hold that project's compiler flags, linker options and
libraries. `make`, and saving the Makefile, copy the compiler flags into `compile_flags.txt`, so clangd checks what the
build uses and the flags live in the Makefile only. C builds as `-std=gnu17`, where `string.h` declares POSIX functions
such as `strdup`; `-Wpedantic` still rejects GNU extensions in the code. `<leader>wp` lists the projects under
`~/Coding` (or `$PROJECTS_DIR`) and the git roots of recent files; a typed part of the name filters the list, and `<CR>`
moves into the project and restores its session. When no session was saved, or the saved one shows no file of the
project (one saved after the last buffer was closed), the file picker opens there instead.
`<leader>wb` runs the project's build task and opens the quickfix list on errors, `<leader>wr` picks any task (make
targets, cargo, npm scripts, `.vscode/tasks.json`), `<leader>wt` shows the task list. `<leader>cr` builds and runs: in a
Makefile project, `make` and then the `run` target, whichever file is open; a lone C or C++ file builds with clang, as
`:make` and `<leader>wb` do, plus any flags its `// 999rpm-flags:` lines name near the top (`// 999rpm-flags: -lncurses`).
A `.nvim.lua` at a project's root holds its own settings once `:trust` approves it.

## Shell and terminal

`'shell'` is `sh`, found through `$PATH`, whatever the login shell, so `:!`, `:make`, `:grep`, `:%!` filters and plugins
that build shell commands get POSIX syntax under zsh and nushell alike. On Windows it stays cmd.exe, which Neovim's
Windows defaults and plugins there expect. Terminal buffers run the login shell: snacks terminals (`<C-,>` and
`<leader>t`) and a bare `:terminal` (on Windows `$SHELL` when set, else cmd.exe). External tools run through argument lists, never through a
shell string.

Key conflicts resolve kitty first, then the shell, then tmux, then Neovim: `kitty.conf` binds only `ctrl+shift`
combinations and `alt+1` to `alt+9`, none of which Neovim uses here; tmux keeps its default prefix `C-b` (`C-b C-b`
sends it on), so no Neovim mapping sits on `<C-b>`; and a terminal buffer maps no Alt keys, which zsh's vi mode and
nushell both use. tmux's extended keys let `<C-CR>`, `<S-CR>` and `<C-,>` reach Neovim, and passthrough lets images
and plots draw. Neovide's keys exist only inside Neovide, where kitty, the shell and tmux never see them.

## Known edge cases

- A fresh install records lazy.nvim's `stable` commit in `lazy-lock.json`, since the bootstrap clones that branch;
  `:Lazy restore` returns it to the locked commit.
- Without git, ripgrep, fd or node the start stays silent: gitsigns stays off and the statusline shows no branch,
  while `:grep` and the grep pickers need ripgrep when used.
- markdown-oxide never attaches to notebooks, so the notes graph's links and rename stay out of `.ipynb` files.
- otter's hidden cell buffer (`<notebook>.otter.py`) is left out of `<leader>dd`, `<leader>sd` and `<leader>dw`, since
  the notebook lists the same diagnostics; ruff skips I001 and N999 there, which only its synthetic file triggers.
- A notebook's cells are checked by a basedpyright rooted at the notebook's folder, so the project's
  `[tool.basedpyright]` or `pyrightconfig.json` settings do not reach them; their Python is the project's `.venv`, else
  the `python` on `$PATH`.
- While a macro records (`q` and a register), which-key stays out of the way: `<leader>` opens no menu and the
  statusline's pending keys show `<20>` (the space). The mode block shows `recording @<register>`; `q` ends it.
- Notifications fade after a few seconds; `<leader>sn` lists them again, errors included (a failed image conversion,
  for example). `<leader>sm` holds command-line messages only.
- snacks.image also draws the `img` and inline `svg` elements of HTML files. An SVG that is not well-formed, or an
  ImageMagick whose SVG renderer cannot start (inkscape aborting with `Gio::DBus::Error`), ends in a "Conversion
  failed" notification.
- Images, math and plots need the kitty graphics protocol; elsewhere they are skipped and text output still shows.
  Neovide has no such protocol: there snacks' images and smooth scrolling (Neovide animates its own) are off, and d2
  diagrams (`<leader>ud`) and notebook plots (`<leader>kp`) open in the system's image viewer.
  [neovim/neovim#41287](https://github.com/neovim/neovim/pull/41287), still open, would let GUIs draw images.
- colorful-winsep is off in Neovide: its coloured separators are floating windows, which Neovide draws with shadows
  and slides between windows, leaving streaks over the code; the plain separator lines remain.
- Neovide 0.17 fills the strip below the last row, left when the window height is not a whole number of rows, with
  that row's colours. Inside Neovide one empty command-line row therefore stays below the statusline (`cmdheight` 1,
  set in `lua/config/neovide.lua`); with no command-line row, lualine's sections would run down to the window edge.
- Neovide 0.17.1 draws the command line and messages itself until its first frame (its startup message capture, on by
  default), and noice.nvim cannot share them. Inside Neovide noice therefore starts once they are handed back, a moment
  after the window opens, and messages from startup come back through Neovide's replay. `neovide
  --no-startup-message-capture`, or `startup-message-capture = false` in Neovide's config file, skips the capture.
- On Windows `<leader>cr` builds a lone C or C++ file into `<name>.exe`; Makefile projects need `make`, and scripts
  their interpreter (`sh`, `bash`, `zsh`, `nu`), on `$PATH`, else a warning names the missing program.
- The C and C++ project template writes a Makefile with POSIX recipes (`mkdir -p`, `printf`, `rm -rf`), so on Windows
  it needs a make that runs them through sh, such as MSYS2's.
- After a theme switch without a restart (`<leader>ut`, `<leader>uc`, `<leader>uC`), crates.nvim's popup colours,
  grug-far's change markers and csvview's header line stay plain until the next start; those plugins set fixed colours
  once, at load. Every other plugin's colours follow the new theme.
- Files over snacks.bigfile's size limit open with the `bigfile` filetype: no treesitter, LSP or folds. A converted
  notebook is measured by its markdown, not by the `.ipynb`, whose saved outputs alone can cross the limit.
- avante.nvim's build step downloads the prebuilt libraries of avante's newest release, whatever commit is locked. Right
  after a release they can be missing (404), and the build stops with a `tar` error; `:Lazy build avante.nvim` repeats
  it once they are published.
