# Config log

What changed, and the reason it changed. Newest first. Older passes are condensed to their conclusions once a later
pass has confirmed them.

## 2026-10-01 (fourteenth pass): uv

- `:JupyterSetup` prefers uv: `uv venv` creates the environment (uv fetches a Python when none is installed) and
  `uv pip install --python <env>` fills it, since uv's environments carry no pip. python3's `venv` and pip stay the
  fallback. Every step runs from `stdpath("data")`, so a project's `.python-version`, `uv.toml` or pip settings do not
  reach it.
- `<leader>kv` / `:JupyterKernelAdd [name]` registers the uv project around the current file as a kernel, the way uv's
  Jupyter guide does (`uv add --dev ipykernel`, then `ipykernel install --user --env VIRTUAL_ENV <root>/.venv`), through
  argument lists, so the guide's `$(pwd)` form, which nushell does not accept, is not needed.
- A cell run while its kernel starts is queued until molten's `MoltenKernelReady`: output sent before the kernel answered
  was lost and the cell stayed "On Hold". A failed `MoltenInit`, which molten only reports through `vim.notify`, no longer
  counts as a running kernel.
- The setup and kernel steps share `run_chain()` in `utils.lua`.
- Checked: a fresh environment built by uv 0.11 (no pip inside) runs molten and the notebook round trip; uv also upgrades
  an environment pip built; with uv off `$PATH` the pip route still works; a uv project kernel registers, appears in
  molten's list and reports the project's `.venv` as `sys.prefix`; a cell pressed 0.7 s after opening a notebook runs
  once the kernel is ready.

## 2026-10-01 (thirteenth pass): barbar underline, Jupyter notebooks

Method: Neovim 0.12.5, headless runs, nushell 0.116 and zsh 5.9; the lockfile's commits plus the two new plugins; a
test notebook with saved outputs and a `# %%` script. Only notebook images in kitty could not be checked.

### barbar underline

- Reported: the current tab used to be underlined in kanagawa lotus and dragon. In the twelfth pass's files no tabline
  group carries an underline in any kanagawa style: kanagawa ships no barbar groups, so barbar derives them from
  `TabLine`/`TabLineSel`, which have none, and barbar's default preset strips underlines from the separators. The old
  underline could not be traced to a file; barbar has tracked master since the eighth pass and rebuilt its highlight
  cache in June 2026.
- `paint_tabs` (formerly `paint_slants`) copies barbar's fresh `BufferDefaultCurrent*` colours into `BufferCurrent*` with
  an underline in the tab's text colour, separators included, for the themes in `underline_themes` (kanagawa, all
  three styles). Icon groups inherit it from `BufferCurrent`. Checked: on in lotus and dragon, off after a switch to
  tokyonight, back after a switch to kanagawa.

### Jupyter notebooks

- molten-nvim runs code in Jupyter kernels and draws outputs under the cell, images through snacks.image (no image.nvim,
  no ImageMagick Lua binding). It tracks main: the last tag, v1.9.2 (January 2025), predates the snacks.nvim provider
  (May 2025).
- otter.nvim attaches the language servers to the code cells.
- The `.ipynb` handler is written in `utils.lua` (`notebook_*`, loaded by `notebook/ipynb.lua`): jupytext.nvim has had
  no commits since April 2024, its maintained fork none since June 2025. Notebooks open as jupytext markdown, molten's
  documented format; `:w` runs `jupytext --update`, then `MoltenExportOutput!`.
- quarto-nvim skipped: otter alone gives the LSP features, the cell runner is a few lines over `MoltenEvaluateRange`,
  and quarto's preview needs the Quarto CLI.
- `:JupyterSetup` (also molten's build step) creates `stdpath("data")/999rpm-jupyter` through argument lists only.
  `rplugin` left lazy's disabled list, since it defines molten's commands; the Python 3 provider runs only when that
  environment exists.
- Found while testing: molten fails with ENOENT on `kernel-*.json` while Jupyter's runtime folder does not exist, as on a
  fresh machine; `:JupyterSetup` now creates it. molten reports errors through `vim.notify`, which noice owns, so they
  stay out of headless output.
- Checked: the notebook opens as markdown with no undo step and no gitsigns; the kernel from its metadata starts on open
  and the saved outputs show; a run cell prints under its fence; `:w` keeps old outputs and adds new ones; `]j` `[j`
  and `ij` `aj` in notebooks and `# %%` scripts; otter-ls attaches.

### From the reference configs

- `undolevels = 10000`; prose filetypes get soft wrap with spell (group `999rpm-prose`); `]e` `[e` / `]w` `[w` for
  errors / warnings only; insert-mode `,` `.` `;` start a new undo step.
- The d2 block lookup and the notebook cell scan share `fenced_blocks()`.

### Checked and left as is

- which-key, trouble, noice, todo-comments and persistence have had no commits for 10 to 11 months, lazy.nvim for 9.
  Kept: stable, and nothing maintained does the same job.
- New global keys (`<leader>k*`, `]e` `[e` `]w` `[w`, insert `,` `.` `;`) collide with nothing; `<S-CR>`, `<C-CR>` and
  the cell `]j` `[j` are buffer-local. kitty.conf binds neither `shift+enter` nor `ctrl+enter`.
- `:grep` and `:!` still work under nushell and zsh.

## Earlier passes: conclusions only

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
