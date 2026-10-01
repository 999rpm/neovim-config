# Config log

What changed, and the reason it changed. Newest first; older passes are condensed to their conclusions once a later
pass has confirmed them.

## 2026-10-02 (fifteenth pass)

Method: Neovim 0.12.5, nushell 0.116, zsh 5.9, actionlint 1.7.12, the lockfile's commits; headless runs per filetype,
keymap dumps (global and per buffer, every plugin loaded) and `:checkhealth`.

### Fixed

- Nushell: `shellpipe` used `tee`, whose closure runs in parallel; nu 0.116 exits before it writes the errorfile, so
  `:grep` and `:make` ended in E40 (1 run in 30 wrote it). A `do` closure writes it every time, no-match runs included.
  `--login` left `shellcmdflag`, as in nushell/integrations: `:!` no longer runs env.nu and config.nu, which failed
  every command whenever a tool they call (zoxide) was missing.
- A notebook opened with `:edit` inside a session got no filetype, so no cell keys or otter. Both read events replay
  inside the BufReadCmd handler, and `vim.lsp.enable()` (lspconfig loading on BufReadPre) fires FileType for open
  buffers, after which filetypedetect's `:setf` skips. The handler sets the filetype itself when it is still empty.
- `gd` and normal-mode `<C-k>` are set only when an attached server answers definitions or signature help. In markdown
  only render-markdown's in-process server attached, so `gd` went to a server that cannot answer it.
- nvim-lint ran actionlint on every YAML file, and plain YAML got "on"/"jobs" errors; it now runs on
  `.github/workflows/*.y(a)ml` only. The `yaml.github` entry never matched, since workflows open as `yaml`. Files are
  also linted when opened.
- `<leader>oN` was undone by the `number_toggle` autocommands on the next BufEnter or InsertLeave; both read
  `vim.g._999rpm_relativenumber` now.
- snacks' `indent()`, `dim()` and `words()` toggles take no options, so the names passed to them were dropped; the
  labels are set on the toggles. Every `<leader>o` description reads "Toggle ...".
- On/off switches moved under `<leader>o`: transparency `<leader>uT` to `ot`, markdown rendering `<leader>um` to `om`,
  debug virtual text `<leader>Dv` to `ov`.
- Copilot's panel key `<M-CR>` collided with markdown-plus's `<A-CR>` in markdown; the panel is off, suggestions cycle
  with `<M-]>`/`<M-[>`. markdown-plus's insert `<A-h/j/k/l>` cell moves hid copilot's `<M-l>`; off as well.
- Filetype rules 0.12.5 handles itself are gone (Brewfile, Jenkinsfile, justfile, yarn.lock, helmfile.yaml,
  .kube/config, .jscsrc), and so is `todo.txt` as `todotxt`, a filetype with no runtime support.
- `notes_root` named two callers that do not call it. kitty.conf named a config.nu setting that does not exist;
  nushell 0.116 sends prompt and directory marks by default.

### Added

- neotest-python (pytest; `$VIRTUAL_ENV`, else a venv folder in the project, else python3) and rustaceanvim's own
  neotest adapter; `<leader>Td` debugs the nearest test.
- Parsers: kitty, zsh, diff, git_config, git_rebase, gitignore, luadoc, luap, printf, xml, ini, sql, dockerfile,
  make, cmake, just. gitcommit stays out: its 3.3 MB parser ran the compiler out of memory on a 4 GB machine.
- `moxide/settings.toml`: `excluded_folders = ["logseq"]` (markdown-oxide 0.25.12) keeps the copies in Logseq's
  `bak/` and `version-files/` out of the index.

### Removed and tidied

- nvim-treesitter left the dependency lists of neotest, render-markdown, treesj, rainbow-delimiters and hlargs; none
  of them loads it on 0.12.
- `options.lua` comments follow the lower-case end-of-line style of the other files. History notes and "see utils.lua"
  pointers are gone, and every plugin header starts with the repository name.
- README cut from 580 lines to an overview.

### Checked and left as is

- nvim-treesitter was archived on 3 April 2026 and unarchived on 19 July, with commits through 30 September. Kept:
  tree-sitter-manager.nvim (rafi, SeniorMars) only installs parsers, and textobjects and tree-sitter-d2 call into it.
- TypeScript 7 serves LSP itself (`tsc --lsp`, lspconfig `tsc`) and has no Mason package; Mason pins ts_ls to
  TypeScript 6.0.3. ts_ls kept.
- noice kept over 0.12's `vim._core.ui2` (jdhao, rafi): ui2 is private and experimental.
- The python and ruby ftplugins map `]m [m ]M [M` themselves and win in those buffers; they jump the same way.
- No mapping uses `<C-S-...>` or `<M-1>`...`<M-9>`, the only keys kitty.conf binds.
- `E31` in `v:errmsg` comes from which-key's own cleanup. snacks' health errors about `vim.ui.select` and the
  dashboard appear only headless, where UIEnter never fires.

## Earlier passes: conclusions only

**Fourteenth pass (2026-10-01).** `:JupyterSetup` prefers uv (`uv venv`, then `uv pip install --python`), python3's
venv and pip as the fallback, all from `stdpath("data")`. `<leader>kv` / `:JupyterKernelAdd` registers the uv project
as a kernel the way uv's Jupyter guide does, through argument lists, so nushell needs no `$(pwd)`. Cells pressed while
the kernel starts wait for `MoltenKernelReady`. `run_chain()` in `utils.lua` serves both.

**Thirteenth pass (2026-10-01).** Jupyter notebooks: molten-nvim (main, for the snacks.image provider) runs kernels,
otter.nvim attaches the servers to cells, and the `.ipynb` handler in `utils.lua` converts through the jupytext CLI
(jupytext.nvim and its fork are unmaintained). quarto-nvim skipped. kanagawa's current tab gets an underline through
`paint_tabs`. From the reference configs: `undolevels = 10000`, prose filetypes with soft wrap and spell, `]e [e` /
`]w [w`, insert `,` `.` `;` undo breaks.

**Twelfth pass (2026-10-01).** Three regressions: the theme switcher never ran, because two local specs shared
`dir = stdpath("config")` and lazy.nvim merged them (both are now `virtual = true` with slash-less names); colorizer
disabled itself, because 0.12 applies `termguicolors` at `VimEnter` (set again); DAP warned for every missing adapter
(`utils.mason_adapter()` checks per session). tiny-inline-diagnostic replaced an 80-line handler, vim-matchup replaced
matchit and matchparen; ts-comments, mini.align, crates.nvim and Snacks.rename were added; lualine stopped running
`git fetch`. `<leader>x` merged into `<leader>d`, workspace folders moved to `<leader>lw*`. Declined: kitty-scrollback,
smart-splits, quicker.nvim, marks.nvim, nvim-treesitter-endwise, themery, virt-column, reference keymaps that take
built-ins, mini.trailspace. Over a year without commits but kept: promise-async, guess-indent, nvim-dap-virtual-text,
hex.nvim. `v:errmsg` holds barbar's silent `dictwatcherdel` E116.

**Eleventh pass (2026-09-30).** The Logseq layer: markdown-oxide rooted at a `logseq/` graph with
`moxide/settings.toml`, `notes/logseq.lua` with the `notes_*` helpers (journals, pages, references, tasks, agenda,
templates, block moves, focus, link graph, git commit), markdown-plus, auto-save limited to the graph, graph highlights
through mini.hipatterns, bullet folds in `after/queries/markdown/folds.scm`, Logseq snippets. Defects fixed then:
`matchpairs` entries with one character, `emoji = false` against kitty's two-cell emoji, `showcmdloc` next to
`showcmd = false`, a `backupdir` Neovim never created, `close_with_q` on a wiped buffer, a file-reload check on every
`CursorHold`, lualine listing every session's servers, blink loading lazydev outside Lua. `<leader>n` became the notes
graph and the no-yank edits moved to `<leader>y`.

**Tenth pass (2026-09-30).** Startup went from 21 plugins to 11 (119 ms to about 60 ms with a UI): harpoon's keys moved
into `keys`, mason-lspconfig stopped naming nvim-lspconfig, lspconfig waits for `BufReadPre`, barbar stopped naming
gitsigns, mini.icons left seven dependency lists. snacks.words replaced a hand-written `documentHighlight` pair and
gave `]r`/`[r`. Key scheme: `<leader>o` holds toggles only, `<leader>u` UI and theme, `<leader>p` plugins and tools.
`jumpoptions` keeps 0.12's `clean`; staged gitsigns glyphs match the unstaged ones; every executable check goes
through `utils.executable`. `frontend/` merged into `lang/`. Buffer variables became `b:_999rpm_*`.

**Ninth pass.** d2 replaced mermaid: mermaid-cli renders through a headless Chromium, d2 0.9.0 is one static binary
that writes SVG, PNG and text itself. Added `tree-sitter-d2.lua`, `utils.d2_render()`, `utils.d2_text()`, the `d2`
filetype and conform's `d2` formatter; removed the mermaid parser and pointed snacks.image's markdown query at
` ```math ` blocks only. Fourteen built-in keys were returned, each personal action moved to a free key: `;` `,` `q`
`x` `X`, visual `p`, `<C-q>`, `H` `L`, `f` `F`, `s` and visual `S`, visual `R`, `g]`, `<C-LeftMouse>`, `]f` `[f`, `zr`
and the command-line `<Left>` `<Right>` `<End>`. Defects fixed: hardtime's own maps had silently replaced the config's
`j`/`k`/`J` and arrow maps; `<leader>io` called an opencode function that no longer exists; `K` on every LSP attach
replaced rustaceanvim's hover actions; a `LspProgress` echo duplicated noice; conform sent Dockerfiles to prettier;
nvim-surround v4 dropped `setup({ keymaps })`; octo and hex raised when `gh`/`xxd` were missing; the debug stack and
blink loaded too early; `close_with_q` force-deleted oil buffers; highlight overrides were lost on the first theme
switch; seventeen options were set to values 0.12.5 already uses. Replacements: alpha-nvim → snacks.dashboard,
nvim-window-picker → `Snacks.picker.util.pick_win()`, a manual `large_file` autocommand → snacks.bigfile, mason-nvim-dap
→ four mason-tool-installer entries.

**Eighth pass.** First run with every plugin installed under 0.12.5. Icons restricted to nf-md glyphs (U+F0001 and up)
and `\u{...}` escapes, after older private-use glyphs kept vanishing in transit. `lint.lua` moved to the public
`try_lint(nil, { filter = installed })`. gopls and gofumpt became conditional on Go. text-case.nvim → coerce.nvim;
FixCursorHold removed; barbar's version pin dropped. kitty's new tab moved to `ctrl+shift+t`, so `<C-t>` reaches Neovim
and fzf. Nushell's `shellpipe` saves stdout as well as stderr, so `:grep` fills the quickfix list.

**Seventh pass.** `gd`/`gD` are built-in commands, not keymaps, so which-key cannot discover them; label-only spec
entries name them without taking them over. `diffopt` is assigned whole. 0.12 took `an`/`in` for node selection, so
mini.ai's next-object pair moved to `aN`/`iN`. nvim-lspconfig registers no commands on 0.12, so `:LspInfo`, `:LspLog`
and `:LspRestart` here are the only source of them.

**Sixth pass.** Built-ins returned: `<C-a>`/`<C-x>` (dial widens them), `>`/`<`, insert-mode `<C-e>`; select-all moved
to `<leader>na`. `dap.configurations.c` and `.rust` are deep copies of `.cpp`, since rustaceanvim appends runnables to
the table in place. Statusline scans are memoised on `b:changedtick` through `utils.buf_cached()`.

**Fifth pass.** One picker engine (snacks.picker) instead of three. barbar replaced bufferline. Each terminal layout is
a separate snacks terminal, keyed by an env var. `'shell'` follows the passwd login shell, with nushell's own flags only
when the shell is nu. Terminal-mode `<M-w/a/s/d>` move between splits and pass through in floats.

**First to fourth passes.** `plugins/init.lua` renamed `plugins/loader.lua` after going missing in seven deliveries (it
shared a basename with the root `init.lua`). Real bugs fixed: `shell = "nushell"` (the binary is `nu`), duplicate
format-on-save, a ufo fallback chain that could not catch treesitter failures, nvim-lint raising on a missing `typos`
inside `BufWritePost` and breaking `:w`, Noice swallowing the hover border. `mini.icons` stands in for
nvim-web-devicons through `mock_nvim_web_devicons()`. Declined, reasons unchanged: sidekick.nvim, eyeliner.nvim,
hydra.nvim, fidget.nvim, nvim-spider, nvim-navic, nvim-hlslens, terrastruct/d2-vim.
