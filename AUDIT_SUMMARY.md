# Config log

What changed and why, newest first. Older passes are condensed to their conclusions once a later pass confirms them.

## 2026-10-28 (thirty-second pass)

Method: Neovim 0.12.6, still the latest release. The tree matched pass 31's manifest and the lockfile was unchanged, so
no file and no plugin moved. Three owner issues, reproduced with `p32-regressions.sh`: `<leader>wp` typed in the tmux
TUI, the C template built with clang 18 and checked by clangd 22 (PyPI), and the floats open after `<leader>dd` dumped
from the TUI (Neovide cannot run here). Script and runtime checks ran on every file; touched files were read in full.

### Fixed

- `<leader>wp` (owner): the projects picker opened in its result list, where a typed name ran as commands (`t` took
  the `r`, `a` failed with E21, `v` started Visual mode) and `<CR>` then opened nothing; names starting with `i` or `/`
  reached the input, hence "sometimes". The projects source opens in the input, as grep does (snacks.lua). Source:
  folke/snacks.nvim `lua/snacks/picker/config/defaults.lua` (list keys), `sources.lua` (projects).
- compile_flags.txt (owner): the Makefile already owned the flags (make rewrites compile_flags.txt from CFLAGS or
  CXXFLAGS), but clangd kept the old ones until the next make. Saving a Makefile with a `compile_flags.txt:` rule now
  runs that rule (autocmds.lua, `run.sync_compile_flags()`), and clangd took the new flags at the next edit without a
  restart.
- C template: `-std=c17` defines `__STRICT_ANSI__`, so glibc's string.h hides POSIX functions; the owner's screenshot
  shows `strdup` undeclared, an error since C99. New C projects use `-std=gnu17`, clang's default and the dialect lone
  files build with; `-Wpedantic` still rejects GNU extensions in the code, and C++ was unaffected (clang++ defines
  `_GNU_SOURCE`). Sources: https://www.gnu.org/software/libc/manual/html_node/Feature-Test-Macros.html, `man 3 strdup`.
- Neovide (owner, streaks after `<leader>dd`): with Trouble open, the only floats over the code are colorful-winsep's
  separators, 1 cell thick and sliding to the next window's edges (shift animation). Neovide draws every float with a
  shadow and animates its moves, with global switches only (https://neovide.dev/configuration.html), which matches the
  grey bar and shadow fan in the screenshot. colorful-winsep is off under Neovide (`cond`); the bullet stays open until
  the owner confirms.

### Checked and kept

- Kept despite a year without commits (upstream HEAD equals the lock on 2026-10-28, no breakage known): which-key.nvim,
  persistence.nvim and boundary.nvim, last commits on 2025-10-28; mini.clue remains the fallback for which-key.
- Kept upgrades; `owner/repo` is https://github.com/owner/repo at the locked commit (README unless a file is named),
  "p28" the typed test written in pass 28 and rerun each pass (p32 included), other numbers the pass that ruled it:

| Key (mode) | Mapping | Preserved | Gained | Source; test |
| --- | --- | --- | --- | --- |
| `n` `N` (n) | `nzzzv` | jump, count | centred, fold opened | `:help zz`; p28 |
| `<Esc>` (n) | `:nohlsearch` | cancels a count or register | search highlight cleared | `:help index`; p28 `3<Esc>j` |
| `grn` (n) | inc-rename | rename at cursor | live preview | smjonas/inc-rename.nvim; p28 TUI |
| `gd` `gD` (n) | LSP | built-in without a server or an answer | server's answer | `:help vim.lsp.buf_request_all()`; p28 |
| `]c` `[c` (n) | gitsigns | built-in in diff mode, count | hunks | lewis6991/gitsigns.nvim `doc/gitsigns.txt`; p28 |
| `]m` `[m` `]M` `[M` (n, x) | textobjects | built-in without a parser, count | any parsed language | nvim-treesitter/nvim-treesitter-textobjects; p28 |
| `zR` `zM` (n) | nvim-ufo | open, close all | provider folds | kevinhwang91/nvim-ufo; p28 |
| `<C-a>` `<C-x>` (n) | dial.nvim | numbers, count, `.` | dates, true/false | monaqa/dial.nvim; p28, 30 cases |
| `%` `g%` `[%` `]%` `a%` `i%` (n, x, o) | vim-matchup | brackets, `N%` | word pairs, tags | andymass/vim-matchup; p28 |
| `a` `i` (x, o) | mini.ai | `iw` `a(` `i"` `ap` `as` `it`, counts | more objects, next/last | nvim-mini/mini.nvim `doc/mini-ai.txt`; p28 |
| `K` (n, Rust) | rustaceanvim | built-in without rust-analyzer, count | hover actions | mrcjkb/rustaceanvim; p28 |
| `gf` `<C-w>f` (n, graph) | logseq.lua | path under cursor, count | links, block refs | `notes/logseq.lua`; p28 |
| `<BS>` `<CR>` (i) | nvim-autopairs | delete, line break | pairs | windwp/nvim-autopairs; p28 |
| `o` `O` (n), `<CR>` `<Tab>` `<S-Tab>` `<BS>` (i) | markdown-plus | outside a list | list items | YousefHadder/markdown-plus.nvim; p28 |
| `<LeftMouse>` (n) | satellite.nvim | click | scrollbar drag | lewis6991/satellite.nvim; p28 TUI |
| `<Tab>` `<CR>` `<C-e>` `<C-k>` (i) | blink.cmp | `fallback` without menu | completion | saghen/blink.cmp keymap docs; p28 |
| `<C-l>` (i) | copilot.lua | popup-menu CTRL-L, `<C-x><C-l>`, no suggestion | suggestion accepted | zbirenbaum/copilot.lua; `:help ins-completion`; p28 |
| `<Tab>` `<S-Tab>` `<C-n>` `<C-p>` `<C-e>` `<C-y>` (c) | blink.cmp | built-in where Neovim has no completion, or with no menu | fuzzy menu | saghen/blink.cmp `keymap/presets.lua`; p28 TUI |
| `,` `.` `;` (i) | `<C-g>u` | text, `.` repeat | undo per clause | `:help i_CTRL-G_u`; 13, p28 |
| `<Left>` `<Right>` (i) | multicursor | built-in with one cursor | one insert per cursor set | jake-stewart/multicursor.nvim `core.lua`; p28 |

- Key audit (p32): as in pass 31 (55 hardtime pass-through keys, 26 quickfix window keys, the table's 77 rows; no layer
  conflict; nothing twice; `g:neovide` adds only the kitty_mod rows). Autocmds: 44 groups, 97 handlers (compile_flags
  added), none twice. Lint, LuaLS (28), selene (10), plugdefaults (16 SAME, the rulings of passes 25 and 26) and the two
  `dependencies` exceptions as in pass 31.
- P4: two clean boots (103 plugins, 44 parsers; Mason's registry the only install error); `:checkhealth` errors
  environmental; startup 68.3 against 68.5 ms over 21 interleaved runs (the five-run medians, 80.7 and 67.2, were
  noise); 107 typed upgrade cases, the TUI keys and the pass-24 to pass-32 steps pass; removal test 91 files; zsh 5.9
  and nu 0.116.1 full matrices (utils/run.lua changed); edge cases as in pass 27; theme switch: the 11 logged groups.
  Skipped: kitty and Neovide (no display), linters (none installed).
- Ruling: the projects picker joins the query-first sources (grep, lines, workspace symbols), an exception to the
  owner's normal-mode pickers, because its items are chosen by name.
- Declined (awesome-neovim 5a801eb): tmux-oil.nvim (tmux sessions as an oil buffer; tmux is optional here and the
  plugin is new), ghost.nvim (LLM answers in virtual text; overlaps avante.nvim), matrix-splash.nvim (a splash screen
  beside snacks.dashboard), lumina-themes (colourschemes; the four schemes stand).

## Earlier passes: conclusions only

- 31st (2026-10-24): Windows and macOS: the `$TMPDIR`-style undo exclusions expand through `vim.fs.normalize()` (autocmd
  patterns are literal), 'shell' is sh only off Windows (cmd.exe stays there), Windows `.exe` names, avante's
  `Build.ps1`; Neovide: `config/neovide.lua` (font, macOS Meta, text-size keys, `<D-c>`/`<C-S-c>` copy and paste),
  snacks.image, snacks.scroll and molten's images off there. Rulings: `<C-S-c>`/`<C-S-v>` exist only inside Neovide,
  beyond kitty's reach; `i_CTRL-SHIFT-V` and `c_CTRL-SHIFT-V` stay built-in. Declined: stylepeek.nvim (CSS rule
  browser).
- 30th (2026-10-23): no change; sprout.nvim declined (a start-screen ornament beside snacks.dashboard); kept despite
  a year without commits: sc-im.nvim, promise-async, mega.logging, guess-indent, nvim-dap-virtual-text, tw-values.nvim.
- 28th and 29th (2026-10-22): cell buffers get their own basedpyright (the notebook's folder as root, the project's
  `.venv`) and kernels start in the notebook's folder; ruff ignores I001 and N999 in `*.otter.*`; hidden cell buffers
  stay out of the diagnostics lists; `<leader>sn` is the notification history. Rulings: a second notebook keeps its
  own kernel (`<name>_1`), as in JupyterLab; snacks' HTML image query stays.
- 27th (2026-10-20): README's Install names lazy.nvim's `stable` clone; init.lua's "Keys:" paragraph is the key
  hierarchy summary.
- 26th (2026-10-20): `<leader>nX` cancels; `2<C-w>f` keeps its count; the right-click Trouble item is off without
  `:Trouble`. Rulings: plugin files call `Snacks` only in handlers and events;
  the key-handler builders of logseq, molten, sc-im and colorschemes stay local.
- 25th (2026-10-19): a live theme switch refills the default links plugins set once at load (utils/themes.lua); the
  right-click "Open in Web Browser" reaches 0.12's gx. Rulings: keymap options equal to a default stay (they pin the
  key); `fn.system` stays in the statusline's branch lookup and the bootstrap (`vim.system():wait()` runs the event
  loop inside a redraw).
- 24th (2026-10-16): typed tests made six upgrades keep the built-in (copilot's `<C-l>` through `trigger_on_accept =
  false`); markdown-plus's `gd` handed back. Rulings: an extra target (a date, true/false, a word pair) may take a key
  where the plugin recognises it, other input gets the built-in; visual `<Tab>` indents.
- 23rd (2026-10-15/16): notebooks kept out of snacks.bigfile (priority-1 `.*%.ipynb` rule) and of markdown-oxide,
  ruff through otter, conform on `:w`; 'shell' is sh and terminals run the login shell; libraries left
  `dependencies` (exceptions: blink keeps friendly-snippets, nvim-dap keeps dap-ui and dap-python); back to the
  built-ins: notebook `<S-CR>`, octo's `]s`/`[s` and `<leader>qa`, hardtime's block mode, pipetable's `auto_enter`, `q`
  in help, multicursor's `<M-LeftMouse>` and layer arrows. Ruling: a plugin's own window keys are listed, not moved.
  Declined: ui2 (experimental), vim.pack (no event, key or command loading), blink.pairs and fff.nvim (overlap
  nvim-autopairs and snacks.picker), jove.nvim (experimental, maps `[c`/`]c`).
- 22nd (2026-10-06): `<leader>cr` builds Makefile projects and lone files (`// 999rpm-flags:` lines).
- 21st (2026-10-03): tw-values only in jsx, tsx, html, css. Kept: rustaceanvim v9; multicursor's 1.0 branch.
- 20th: themes in `utils/themes.lua`; `lang/d2-diagrams.lua`, so no plugin file shares a basename with a util; a
  failing theme warns and keeps the last one.
- 19th: one `vim.lsp.enable()` call (each re-ran FileType). Declined: nvim-lightbulb (no room), ui2 (experimental).
- 18th: the projects layer under `<leader>w`; terminal mode maps no Alt keys; kept nvim-treesitter's queries over
  tree-sitter-manager.nvim; declined cmake-tools, vim-dadbod.
- 17th: previews scroll with `<M-j>`/`<M-k>` because `<C-b>` is tmux's prefix; package-info.nvim and vim-suda added.
- 16th: backups survive a failed write; `gO` in man pages and `<C-a>`/`<C-x>` in rebase lists returned.
- 15th: `gd` and normal `<C-k>` only where a server answers; gitcommit parser left out (its build exhausts 4 GB).
  Kept: nvim-treesitter, ts_ls, noice over ui2.
- 13th and 14th: molten-nvim (main) runs kernels, otter.nvim attaches servers to cells, the jupytext CLI converts
  (jupytext.nvim is unmaintained), `:JupyterSetup` prefers uv; quarto-nvim skipped; insert `,` `.` `;` undo breaks.
- 12th: local specs are `virtual = true` with slash-less names (lazy.nvim merged two `dir` specs);
  tiny-inline-diagnostic; vim-matchup replaces matchit and matchparen. Declined: kitty-scrollback, smart-splits,
  quicker.nvim, marks.nvim, nvim-treesitter-endwise, themery, virt-column, mini.trailspace, reference keymaps that take
  built-ins.
- 11th: the Logseq layer (markdown-oxide, notes helpers, markdown-plus, bullet folds); `<leader>n` notes.
- 10th: startup from 21 plugins to 11; snacks.words gives `]r`/`[r`; `<leader>o` holds toggles only.
- 9th: d2 replaced mermaid (one static binary); fourteen built-in keys returned: `;` `,` `q` `x` `X`,
  visual `p`, `<C-q>`, `H` `L`, `f` `F`, `s`, visual `S` `R`, `g]`, `<C-LeftMouse>`, `]f` `[f`, `zr`, command-line
  `<Left>` `<Right>` `<End>`; snacks.dashboard, `pick_win()` and snacks.bigfile replaced alpha, nvim-window-picker and
  a large-file autocmd.
- 1st to 8th: one picker (snacks.picker); barbar over bufferline; `plugins/loader.lua` (an `init.lua` went missing);
  mini.icons stands in for nvim-web-devicons; nf-md icons; coerce.nvim replaced text-case.nvim; `gd`/`gD` named through
  label-only which-key entries; mini.ai's next-object pair on `aN`/`iN`; `<C-a>`/`<C-x>`, `>`/`<` and insert `<C-e>`
  returned. Declined: sidekick.nvim, eyeliner.nvim, hydra.nvim, fidget.nvim, nvim-spider, nvim-navic, nvim-hlslens,
  terrastruct/d2-vim.

## Reference ledger

| Repository | Scan date | Default-branch HEAD | Result |
| --- | --- | --- | --- |
| rockerBOO/awesome-neovim | 2026-10-28 | 5a801eb3017f | 4 entries since pass 31: tmux-oil.nvim, ghost.nvim, matrix-splash.nvim, lumina-themes, all declined (pass 32) |
| wsdjeg/SpaceVim | 2026-10-28 | eed9d8f14951 | no commit since 2026-10-03 |
| jdhao/nvim-config | 2026-10-28 | c07f3c1e1b77 | no commit since 2026-10-20 |
| craftzdog/dotfiles-public | 2026-10-28 | bf2867469b8b | no commit since 2026-10-03 |
| xero/dotfiles | 2026-10-28 | 5204a2b74f9a | no commit since 2026-10-03 |
| rafi/vim-config | 2026-10-28 | dfc296925794 | no commit since 2026-10-15 |
| ecosse3/nvim | 2026-10-28 | 5d1e66db95b7 | no commit since 2026-10-03 |
| linkarzu/dotfiles-latest | 2026-10-28 | 0605224aec7d | 2 commits: OBS scene keys, a qmk.nvim layout autocmd for a ZMK keyboard; nothing for this config |
| nshen/learn-neovim-lua | 2026-10-28 | 0813be9206a1 | no commit since 2026-10-03 |
| yutkat/dotfiles | 2026-10-28 | 07583b0d81ac | 1 commit: a nushell Ctrl+A binding and lockfile bumps; no new plugin |
| Matt-FTW/dotfiles | 2026-10-28 | 0bcecd91cd93 | no commit since 2026-10-20; tsc in the backlog, markview.nvim declined (overlaps render-markdown) |
| wincent/wincent | 2026-10-28 | a1d582ea7d1f | 2 commits: Pi agent; no Neovim file |
| crivotz/nv-ide | 2026-10-28 | ebd4f35c3282 | no commit since 2026-10-03 |
| SeniorMars/dotfiles | 2026-10-28 | ea99c6844e1d | no commit since 2026-10-03 |
| folke/dot | 2026-10-28 | 10526a848771 | no commit since 2026-10-03 |
| Allaman/nvim | 2026-10-28 | d1188a5cdb9b | 1 commit: a CI action bump; no Neovim file |
| loctvl842/monokai-pro.nvim | 2026-10-28 | a68e38b8e55d | no commit since 2026-10-03; one of the four schemes |

## Backlog

| Deferred item | Source | Reason |
| --- | --- | --- |
| images under Neovide | neovim/neovim#41287 (`ext_images` UI events for `vim.ui.img`), open on 2026-10-24, stacked on #39496; `vim.ui.img` is not in 0.12.6 | re-check each pass; once a release and Neovide carry it, turn images back on there (neovide.lua, snacks.lua, molten.lua, utils/d2.lua) |
| jove.nvim for the notebook stack | awesome-neovim README@c578b193 | experimental; re-check when its README drops the warning |
| ShaDa tmp-file cleanup at startup (E138) | linkarzu/dotfiles-latest `neobean/lua/config/autocmds.lua`@fba7c6b | guards a crash-only failure |
| copy a selection as a fenced block with path:line | yutkat/dotfiles `rc/mappings.lua`@aab0608 | new feature, owner's call |
| noice.nvim activity | folke/noice.nvim, last commit 2025-11-03 | 12 months on 2026-11-03; ui2 once stable |
| 12 months without commits | vim-suda on 2026-10-29; trouble, harpoon 10-31; todo-comments 11-10 (upstream HEAD still the locked commit on 2026-10-28); which-key, persistence, boundary.nvim kept in pass 32 | no breakage known; log each as kept when it crosses, or switch to a maintained alternative (mini.clue for which-key) |
| lazy.nvim activity | folke/lazy.nvim, last commit 2025-12-17 | 12 months on 2026-12-17; vim.pack is the built-in |
| sc-im.nvim's deprecated calls | DAmesberger/sc-im.nvim `lua/sc-im/table.lua` | `termopen()`, `nvim_*_set_option()`; re-check at each Neovim release |
| tsc (TypeScript 7 native server) for ts_ls | Matt-FTW/dotfiles `typescript-extended.lua`@86fa51f, yutkat/dotfiles `mise/conf.d/neovim.toml`@15d340b | attaches only with TypeScript 7; adopt once the projects use it |
| fixed-colour defaults after a theme switch | crates.nvim, grug-far.nvim, csvview.nvim | set once at load as colours, not links; upstream would need a ColorScheme handler |
