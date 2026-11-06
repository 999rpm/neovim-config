# Config log

What changed and why, newest first. Older passes are condensed to their conclusions once a later pass confirms them.

## 2026-11-06 (thirty-fifth pass)

Method: Neovim 0.12.6, still the latest release (the stable tag peels to v0.12.6); the tree matched pass 34's manifest
and the lockfile was unchanged, so no plugin moved. The owner asked for a full checkup and for every plugin to work with
every other one: Scope full, so every in-scope file was read in full, and each pair of plugins that meets in a window,
an event, a key or an LSP request was checked against the installed plugins' docs and code. `p35-regressions.sh`
counts the rename requests of the two explorers with an in-process language server and checks each other hookup by
what reaches the screen or the server; the original tree fails 11 of its 14 checks, the final tree none.

### Fixed

- oil.nvim and snacks: an oil move asked the servers for import edits twice. oil's `lsp_file_methods` (on by default;
  stevearc/oil.nvim `lua/oil/config.lua`, `lua/oil/mutator/init.lua`) sends `workspace/willRenameFiles` before the
  move and `didRenameFiles` after it, and oil.lua's `OilActionsPost` handler sent both again through
  `Snacks.rename.on_rename_file`, so a server could apply the import edits a second time. The handler is gone. Test:
  two requests per move before, one after.
- neo-tree and snacks: `Snacks.rename.on_rename_file` calls `client.supports_method`, which 0.12 deprecates with a
  warning on its first use (folke/snacks.nvim `lua/snacks/rename.lua`, unchanged upstream since 2026-05-25;
  `vim.deprecate` in `runtime/lua/vim/_core/editor.lua`, removal in 0.13). neo-tree.lua sends the two notices with
  `client:` calls: `willRenameFiles` on neo-tree's `before_file_move` and `before_file_rename` events, so the edits
  come before the move as the protocol has it, and `didRenameFiles` on `file_moved` and `file_renamed`.
- neo-tree `w`: neo-tree's `open_with_window_picker` needs nvim-window-picker
  (`lua/neo-tree/sources/common/commands.lua`), which pass 9 replaced with snacks' `pick_win`, so `w` printed an
  install hint. `w` letters the file windows through `Snacks.picker.util.pick_win()`.
- overseer.nvim and nvim-dap: overseer adds its preLaunchTask and postDebugTask hook to nvim-dap only in
  `overseer.setup()` (`lua/overseer/init.lua`, `enable_dap`), and a debug key loaded nvim-dap without overseer, so a
  launch.json's preLaunchTask did not run. overseer.lua loads overseer on lazy.nvim's `User LazyLoad` event for
  nvim-dap (folke/lazy.nvim `doc/lazy.nvim.txt`, user events).
- copilot.lua and blink.cmp: copilot hides its suggestion only while the built-in popup menu is open, so the grey text
  stayed beside blink's list. copilot.lua sets `b:copilot_suggestion_hidden` on `BlinkCmpMenuOpen` and
  `BlinkCmpMenuClose`, the blink.cmp example of zbirenbaum/copilot.lua's README.
- render-markdown and avante.nvim: avante's README asks render-markdown to take the `Avante` filetype (`file_types`
  and `ft`); added, with tables rendered there through `overrides.filetype`, since markdown-pipetable serves markdown
  buffers only.
- Right-click menu: Find Todos raised "attempt to call field 'todo_comments'" until a file had been read, since
  todo-comments adds its picker source in its own setup (`lua/todo-comments/config.lua`). The item loads the plugin
  first.
- hex.nvim: the header promised that `nvim -b file` opens in hex view, but the plugin is lazy and its read hook
  (`lua/hex.lua`) did not exist when the file was read; it loads at startup when `-b` is in `v:argv`.
- treesitter.lua: `vim.treesitter.language.add()` returns nil without a parser instead of raising
  (`runtime/lua/vim/treesitter/language.lua`), so the start helper ran into `vim.treesitter.start()`'s error on every
  filetype without a parser; the result is checked first.

### Changed

- Neovide 0.17.2 (2026-11-04) leaves the strip below the last row plain by default (`neovide_fill_bottom_background`,
  neovide/neovide#3631, `website/docs/configuration.md` at 0.17.2), the backlog's condition: neovide.lua keeps the
  'cmdheight' 1 row only before 0.17.2 (`g:neovide_version`, which Neovide's `lua/init.lua` sets), so noice's hidden
  command line returns there. The replay (`p34-neovide.py`, `P34_VERSION`) passes as 0.17.1 (cmdheight 1) and as
  0.17.2 (cmdheight 0, noice's handlers, no message).
- Parsers install by themselves once mason-tool-installer has put the tree-sitter CLI on $PATH (`User
  MasonToolsUpdateCompleted`, WhoIsSethDaniel/mason-tool-installer.nvim README; seen in craftzdog/dotfiles-public
  `dot_config/nvim/lua/craftzdog/plugins/treesitter.lua`@447cc37); before, a first start without the CLI warned and
  waited for :TSUpdate.
- lualine's diff counts come from gitsigns' `b:gitsigns_status_dict` (nvim-lualine/lualine.nvim README, diff
  `source`; lewis6991/gitsigns.nvim `doc/gitsigns.txt`), so no second git diff runs per buffer, and unsaved edits
  count as gitsigns' signs show them.
- 'guicursor' takes 0.12's `sm` and `t` entries (`:help 'guicursor'`), so terminal mode keeps the blinking
  TermCursor block the custom value had dropped.
- hardtime leaves overseer's task list and codediff's file and commit lists alone, as it does the other list windows.
- `dm` calls `:delmarks` directly: every character the mapping admits is a valid argument (tested), so the `pcall`
  guarded nothing. autocmds.lua and utils/notebook.lua test `package.loaded.snacks` instead of `_G.Snacks` (selene's
  two global_usage findings).
- snacks.lua's key block lists `<A-f>` and `<A-r>`. The 21 comment lines past 120 columns (lint.py counts tabs as four
  columns) are wrapped, each key kept on the line of its action; lint.py's long-comment count is 0.
- harness: optdefaults.lua joins an assignment StyLua wrapped after its `=` (the new 'guicursor' line read as an
  error).

### Checked and kept

- Plugin pairs found integrated: blink.cmp with lazydev, render-markdown, crates, otter and markdown-oxide (sources or
  in-process servers), with the picker input (`b.completion = false`) and with noice's command line; noice's signature
  help off in favour of blink's, and snacks.notifier owning `vim.notify`; inc-rename through noice's preset; nvim-ufo
  with statuscol and 0.12's `foldingRange` client capability; catppuccin's `auto_integrations` and tokyonight's
  plugin detection, monokai-pro and kanagawa covering blink, snacks, noice, which-key and neo-tree; modicator taking
  lualine's mode colours; avante passing its own img-clip options; vim-matchup on the built-in treesitter;
  conform skipping graph pages, which logseq.lua marks; persistence firing barbar's SessionSavePre.
- hlargs beside LSP semantic tokens: its README has them coexist, the server's tokens winning where they exist.
- opencode's `ask()` prompt, enhanced only with snacks.input (opencode.nvim README, Integrations): snacks.input stays
  off, since noice draws every `vim.ui.input` prompt here; backlog, the owner's call. `:checkhealth opencode` warns
  about it.
- Declined: Kaiser-Yang/blink-cmp-avante (avante's mention and slash-command completion for blink; avante README,
  mcphub `doc/extensions/avante.md`): no commit since 2025-07-24, and new plugins get no maintenance exception.
  awesome-neovim@f57361a: LongYinStudio/suda.nvim (overlaps vim-suda, which works; first listed 2026-11-05),
  dotnet-counters.nvim (no .NET), nvim.setup (a whole config). mcphub's tools in avante went to the backlog.
- Reference deltas: linkarzu (sketchybar, a dictation app), yutkat (nushell loader, a mini.operators pin for Nightly):
  nothing for 0.12.6.
- Key audit: no SHADOW or STACK row in the terminal; under Neovide the six STACK rows are the `<C-S-c>`/`<C-S-v>`
  ruling of pass 31. Autocmds: 44 groups, 98 handlers (Neovide 45, 100), none twice. LuaLS 27 (oil.lua's argv cast
  fixed), selene 8 (LuaJIT's `\u{}` escapes), plugdefaults 16 SAME as before, optdefaults none, the two `dependencies`
  exceptions as logged.
- P4: two clean boots (103 plugins, 44 parsers; Mason's registry the only error); `:checkhealth` errors environmental,
  its deprecation list naming only mega.cmdparse's own health check (`vim.validate{}`, removal in 1.0); startup 68.0
  against 70.6 ms (median of five); the pass-24 to pass-35 steps and the typed upgrade tests pass; removal test 91
  files; zsh 5.9 and nu 0.116.1 matrices; edge cases; theme switch: the 11 logged groups. Skipped: kitty and Neovide
  (no display; the attach is replayed), linters (none installed). `p34-fixtures.sh` rebuilds the pass-34 fixtures,
  which lived in the unshipped scratch folder.
- Kept upgrades; `owner/repo` is https://github.com/owner/repo at the locked commit (README unless a file is named),
  "p28" the typed test written in pass 28 and rerun each pass (p35 included), other numbers the pass that ruled it:

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

- 34th (2026-11-04): Neovide 0.17.1 attaches with ext_messages and ext_cmdline until its first frame
  (startup-message-capture), so noice.lua sets noice up on the 'cmdheight' OptionSet of the hand-back, replayed by
  `p34-neovide.py`; neovide.lua's 'cmdheight' 1 row (since pass 35 only before 0.17.2). The E31 a second markdown
  FileType leaves in v:errmsg comes from 0.12.6's ftplugins. Declined: cheatsheet.nvim, intellij-formatter.nvim,
  nvim-md-preview, dotnet-tree.nvim; codediff's `explorer.line_stats`; the neovim#40290 fold workaround (nvim-ufo
  folds here); jdhao's animated LSP progress (noice).
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
| rockerBOO/awesome-neovim | 2026-11-06 | f57361aeac4b | 3 entries since pass 34, all declined (pass 35) |
| wsdjeg/SpaceVim | 2026-11-06 | eed9d8f14951 | no commit since 2026-10-03 |
| jdhao/nvim-config | 2026-11-06 | ca26c711ba1e | 1 commit: animated LSP progress; nothing adopted (pass 34) |
| craftzdog/dotfiles-public | 2026-11-06 | 7c50fa72f64a | parsers wait for Mason's tree-sitter-cli (adopted, pass 35); CC=gcc on Windows (backlog) |
| xero/dotfiles | 2026-11-06 | 5204a2b74f9a | no commit since 2026-10-03 |
| rafi/vim-config | 2026-11-06 | dfc296925794 | no commit since 2026-10-15 |
| ecosse3/nvim | 2026-11-06 | 5d1e66db95b7 | no commit since 2026-10-03 |
| linkarzu/dotfiles-latest | 2026-11-06 | 6b9319077b36 | 22 commits: sketchybar and a dictation app; no Neovim file |
| nshen/learn-neovim-lua | 2026-11-06 | 0813be9206a1 | no commit since 2026-10-03 |
| yutkat/dotfiles | 2026-11-06 | b5d55e160c68 | 4 commits: nushell loader, mini.operators pinned for Nightly; nothing for 0.12.6 |
| Matt-FTW/dotfiles | 2026-11-06 | 0bcecd91cd93 | no commit since 2026-10-20; tsc in the backlog, markview.nvim declined (overlaps render-markdown) |
| wincent/wincent | 2026-11-06 | 3c6b10681992 | 7 commits: kitty.conf for kitty 0.50, his shannon link opener, Pi logs; nothing to adopt |
| crivotz/nv-ide | 2026-11-06 | ebd4f35c3282 | no commit since 2026-10-03 |
| SeniorMars/dotfiles | 2026-11-06 | ea99c6844e1d | no commit since 2026-10-03 |
| folke/dot | 2026-11-06 | 10526a848771 | no commit since 2026-10-03 |
| Allaman/nvim | 2026-11-06 | 582423f3a8e0 | 1 commit: a CI action bump; no Neovim file |
| loctvl842/monokai-pro.nvim | 2026-11-06 | a68e38b8e55d | no commit since 2026-10-03; one of the four schemes |

## Backlog

| Deferred item | Source | Reason |
| --- | --- | --- |
| images under Neovide | neovim/neovim#41287 (`ext_images` UI events for `vim.ui.img`), open on 2026-11-04 (no image event in master's `ui_events.in.h`; `vim.ui.img` is not in 0.12.6) | re-check each pass; once a release and Neovide carry it, turn images back on there (neovide.lua, snacks.lua, molten.lua, utils/d2.lua) |
| jove.nvim for the notebook stack | awesome-neovim README@c578b193 | experimental; re-check when its README drops the warning |
| ShaDa tmp-file cleanup at startup (E138) | linkarzu/dotfiles-latest `neobean/lua/config/autocmds.lua`@fba7c6b | guards a crash-only failure |
| copy a selection as a fenced block with path:line | yutkat/dotfiles `rc/mappings.lua`@aab0608 | new feature, owner's call |
| 12 months without commits | todo-comments on 2026-11-10, mega.cmdparse 11-28, nvim-dap-python 12-20, dial.nvim 12-21 (upstream HEAD still the locked commit on 2026-11-03); vim-suda, harpoon, trouble, noice kept in pass 33 (noice until ui2 leaves experimental); which-key, persistence, boundary.nvim kept in pass 32 | no breakage known; log each as kept when it crosses, or switch to a maintained alternative (mini.clue for which-key) |
| lazy.nvim activity | folke/lazy.nvim, last commit 2025-12-17 | 12 months on 2026-12-17; vim.pack is the built-in |
| sc-im.nvim's deprecated calls | DAmesberger/sc-im.nvim `lua/sc-im/table.lua` | `termopen()`, `nvim_*_set_option()`; re-check at each Neovim release |
| tsc (TypeScript 7 native server) for ts_ls | Matt-FTW/dotfiles `typescript-extended.lua`@86fa51f, yutkat/dotfiles `mise/conf.d/neovim.toml`@15d340b | attaches only with TypeScript 7; adopt once the projects use it |
| mcphub's tools in avante | ravitemer/mcphub.nvim `doc/extensions/avante.md` (system_prompt, custom_tools) | avante's own file and bash tools and mcphub's neovim server overlap; the docs ask for one set to be disabled, the owner's call |
| snacks.input for opencode's `ask()` (placeholder completion and highlights) | NickvanDyke/opencode.nvim README, Integrations | would move every `vim.ui.input` prompt from noice's command-line popup to snacks' input window; the owner's call |
| CC=gcc for parser builds on Windows without MSVC | craftzdog/dotfiles-public `dot_config/nvim/lua/craftzdog/plugins/treesitter.lua`@7c50fa7 | the tree-sitter CLI's compiler choice on Windows is unconfirmed here (no Windows host) |
| fixed-colour defaults after a theme switch | crates.nvim, grug-far.nvim, csvview.nvim | set once at load as colours, not links; upstream would need a ColorScheme handler |
