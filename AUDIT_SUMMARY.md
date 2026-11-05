# Config log

What changed and why, newest first. Older passes are condensed to their conclusions once a later pass confirms them.

## 2026-11-04 (thirty-fourth pass)

Method: Neovim 0.12.6, still the latest release; the tree matched pass 33's manifest, the lockfile unchanged. One
owner issue, noice's two errors when Neovide starts, reproduced by replaying Neovide 0.17.1's attach over RPC from its
source (`p34-neovide.py`; Neovide cannot run here). The owner's request for a deep check of the phase was read
as a deep check of the GUI path. Script and runtime checks ran on every file; touched files were read in full.

### Fixed

- Neovide (owner): 0.17.1 (2026-10-31) attaches with `ext_messages`, and so `ext_cmdline`, until its first frame
  (`startup-message-capture`, on by default; neovide/neovide `src/bridge/mod.rs`, `src/bridge/ui_commands.rs`,
  `website/docs/command-line-reference.md` at 0.17.1). noice reads `nvim_list_uis()` once, at setup: it raised the two
  errors and dropped its command-line and message handlers (folke/noice.nvim `lua/noice/health.lua`,
  `lua/noice/ui/init.lua`), so `:` and messages fell back to the built-ins and Neovide's replay of a startup
  message stopped at a hit-enter prompt. noice.lua sets noice up once no UI externalizes either: at once in a
  terminal, inside Neovide on the 'cmdheight' `OptionSet` of its hand-back. neovide.lua puts 'cmdheight' back to 1
  whenever noice's `ui_attach` zeroes it (`:help ui-messages`; neovim/neovim `src/nvim/ui.c` `ui_refresh()`). Test:
  `p34-regressions.sh`, capture on and off: the original tree fails, the fix passes.

### Checked and kept

- Deep check: of the installed plugins only noice reacts to a GUI's `ext_*` options; 19 fixture filetypes open
  silently under the GUI attach, capture on and off, and in the tmux TUI (`p34-ft.lua`); `:checkhealth noice` under the
  GUI is clean. The E31 a second markdown FileType leaves in `v:errmsg` comes from Neovim 0.12.6's ftplugins,
  which unmap `]]` and `[[` twice in `b:undo_ftplugin`, under `--clean` too.
- Key audit, autocmds, LuaLS (28), selene (10), plugdefaults (16 SAME), the two `dependencies` exceptions: as in
  pass 33; under Neovide 45 groups, 99 handlers (the new 'cmdheight' one), none twice.
- P4: two clean boots (103 plugins, 44 parsers; Mason's registry the only error); `:checkhealth` errors environmental;
  startup 63.7 against 66.1 ms over 21 interleaved runs (spec loading 51.5 against 51.4 ms); the pass-24 to pass-34
  steps and typed upgrade tests pass; removal test 91 files; zsh 5.9 and nu 0.116.1 full matrices (utils/core.lua
  changed); edge cases; theme switch: the 11 logged groups. Skipped: kitty and Neovide (no display; the attach is
  replayed), linters (none installed).
- Declined (awesome-neovim b13df95): cheatsheet.nvim (Telescope; which-key), intellij-formatter.nvim (IntelliJ;
  conform), nvim-md-preview (live-preview.nvim), dotnet-tree.nvim (no .NET); craftzdog@0fccf79: codediff's
  `explorer.line_stats` (extra Git queries, codediff README), the neovim#40290 fold workaround (0.12.6's
  `_fold.lua` drops fold state on BufUnload; nvim-ufo folds here); jdhao's animated LSP progress (noice).
- Kept upgrades; `owner/repo` is https://github.com/owner/repo at the locked commit (README unless a file is named),
  "p28" the typed test written in pass 28 and rerun each pass (p34 included), other numbers the pass that ruled it:

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

## Earlier passes: conclusions only

- 33rd (2026-11-03): `<leader>wp` loads the session, then the files picker unless a window shows a project file;
  'cmdheight' 1 in Neovide (0.17 fills the strip below the last row). Kept despite a year without commits: vim-suda,
  harpoon, trouble.nvim, noice.nvim (ui2 experimental). Declined: vimdojo, markdown-preview.nvim,
  gruber-darker-renaissance, heritage-themes.nvim, dbt-ft.nvim, earlgrey.nvim; jdhao's `--color=never` in 'grepprg',
  mini.diff signs.
- 32nd (2026-10-28): projects picker in its input; saving a Makefile with a `compile_flags.txt:` rule runs it; C
  template `-std=gnu17` (c17 hides strdup); colorful-winsep off under Neovide (shadowed separator floats). Kept
  despite a year without commits: which-key, persistence, boundary.nvim. Declined: tmux-oil.nvim, ghost.nvim,
  matrix-splash.nvim, lumina-themes.
- 31st (2026-10-24): Windows and macOS: undo exclusions through `vim.fs.normalize()` (autocmd patterns are literal),
  'shell' sh only off Windows, `.exe` names, avante's `Build.ps1`; `config/neovide.lua` (font, macOS Meta, text size,
  clipboard); snacks.image, snacks.scroll and molten's images off in Neovide. Rulings: `<C-S-c>`/`<C-S-v>` only
  inside Neovide, beyond kitty's reach; `i_CTRL-SHIFT-V` and `c_CTRL-SHIFT-V` stay built-in. Declined: stylepeek.nvim.
- 30th (2026-10-23): no change; sprout.nvim declined (a start-screen ornament beside snacks.dashboard); kept despite
  a year without commits: sc-im.nvim, promise-async, mega.logging, guess-indent, nvim-dap-virtual-text, tw-values.nvim.
- 28th and 29th (2026-10-22): cell buffers get their own basedpyright (the notebook's folder as root, the project's
  `.venv`) and kernels start in the notebook's folder; ruff ignores I001 and N999 in `*.otter.*`; hidden cell buffers
  stay out of the diagnostics lists; `<leader>sn` is the notification history. Rulings: a second notebook keeps its
  own kernel (`<name>_1`), as in JupyterLab; snacks' HTML image query stays.
- 26th and 27th (2026-10-20): `<leader>nX` cancels; `2<C-w>f` keeps its count; the right-click Trouble item is off
  without `:Trouble`; README's Install names lazy.nvim's `stable` clone. Rulings: plugin files call `Snacks` only in
  handlers and events; the key-handler builders of logseq, molten, sc-im and colorschemes stay local; init.lua's
  "Keys:" paragraph is the key hierarchy summary.
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
| rockerBOO/awesome-neovim | 2026-11-04 | b13df95dc3af | 4 entries since pass 33, all declined (pass 34) |
| wsdjeg/SpaceVim | 2026-11-04 | eed9d8f14951 | no commit since 2026-10-03 |
| jdhao/nvim-config | 2026-11-04 | ca26c711ba1e | 1 commit: animated LSP progress; nothing adopted (pass 34) |
| craftzdog/dotfiles-public | 2026-11-04 | 0fccf79af21b | history rewritten; codediff options, a neovim#40290 fold workaround; nothing adopted (pass 34) |
| xero/dotfiles | 2026-11-04 | 5204a2b74f9a | no commit since 2026-10-03 |
| rafi/vim-config | 2026-11-04 | dfc296925794 | no commit since 2026-10-15 |
| ecosse3/nvim | 2026-11-04 | 5d1e66db95b7 | no commit since 2026-10-03 |
| linkarzu/dotfiles-latest | 2026-11-04 | 5eaf6db7f969 | 3 commits: OBS scene keys, an skhd keycode; no Neovim file |
| nshen/learn-neovim-lua | 2026-11-04 | 0813be9206a1 | no commit since 2026-10-03 |
| yutkat/dotfiles | 2026-11-04 | 5881179218ce | 4 commits: unused app and plugin configs removed; no new plugin |
| Matt-FTW/dotfiles | 2026-11-04 | 0bcecd91cd93 | no commit since 2026-10-20; tsc in the backlog, markview.nvim declined (overlaps render-markdown) |
| wincent/wincent | 2026-11-04 | 3c6b10681992 | 7 commits: kitty.conf for kitty 0.50, his shannon link opener, Pi logs; nothing to adopt |
| crivotz/nv-ide | 2026-11-04 | ebd4f35c3282 | no commit since 2026-10-03 |
| SeniorMars/dotfiles | 2026-11-04 | ea99c6844e1d | no commit since 2026-10-03 |
| folke/dot | 2026-11-04 | 10526a848771 | no commit since 2026-10-03 |
| Allaman/nvim | 2026-11-04 | 582423f3a8e0 | 1 commit: a CI action bump; no Neovim file |
| loctvl842/monokai-pro.nvim | 2026-11-04 | a68e38b8e55d | no commit since 2026-10-03; one of the four schemes |

## Backlog

| Deferred item | Source | Reason |
| --- | --- | --- |
| images under Neovide | neovim/neovim#41287 (`ext_images` UI events for `vim.ui.img`), open on 2026-11-04 (no image event in master's `ui_events.in.h`; `vim.ui.img` is not in 0.12.6) | re-check each pass; once a release and Neovide carry it, turn images back on there (neovide.lua, snacks.lua, molten.lua, utils/d2.lua) |
| jove.nvim for the notebook stack | awesome-neovim README@c578b193 | experimental; re-check when its README drops the warning |
| ShaDa tmp-file cleanup at startup (E138) | linkarzu/dotfiles-latest `neobean/lua/config/autocmds.lua`@fba7c6b | guards a crash-only failure |
| copy a selection as a fenced block with path:line | yutkat/dotfiles `rc/mappings.lua`@aab0608 | new feature, owner's call |
| 12 months without commits | todo-comments on 2026-11-10, mega.cmdparse 11-28, nvim-dap-python 12-20, dial.nvim 12-21 (upstream HEAD still the locked commit on 2026-11-03); vim-suda, harpoon, trouble, noice kept in pass 33 (noice until ui2 leaves experimental); which-key, persistence, boundary.nvim kept in pass 32 | no breakage known; log each as kept when it crosses, or switch to a maintained alternative (mini.clue for which-key) |
| Neovide's bottom background fill off by default | neovide/neovide#3631, on main 2026-11-04, after 0.17.1 | once a release carries it, neovide.lua's 'cmdheight' 1 can go |
| lazy.nvim activity | folke/lazy.nvim, last commit 2025-12-17 | 12 months on 2026-12-17; vim.pack is the built-in |
| sc-im.nvim's deprecated calls | DAmesberger/sc-im.nvim `lua/sc-im/table.lua` | `termopen()`, `nvim_*_set_option()`; re-check at each Neovim release |
| tsc (TypeScript 7 native server) for ts_ls | Matt-FTW/dotfiles `typescript-extended.lua`@86fa51f, yutkat/dotfiles `mise/conf.d/neovim.toml`@15d340b | attaches only with TypeScript 7; adopt once the projects use it |
| fixed-colour defaults after a theme switch | crates.nvim, grug-far.nvim, csvview.nvim | set once at load as colours, not links; upstream would need a ColorScheme handler |
