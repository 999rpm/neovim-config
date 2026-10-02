# Config log

What changed, and the reason it changed. Newest first; older passes are condensed to their conclusions once a later
pass has confirmed them.

## 2026-10-02 (sixteenth pass)

Method: Neovim 0.12.5, nushell 0.116, zsh 5.9, every plugin at its newest commit or tag; a headless script of 47 checks
that drives each change below (writes, failed writes, bufload(), tabs, resizes, cell edits, `:grep` under both shells),
then every plugin loaded and the keymaps of all modes scanned.

### Fixed

- Backups could stay off for the rest of a session: two autocommands switched the global `'backup'` off before writing
  a temporary or transient file and on again in BufWritePost, which a failed write never reaches. `'backupskip'` lists
  those files now, and its default `/tmp`, `$TMPDIR`, `$TMP` and `$TEMP` patterns are back (`'wildignore'` had replaced
  them). One autocommand still turns the undo file off for the same files.
- Trailing whitespace was stripped from patches (the context line of a blank line), mail signatures, binary buffers and
  files whose `.editorconfig` sets `trim_trailing_whitespace = false`; an unmodifiable buffer could not be written.
- `auto_create_dir` made a folder out of URL-style names (`scheme://...`).
- A file loaded unseen (pickers, grug-far, LSP renames) lost its last cursor position: bufload() fires BufWinEnter in
  Neovim's hidden autocommand window and resets the `'"` mark when that window closes. The mark is read at load time
  and applied in the first real window, with the exclusions of `:h last-position-jump` (commit messages, rebase todo
  lists, xxd, diff mode).
- With only quickfix, Trouble or neo-tree windows left in one tab, `qall` closed every other tab too. That tab closes
  alone now, scheduled, since BufEnter may not change the layout (E1312).
- A terminal resize equalized the splits of the current tab only; every tab now, through nvim_win_call.
- The yank cursor restore could apply another window's view when code yanked in a different window.
- `g:no_man_maps` and `g:no_gitrebase_maps` turned off built-in filetype keys: `gO` lists a man page's sections again,
  and `<C-a>`/`<C-x>` cycle a rebase todo line's action instead of dial's number steps. q in man pages stays this
  config's close, since man's own q quits Neovim from the last window.
- grug-far's header named keys it does not have: `<localleader>c` closes, `<localleader>b` aborts.

### Added

- Notebook cell editing, buffer-local wherever cells exist (notebooks, quarto, `# %%` scripts): `<leader>ka`/`kb` add
  an empty cell above/below in the language of the cell under the cursor and start insert mode, `<leader>kd` deletes
  the cell into the registers like `dd` (molten's output with it), `<leader>ks` splits it at the cursor line,
  `<leader>kj` joins it with the next cell when only blank lines part them. Molten's keys moved off those letters:
  run up to here `ka` to `ku`, delete output `kd` to `kD`, HTML output in the browser `kb` to `kw`.
- Sessions keep barbar's buffer order and pins, as barbar's README sets it up: `globals` in `'sessionoptions'`, and
  persistence's PersistenceSavePre (fired before its exit save) fires SessionSavePre.
- `.zshrc`: the fastfetch logo skips Neovim's `:terminal`, which inherits `KITTY_WINDOW_ID`; `MANPAGER` uses bat only
  when bat is installed.

### Removed and tidied

- The TermOpen handler no longer turns line numbers off: 0.12's `nvim.terminal` group does, along with signs and folds.
- Comments in `.zshrc`, `.zshenv`, `config.nu` and `env.nu` follow the neutral style of the rest; their code is
  unchanged apart from the two `.zshrc` items above. Seven Lua files reformatted by StyLua's defaults.
- The archive mirrors `$HOME`, so one `unzip -d ~` places every file.
- Lockfile: avante.nvim, hardtime.nvim (1.3.0), nvim-lspconfig, nvim-treesitter, schemastore.nvim and yazi.nvim moved;
  the plugins pinned to tags stay (blink.cmp 1.10.2, mini.nvim 0.18.0, nvim-surround 4.0.5, rustaceanvim 9.2.1,
  tree-sitter-d2 0.7.2).

### Checked and left as is

- Treesitter indentation (`indentexpr`) stays off: nvim-treesitter's README calls it experimental.
- blink.cmp's 240 commits after 1.10.2 are unreleased; `version = "*"` keeps the tag.
- The options and plugins of the reference configs add nothing missing here; plugins two or more of them share are
  alternatives already in place (telescope, nvim-cmp, bufferline, fidget) or declined below.
- No mapping uses `<C-S-...>` or `<M-1>`...`<M-9>`, the keys kitty.conf takes, with every plugin loaded.
- `E116 dictwatcherdel` (barbar) and `E31` (which-key) in `v:errmsg` remain silent and harmless.

## Earlier passes: conclusions only

**Fifteenth pass (2026-10-02).** Nushell's `shellpipe` writes the errorfile through a `do` closure (tee's parallel
closure lost it) and `:!` runs without `--login`. A notebook opened with `:edit` in a running session sets its own
filetype. `gd` and normal-mode `<C-k>` only where a server answers them. actionlint only on `.github/workflows`.
`<leader>oN` survives the number_toggle autocommands; every on/off switch under `<leader>o`. neotest-python and
rustaceanvim's adapter added; parsers for kitty, zsh, diff, git files, luadoc, luap, printf, xml, ini, sql, dockerfile,
make, cmake and just (gitcommit left out: its parser build exhausts 4 GB). `excluded_folders = ["logseq"]` in moxide.
Kept: nvim-treesitter (unarchived July 2026), ts_ls (TypeScript 7 has no Mason package), noice over the private ui2.

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
