# Config log

What changed, and the reason it changed. Newest first; older passes are condensed to their conclusions once a later
pass has confirmed them.

## 2026-10-03 (twentieth pass)

Method: the nineteenth pass's headless setup; every theme and style loaded from a saved file, every switcher action
driven, the state file fed broken input (`null`, a bare string, broken JSON, an unknown theme, a style index that is
not a number or out of range, `[]`, no file), a theme made to fail on load, then the full harness, StyLua and the
"This util is used by" check again.

### Changed

- The theme switcher moved out of `core/themes.lua` into `utils/themes.lua`, the way notes, notebooks and projects keep
  their code in `utils/`. The spec file is now `core/colorschemes.lua`: the four colour schemes and the 999rpm-themer
  spec, whose keys became lazy.nvim `keys` entries. `lang/d2.lua` became `lang/d2-diagrams.lua`: no plugin file shares
  a basename with a `utils/` module, the rule that once renamed `plugins/init.lua`.
- A theme that fails to load (a plugin missing where no git installed it) no longer stops startup or a switch: startup
  warns and keeps Neovim's default colours, a switch warns and returns to the last theme, and the saved choice stays.
- The state file is read defensively: anything but a JSON object keeps the defaults, an unknown theme is ignored and
  the style index is clamped. `null`, a bare string or a style index that was not a number stopped the switcher before
  it set any colours or keys, and an unknown theme left no colour scheme at all.

### Removed

- `lualine.refresh()` after a switch: lualine reloads itself on `ColorScheme` and on a `'background'` change.
- kanagawa's own `package.loaded` reset, which repeated the one every theme gets.

### Fixed

- snacks.lua's header still sent d2 rendering to the removed tree-sitter-d2.lua, and `core.warn`'s note now names
  `utils/themes.lua`.

## Earlier passes: conclusions only

**Nineteenth pass (2026-10-03).** nvim-treesitter's custom-parser hook builds the d2 parser (ravsii/tree-sitter-d2
at v0.7.2): the plugin started treesitter unguarded on every `.d2` buffer and had no commit in a year. `'secure'` went
(Neovim removed it; `:trust` guards `'exrc'`). One `vim.lsp.enable()` call for every server, since each call re-ran
FileType over every open buffer. nvim-dap alone names its panels and Python adapter; `utils/run.lua` owns the compiler
flags (`-W`, the old name of `-Wextra`, dropped); tmux takes truecolour from `terminal-features RGB`. Under nushell
`:%!sort` runs nu's own `sort`: `:sort` or `:%!^sort` instead. Declined: nvim-lightbulb (no room in the sign column or
at the end of the line), ui2 (still experimental in 0.12.5).

**Eighteenth pass (2026-10-03).** The projects layer under `<leader>w`: the `utils/project.lua` wizard (C and C++
with a Makefile and `compile_flags.txt`, Rust, Python, JavaScript), overseer.nvim with a provider that tags make and
lone-file clang builds, `utils/run.lua` (`<leader>cr`, and clang as `'makeprg'` quoted with `:S`), `'exrc'` and the
`kdl` parser. Terminal mode maps no Alt keys; octo's Ctrl keys moved to `<localleader>` and `<A-...>`; `run_chain()`
moved to `utils/core.lua`. Kept: nvim-treesitter's curated queries over tree-sitter-manager.nvim; no cmake-tools or
vim-dadbod.

**Seventeenth pass (2026-10-03).** `utils.lua` became `lua/utils/` (one module per subject, no `init.lua`).
`get_lsp_capabilities` gave way to 0.12's own folding capabilities and blink's merge into `vim.lsp.config("*")`.
blink, the pickers and nvim-bqf scroll documentation and previews with `<M-j>`/`<M-k>` instead of tmux's `<C-b>`.
tmux.conf gained extended keys, passthrough and undercurl. better-escape stopped mapping visual `j`; notebooks in the
graph stopped getting Logseq keys and auto-save; impossible journal dates are refused; `history` keeps 10000.
package-info.nvim and vim-suda were added.

**Sixteenth pass (2026-10-02).** Backups survive a failed write (`'backupskip'` lists temporary files instead of
toggling `'backup'`); trailing whitespace stays in patches, mail, binary buffers and where `.editorconfig` keeps it; the
last cursor position survives bufload(); a tab left with only quickfix, Trouble or neo-tree closes alone; a resize
equalizes every tab; `gO` in man pages and `<C-a>`/`<C-x>` in rebase todo lists are back. Notebook cell editing under
`<leader>k` and barbar's order and pins in sessions were added; the archive mirrors `$HOME`.

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
that writes SVG, PNG and text itself. Added `tree-sitter-d2.lua` (replaced by nvim-treesitter's parser hook in the nineteenth pass), `utils.d2_render()`, `utils.d2_text()`, the `d2`
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
