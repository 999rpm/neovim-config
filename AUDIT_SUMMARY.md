# Config log

What changed, and the reason it changed. Newest first; older passes are condensed to their conclusions once a later
pass has confirmed them.

## 2026-10-06 (twenty-second pass)

Method: Neovim 0.12.5 headless (`-u NONE` with the config's `lua/` on the runtime path, options.lua and autocmds.lua
loaded, overseer.nvim at its locked commit), clang 18.1 and GNU make 4.3. A 39-step harness: the wizard's C and C++
projects built, rebuilt after a flag edit and after a header edit, linked against a static library through `LDFLAGS`
and `LDLIBS`, built for release and run; `<leader>cr` in a project with Neovim's working directory elsewhere and a
header left unsaved, then with a compile error; a Makefile without a `run` target; a CMake folder; lone files in a folder
with a space (a library, `-Wno-error`, a flag line below line ten, a missing file); `:make` under sh, zsh 5.9 and
nushell 0.116.1; overseer's build task in a project and on a lone file. StyLua clean.

### Fixed

- `<leader>cr` ignored a project's Makefile: it compiled the open file alone with the default flags, so a project with
  more than one source file or a library failed to link, and the binary landed in `src/`. Under a Makefile it now runs
  `make`, then the `run` target in the split (Visual Studio's Ctrl+F5), after writing the project's modified file
  buffers, as 'autowrite' does for `:make`. A directory line leads the quickfix list, so a make error opens the right
  file when the working directory is elsewhere. A file under CMake or meson warns instead of building alone.
- A generated Makefile did nothing after its own flags or a header changed, since the program depended on the sources
  only; it depends on the Makefile and the headers in `src/` too.

### Changed

- Generated Makefiles keep linker options in `LDFLAGS` and libraries in `LDLIBS`, after the sources, as GNU ld needs;
  a three-line header names the variables. `make` rewrites `compile_flags.txt` from `CXXFLAGS` (`CFLAGS` in C) whenever
  the Makefile changes, so clangd follows a project's flags; the wizard still writes the first copy.
- A lone C or C++ file names extra flags on `// 999rpm-flags:` lines among its first ten lines. They follow the file on
  the command line, so a library links and a later flag overrides a default (`-Wno-error`). `<leader>cr`, overseer's
  `clang: build file` task and `:make` read them; `'makeprg'` is set again after each write, each flag quoted for the
  shell.
- `utils/run.lua` owns the Makefile lookup overseer.lua's make task uses (`run.makefile()`). `M.flags` seeds new
  Makefiles only: an existing project keeps the flags its Makefile holds.

## 2026-10-03 (twenty-first pass)

Method: Neovim 0.12.5 headless with every plugin at its newest commit (nine moved: avante, gitlinker, hardtime, lazy.nvim,
nvim-lspconfig, nvim-treesitter, nvim-ts-autotag, schemastore, yazi; lazy-lock.json records them). A 63-step harness:
startup, every theme and style, every plugin loaded, a key audit (no global key set twice with different jobs, no global
map on a protected built-in, nothing on tmux's prefix, kitty's alt+digit or ctrl+shift keys, or Alt in terminal mode),
each filetype opened, the notes layer on a scratch graph (dates, journals, task cycle, block moves, links, pickers,
templates, logseq/ left out), a notebook written and reopened, `:grep`, `:%!` filters and `:make` under zsh 5.9 and
nushell 0.116 in a folder with a space, the project wizard and `<leader>cr`. The shell files ran in real zsh and nu with
and without starship, zoxide and broot; the tmux template, rendered with sample colours, loaded in tmux 3.4. StyLua clean.

### Fixed

- A notebook saved into a folder that did not exist was never written: BufWriteCmd skips BufWritePre, where autocmds.lua
  creates missing folders. `utils/notebook.lua` creates the folder itself and fires BufWritePost after a write, so
  otter.lua's cell diagnostics refresh as they do after any `:w`.
- nushell stopped reading config.nu when broot's launcher was missing (`use` resolves at parse time) and stopped env.nu
  when zoxide was missing. starship and zoxide now write their init scripts into the vendor autoload folder only when
  installed, the broot module becomes `null` when its file is absent, and PATH drops duplicate entries.
- zsh printed errors at every start without fzf, zoxide, starship or broot; each now loads only when present, and the
  broot launcher path no longer spells out a home folder.
- `:ProjectNew <template>` naming no template did nothing; it warns now.
- `<leader>cv` (tw-values) answered in every buffer; it is limited to jsx, tsx, html and css.

### Changed

- tmux.conf ships as the matugen template, `.config/matugen/templates/tmux.conf`, and the generated
  `~/.config/tmux/tmux.conf` stays out of the archive, so extracting it never replaces live colours with template fields.
  Truecolour comes from `terminal-features RGB`, as the nineteenth pass intended. `.config/moxide/settings.toml` is back.
- Comment trims: lualine's `path` and `file_status`, conform's `clang-format`, `rust` and `toml` notes. `is_lone` names its
  argument a path, which is what its callers pass.

### Checked and kept

- The sixteen reference configs hold nothing new beyond what earlier passes took or declined: the options they set and
  this config does not are 0.12 defaults (autoread, hidden, hlsearch, incsearch, wildmenu, history) or plugin territory
  (statuscolumn, folds), and the plugins three or more of them share have replacements here (telescope, bufferline,
  nvim-cmp, LuaSnip, diffview, fidget, vim-illuminate) or were declined before.
- hardtime's `which_key_ignore` maps on `.`, `p`, `x`, `J`, `~` and the `g` operators count the key and pass it through;
  multicursor's insert `<Left>`/`<Right>` exist only while cursors are active.
- snacks.lua's markdown `images` query replaces only the fenced-block part (math kept, mermaid dropped); `![]()` images
  come from the plugin's markdown_inline query. mason-tool-installer checks installs through `vim.defer_fn`, so loading
  on VeryLazy still installs. blink's cmdline preset maps `<Left>`, `<Right>` and `<End>`, which the `false` entries drop.
  avante's README lists mega.cmdparse. rustaceanvim v9.2.1 is the newest major and multicursor's 1.0 branch is current.
  guess-indent, hex.nvim, nvim-dap-virtual-text, promise-async and mega.logging have had no commit in over a year; kept.

## Earlier passes: conclusions only

**Twentieth pass (2026-10-03).** The theme switcher moved to `utils/themes.lua`; `core/colorschemes.lua` holds the
four schemes and the 999rpm-themer spec, and `lang/d2.lua` became `lang/d2-diagrams.lua`, so no plugin file shares a
basename with a `utils/` module. A theme that fails to load warns and keeps the last one; the state file is read
defensively (anything but a JSON object keeps the defaults, the style index is clamped). `lualine.refresh()` after a
switch and kanagawa's own `package.loaded` reset went.

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
