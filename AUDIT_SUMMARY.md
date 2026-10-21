# Config log

What changed and why, newest first. Older passes are condensed to their conclusions once a later pass confirms them.

## 2026-10-20 (twenty-seventh pass)

Method: Neovim 0.12.6, still the latest release (`stable` tag); the tree matched pass 26's manifest file for file and
the lockfile was unchanged, so no plugin moved and only the file the lint flagged (init.lua) was read in full. The
archived harness did not run: the session's safety check refuses scripts from an uploaded archive, so each script used
was reviewed and written again. lint.py now also takes its deprecated-call patterns from the runtime's
`deprecated.txt` (102 of 138), and the key audit finds the `index.txt` sections by their tags.

### Fixed

- README's Install section had the first start clone lazy.nvim at the locked commit; the bootstrap clones its `stable`
  branch (`config/lazy.lua`; the clean boot recorded 85c7ff3 for the locked 306a055), as the edge-case note on
  `:Lazy restore` already said. The sentence now says so. No config code needed a fix: every check came back as in
  pass 26.

### Changed

- None.

### Checked and kept

- Kept upgrades; `owner/repo` is https://github.com/owner/repo at the locked commit (README unless a file is named),
  "p27" a test this pass, other numbers the pass that ruled it:

| Key (mode) | Mapping | Preserved | Gained | Source; test |
| --- | --- | --- | --- | --- |
| `n` `N` (n) | `nzzzv` | jump, count | centred, fold opened | `:help zz`; p27 |
| `<Esc>` (n) | `:nohlsearch` | cancels a count or register | search highlight cleared | `:help index`; p27 `3<Esc>j` |
| `grn` (n) | inc-rename | rename at cursor | live preview | smjonas/inc-rename.nvim; p27 TUI |
| `gd` `gD` (n) | LSP | built-in without a server or an answer | server's answer | `:help vim.lsp.buf_request_all()`; p27 |
| `]c` `[c` (n) | gitsigns | built-in in diff mode, count | hunks | lewis6991/gitsigns.nvim `doc/gitsigns.txt`; p27 |
| `]m` `[m` `]M` `[M` (n, x) | textobjects | built-in without a parser, count | any parsed language | nvim-treesitter/nvim-treesitter-textobjects; p27 |
| `zR` `zM` (n) | nvim-ufo | open, close all | provider folds | kevinhwang91/nvim-ufo; p27 |
| `<C-a>` `<C-x>` (n) | dial.nvim | numbers, count, `.` | dates, true/false | monaqa/dial.nvim; p27, 30 cases |
| `%` `g%` `[%` `]%` `a%` `i%` (n, x, o) | vim-matchup | brackets, `N%` | word pairs, tags | andymass/vim-matchup; p27 |
| `a` `i` (x, o) | mini.ai | `iw` `a(` `i"` `ap` `as` `it`, counts | more objects, next/last | nvim-mini/mini.nvim `doc/mini-ai.txt`; p27 |
| `K` (n, Rust) | rustaceanvim | built-in without rust-analyzer, count | hover actions | mrcjkb/rustaceanvim; p27 |
| `gf` `<C-w>f` (n, graph) | logseq.lua | path under cursor, count | links, block refs | `notes/logseq.lua`; p27 |
| `<BS>` `<CR>` (i) | nvim-autopairs | delete, line break | pairs | windwp/nvim-autopairs; p27 |
| `o` `O` (n), `<CR>` `<Tab>` `<S-Tab>` `<BS>` (i) | markdown-plus | outside a list | list items | YousefHadder/markdown-plus.nvim; p27 |
| `<LeftMouse>` (n) | satellite.nvim | click | scrollbar drag | lewis6991/satellite.nvim; p27 TUI |
| `<Tab>` `<CR>` `<C-e>` `<C-k>` (i) | blink.cmp | `fallback` without menu | completion | saghen/blink.cmp keymap docs; p27 |
| `<C-l>` (i) | copilot.lua | popup-menu CTRL-L, `<C-x><C-l>`, no suggestion | suggestion accepted | zbirenbaum/copilot.lua; `:help ins-completion`; p27 |
| `<Tab>` `<S-Tab>` `<C-n>` `<C-p>` `<C-e>` `<C-y>` (c) | blink.cmp | built-in where Neovim has no completion, or with no menu | fuzzy menu | saghen/blink.cmp `keymap/presets.lua`; p27 TUI |
| `,` `.` `;` (i) | `<C-g>u` | text, `.` repeat | undo per clause | `:help i_CTRL-G_u`; 13, p27 |
| `<Left>` `<Right>` (i) | multicursor | built-in with one cursor | one insert per cursor set | jake-stewart/multicursor.nvim `core.lua`; p27 |

- hardtime.nvim's 55 pass-through keys give the built-in result (20 typed cases, p27); `Y` runs 0.12's default `y$`.
- Key audit (p27): no shadowed built-in outside the table, the pass-through keys and 26 quickfix window keys; no key on
  kitty's alt+digit or ctrl+shift keys, tmux's C-b or a shell key in terminal mode; no key defined twice. Autocmd audit:
  42 groups, 99 handlers, none registered twice. Lint: no deprecated call, comment, voice, header or util finding; the
  two `dependencies` lists are the logged exceptions; plugdefaults' 16 same-path matches are pinned keys (copilot,
  neo-tree) or other tables (snacks' per-source matchers, lualine's buffers component, a render-markdown preset,
  lspconfig's docs block).
- Ruling: init.lua's "Keys:" paragraph is the key hierarchy summary its header owes, not a plugin key list; the lint's
  `gap.keys-line` rule now checks plugin headers only.
- `E31` in `v:errmsg` after the first file opens: the markdown ftplugin's undo (a silent `nunmap` of `]]`) runs again
  when lazy.nvim replays the read events; upstream, not this config. LuaLS's 28 warnings are stdlib type strictness;
  selene's 9 are `\u{...}` escapes, which LuaJIT reads, and `_G` existence checks.
- P4: two clean boots (103 plugins, 44 parsers); the only install error is Mason's unreachable registry (avante's
  build now finds its v0.4.1 libraries). `:checkhealth` errors all environmental, as in pass 26 (Mason registry,
  opencode, rust-analyzer, img-clip's clipboard, kitty graphics, gs, lazygit, locale, yazi's check without yazi;
  mega.cmdparse calls the deprecated `vim.validate{}`). Startup within noise on identical Lua (medians 99.6 and 96.7
  ms over five runs, 94.8 and 86.6 over 21). Upgrades: 107 typed cases and 6 logged gains, `grn` and the mouse in the
  TUI, basedpyright's `gd`/`gD`. 91 files in the removal test; the dependency exceptions still needed; the shell
  matrix under zsh 5.9 and the nushell smoke set under nu 0.116.1; edge cases as in pass 25, plus a TUI start inside
  tmux. Skipped: kitty (no GUI), linters (none installed).
- Research: jdhao/nvim-config and yutkat/dotfiles moved (ledger), nothing to adopt; awesome-neovim unchanged since
  pass 26. Plugins near or past a year without commits have their upstream HEAD at the locked commit (backlog).
- Kept despite a year without commits (upstream dates): sc-im.nvim 2024-03, promise-async 2024-08, mega.logging
  2025-02, guess-indent 2025-03, nvim-dap-virtual-text 2025-05, tw-values.nvim 2025-10; no breakage known.

## Earlier passes: conclusions only

- 26th (2026-10-20): `<leader>nX` cancels (logseq.lua's key builder counts leading nils with `select("#", ...)`);
  `2<C-w>f` passes its count to `wincmd f`; the right-click Trouble item is disabled without `:Trouble`; dropped as dead
  or restated: basedpyright's `tagSupport`, noice's "search hit BOTTOM" route ('shortmess' s), `modeline` under sudo,
  snacks' `words.debounce`, `notifier.timeout` and indent defaults, rustaceanvim's `enable_clippy`; `:autocmd 999rpm-*`
  (E216) comments name the `<leader>sa` picker. Rulings: plugin files call `Snacks` only in handlers and events; the
  key-handler builders of logseq, molten, sc-im and colorschemes stay local (one module each).
- 25th (2026-10-19): a live theme switch refills the default links plugins set once at load (utils/themes.lua); the
  right-click "Open in Web Browser" is an `amenu`, reaching 0.12's gx; dead options dropped (grug-far's
  `headerMaxWidth`, trouble's `win.border`, lazy.nvim's `dev.path`); basedpyright leaves `useLibraryCodeForTypes` to
  pyproject.toml; 40 specs lost restated defaults. Rulings: keymap options equal to a default stay (they pin the key);
  sc-im.nvim stays (not archived; deprecated calls still present); `fn.system` stays in the statusline's branch lookup
  and the bootstrap (`vim.system():wait()` would run the event loop inside a redraw).
- 24th (2026-10-16): typed tests made the upgrades keep the built-in (dial, rustaceanvim's `K`, logseq's `2gf`,
  lspconfig's `gd`/`gD`, blink's command-line `<Tab>`, copilot's `<C-l>` with `trigger_on_accept = false`);
  markdown-plus's `gd` handed back. Rulings: an extra target (a date, true/false, a word pair) may take a key where the
  plugin recognises it, other input gets the built-in; visual `<Tab>` indents.
- 23rd (2026-10-15/16): notebooks: a priority-1 `.*%.ipynb` rule keeps converted ones out of snacks.bigfile, ruff's
  diagnostics reach otter after each change, markdown-oxide stays out, `:w` runs conform's injected formatter,
  `ipython/outlined_tables.py` boxes DataFrames; 'shell' is sh and terminals run the login shell; libraries left
  `dependencies` (exceptions: blink keeps friendly-snippets, nvim-dap keeps dap-ui and dap-python); back to the
  built-ins: notebook `<S-CR>`, octo's `]s`/`[s` and `<leader>qa`, hardtime's block mode, pipetable's `auto_enter`, `q`
  in help, multicursor's `<M-LeftMouse>` and layer arrows. Ruling: a plugin's own window keys are listed, not moved.
  Declined: ui2 (experimental), vim.pack (no event, key or command loading), blink.pairs and fff.nvim (overlap
  nvim-autopairs and snacks.picker), jove.nvim (experimental, maps `[c`/`]c`).
- 22nd (2026-10-06): `<leader>cr` builds Makefile projects (`make`, then `run`, after writing their buffers) and lone
  files with their `// 999rpm-flags:` lines; generated Makefiles depend on themselves and the headers.
- 21st (2026-10-03): notebooks write into missing folders; zsh and nushell load fzf, zoxide, starship and broot only
  when installed; tmux.conf ships as the matugen template; tw-values only in jsx, tsx, html, css. Kept: rustaceanvim
  v9; multicursor's 1.0 branch.
- 20th: themes in `utils/themes.lua`; `lang/d2-diagrams.lua`, so no plugin file shares a basename with a util; a
  failing theme warns and keeps the last one.
- 19th: nvim-treesitter's parser hook builds d2; `'secure'` dropped; one `vim.lsp.enable()` call (each re-ran
  FileType); tmux truecolour from `terminal-features RGB`. Declined: nvim-lightbulb (no room), ui2 (experimental).
- 18th: the projects layer under `<leader>w`; terminal mode maps no Alt keys; kept nvim-treesitter's queries over
  tree-sitter-manager.nvim; declined cmake-tools, vim-dadbod.
- 17th: `lua/utils/` with one module per subject; 0.12's folding capabilities; previews scroll with `<M-j>`/`<M-k>`
  because `<C-b>` is tmux's prefix; package-info.nvim and vim-suda added.
- 16th: backups survive a failed write; `gO` in man pages, `<C-a>`/`<C-x>` in rebase lists returned.
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
  mini.icons stands in for nvim-web-devicons; nf-md icons; coerce.nvim replaced text-case.nvim; `gd`/`gD` named through label-only which-key entries; mini.ai's next-object pair on
  `aN`/`iN`; `<C-a>`/`<C-x>`, `>`/`<` and insert `<C-e>` returned. Declined: sidekick.nvim, eyeliner.nvim, hydra.nvim,
  fidget.nvim, nvim-spider, nvim-navic, nvim-hlslens, terrastruct/d2-vim.

## Reference ledger

| Repository | Scan date | Default-branch HEAD | Result |
| --- | --- | --- | --- |
| rockerBOO/awesome-neovim | 2026-10-20 | 54ae5f6ada9e | 3 entries: partial-diff.nvim, jisho.nvim, resonance.nvim; declined |
| wsdjeg/SpaceVim | 2026-10-20 | eed9d8f14951 | no commit since 2026-10-03 |
| jdhao/nvim-config | 2026-10-20 | c07f3c1e1b77 | 1 commit: oxocarbon removed, a scheme not used here; nothing to adopt |
| craftzdog/dotfiles-public | 2026-10-20 | bf2867469b8b | no commit since 2026-10-03 |
| xero/dotfiles | 2026-10-20 | 5204a2b74f9a | no commit since 2026-10-03 |
| rafi/vim-config | 2026-10-20 | dfc296925794 | no commit since 2026-10-15 |
| ecosse3/nvim | 2026-10-20 | 5d1e66db95b7 | no commit since 2026-10-03 |
| linkarzu/dotfiles-latest | 2026-10-20 | df62cb73fd1b | 9 commits; a task-order tweak in its snacks.lua; nothing to adopt |
| nshen/learn-neovim-lua | 2026-10-20 | 0813be9206a1 | no commit since 2026-10-03 |
| yutkat/dotfiles | 2026-10-20 | 3c469bfb7268 | 4 commits: nushell, nix, zsh; lockfile bumps, no plugin added; nothing to adopt |
| Matt-FTW/dotfiles | 2026-10-20 | 0bcecd91cd93 | tsc for TypeScript (backlog), markview.nvim (overlaps render-markdown) |
| wincent/wincent | 2026-10-20 | 28a511dd74d8 | 8 commits: tests, CI, Hammerspoon; no Neovim file |
| crivotz/nv-ide | 2026-10-20 | ebd4f35c3282 | no commit since 2026-10-03 |
| SeniorMars/dotfiles | 2026-10-20 | ea99c6844e1d | no commit since 2026-10-03 |
| folke/dot | 2026-10-20 | 10526a848771 | no commit since 2026-10-03 |
| Allaman/nvim | 2026-10-20 | d62ecf5aa010 | no commit since 2026-10-03 |
| loctvl842/monokai-pro.nvim | 2026-10-20 | a68e38b8e55d | no commit since 2026-10-03; one of the four schemes |

## Backlog

| Deferred item | Source | Reason |
| --- | --- | --- |
| jove.nvim for the notebook stack | awesome-neovim README@c578b193 | experimental; re-check when its README drops the warning |
| ShaDa tmp-file cleanup at startup (E138) | linkarzu/dotfiles-latest `neobean/lua/config/autocmds.lua`@fba7c6b | guards a crash-only failure |
| copy a selection as a fenced block with path:line | yutkat/dotfiles `rc/mappings.lua`@aab0608 | new feature, owner's call |
| noice.nvim activity | folke/noice.nvim, last commit 2025-11-03 | 12 months on 2026-11-03; ui2 once stable |
| 12 months without commits by 2026-11-10 | which-key, persistence, trouble, todo-comments (folke), boundary.nvim, vim-suda, harpoon | no breakage known; log each as kept when it crosses, or switch to a maintained alternative (mini.clue for which-key) |
| lazy.nvim activity | folke/lazy.nvim, last commit 2025-12-17 | 12 months on 2026-12-17; vim.pack is the built-in |
| sc-im.nvim's deprecated calls | DAmesberger/sc-im.nvim `lua/sc-im/table.lua` | `termopen()`, `nvim_*_set_option()`; re-check at each Neovim release |
| tsc (TypeScript 7 native server) for ts_ls | Matt-FTW/dotfiles `typescript-extended.lua`@86fa51f, yutkat/dotfiles `mise/conf.d/neovim.toml`@15d340b | attaches only with TypeScript 7; adopt once the projects use it |
| fixed-colour defaults after a theme switch | crates.nvim, grug-far.nvim, csvview.nvim | set once at load as colours, not links; upstream would need a ColorScheme handler |
