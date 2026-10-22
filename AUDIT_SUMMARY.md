# Config log

What changed and why, newest first. Older passes are condensed to their conclusions once a later pass confirms them.

## 2026-10-22 (twenty-eighth pass)

Method: Neovim 0.12.6, still the latest release (`stable` tag); the tree matched pass 27's manifest and the lockfile was
unchanged, so no plugin moved and the reads went to the files behind the four owner-reported issues. The archived
harness ran after each script was read. Each issue was reproduced on the original tree in a uv package project (src
layout, editable install, ruff selecting the isort and pep8-naming rules), fixed and retested; the tests joined the
harness (`p28-*`). Research: three repositories moved, nothing to adopt; awesome-neovim unchanged; tell list refreshed.

### Fixed

- Notebook imports (owner): basedpyright left `import hfpy_utils` beside `src/swimclub/Charts.ipynb` unresolved: the
  editable install puts `src/` on the search path, which turns off pyright's parent-folder fallback. otter.lua adds the
  notebook's folder to basedpyright's `extraPaths` once the server attaches to a hidden cell buffer
  (docs.basedpyright.com, language-server settings; p28-notebook-lsp).
- Kernel folder: kernels started in the folder Neovim had when molten's Python host started (jupyter_client's
  LocalProvisioner takes `Path.cwd()`). A `MoltenInitPre` handler and `<leader>kr` write the buffer's folder to a
  per-instance file (`$_999RPM_KERNEL_CWD`) and `ipython/outlined_tables.py` moves the kernel there, as JupyterLab
  starts kernels in the notebook's folder (p28-kernel).
- Ruff in cells (owner): N999 (`Charts.ipynb.otter` is no module name) and I001 (blank lines stand in for the markdown
  between cells) came from otter's hidden file. ruff gets an inline `extend-per-file-ignores` for `*.otter.*`; a plain
  file keeps the project's I001 (https://docs.astral.sh/ruff/editors/settings/, inline `configuration` since 0.9.8;
  p28-notebook-lsp).
- Hidden cell buffers listed twice (owner): Trouble's diagnostics mode, snacks' diagnostics picker and `<leader>dw`
  leave `*.otter.*` buffers out (`utils/notebook.lua` `is_cell_buffer`; trouble.nvim `docs/filter.md`, snacks.nvim
  `filter.filter`).
- `swimclub_1` (owner): molten's id for a second instance of a kernelspec (`molten/__init__.py`). `MoltenDeinitPost`
  fires for the current buffer, so deleting another notebook's buffer cleared this one's kernel name and `<leader>kc`
  started a second kernel. The handler re-reads every buffer's kernels from molten, and `utils/notebook.lua` asks molten
  before starting one. Ruling: a second notebook keeps its own kernel, as in JupyterLab (p28-kernel).
- Leader without which-key, `<20>` shown (owner): which-key drops its triggers while a macro records (`state.lua`,
  RecordingEnter) and noice skips `msg_showmode`, so "recording @q" showed nowhere. lualine's mode block shows
  `recording @<register>` (p28-macro-tui).
- Image error in index.html (owner): the popup came from `vim.notify`, which snacks.notifier owns, so `<leader>sn` (now
  "Notification history") lists it; `<leader>sm`'s comment claimed notifications too (p28-notify). Cause: swimclub.py
  writes `<svg>` where `</svg>` belongs, and ImageMagick's delegate, inkscape, aborted with `Gio::DBus::Error`. Ruling:
  snacks' HTML image query stays.

### Changed

- None beyond the fixes.

### Checked and kept

- Kept upgrades; `owner/repo` is https://github.com/owner/repo at the locked commit (README unless a file is named),
  "p28" a test this pass, other numbers the pass that ruled it:

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

- Key audit (p28): no shadowed built-in outside the table, hardtime's 55 pass-through keys and 26 quickfix window keys;
  no key on kitty's, tmux's or a shell's keys; none defined twice. Autocmds: 43 groups, 103 handlers, none twice. Lint
  clean; the two `dependencies` lists stay logged exceptions; plugdefaults as in pass 27.
- Upgrades (p28): 107 typed cases and 6 logged gains; `grn`, the mouse and command-line keys in the TUI.
- P4: two clean boots (103 plugins, 44 parsers; Mason's registry the only install error); `:checkhealth` errors
  environmental, as in pass 27; startup 72.7 against 78.1 ms (five runs), 70.9 against 76.3 (21); removal test 91 files;
  zsh 5.9 matrix and nu 0.116.1 smoke set; edge cases as in pass 27. Skipped: kitty (no display), linters (none
  installed).
- Theme switch: 11 groups end empty, on the original tree too: the logged crates, grug-far and csvview colours,
  `RenderMarkdownPadding` (no attributes) and two `lualine_transitional_*` groups (made at the next statusline draw,
  which a headless run lacks).
- `E31` in `v:errmsg` is the markdown ftplugin's (pass 27). LuaLS 28 warnings (stdlib types); selene 10 (`\u{...}`
  escapes, `_G` checks).
- Kept despite a year without commits: sc-im.nvim, promise-async, mega.logging, guess-indent, nvim-dap-virtual-text,
  tw-values.nvim.

## Earlier passes: conclusions only

- 27th (2026-10-20): README's Install names lazy.nvim's `stable` clone; init.lua's "Keys:" paragraph is the key
  hierarchy summary, so `gap.keys-line` checks plugin headers only.
- 26th (2026-10-20): `<leader>nX` cancels; `2<C-w>f` keeps its count; the right-click Trouble item is off without
  `:Trouble`; dropped as dead or restated: basedpyright's `tagSupport`, noice's "search hit BOTTOM" route, `modeline`
  under sudo, snacks' `words.debounce`, `notifier.timeout` and indent defaults, rustaceanvim's `enable_clippy`. Rulings:
  plugin files call `Snacks` only in handlers and events; the key-handler builders of logseq, molten, sc-im and
  colorschemes stay local.
- 25th (2026-10-19): a live theme switch refills the default links plugins set once at load (utils/themes.lua); the
  right-click "Open in Web Browser" is an `amenu` reaching 0.12's gx; dead options dropped (grug-far's `headerMaxWidth`,
  trouble's `win.border`, lazy.nvim's `dev.path`); basedpyright leaves `useLibraryCodeForTypes` to pyproject.toml.
  Rulings: keymap options equal to a default stay (they pin the key); sc-im.nvim stays (not archived); `fn.system` stays
  in the statusline's branch lookup and the bootstrap (`vim.system():wait()` runs the event loop inside a redraw).
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
| rockerBOO/awesome-neovim | 2026-10-22 | 54ae5f6ada9e | no commit since 2026-10-20; partial-diff.nvim, jisho.nvim, resonance.nvim declined in pass 27 |
| wsdjeg/SpaceVim | 2026-10-22 | eed9d8f14951 | no commit since 2026-10-03 |
| jdhao/nvim-config | 2026-10-22 | c07f3c1e1b77 | no commit since 2026-10-20 |
| craftzdog/dotfiles-public | 2026-10-22 | bf2867469b8b | no commit since 2026-10-03 |
| xero/dotfiles | 2026-10-22 | 5204a2b74f9a | no commit since 2026-10-03 |
| rafi/vim-config | 2026-10-22 | dfc296925794 | no commit since 2026-10-15 |
| ecosse3/nvim | 2026-10-22 | 5d1e66db95b7 | no commit since 2026-10-03 |
| linkarzu/dotfiles-latest | 2026-10-22 | 83304ca2cfb2 | 4 commits: sketchybar, Hammerspoon, OBS scripts; no Neovim file |
| nshen/learn-neovim-lua | 2026-10-22 | 0813be9206a1 | no commit since 2026-10-03 |
| yutkat/dotfiles | 2026-10-22 | 9c05709e0792 | 14 commits: nushell, zsh, a firejail Neovim launcher; no config change to adopt |
| Matt-FTW/dotfiles | 2026-10-22 | 0bcecd91cd93 | no commit since 2026-10-20; tsc in the backlog, markview.nvim declined (overlaps render-markdown) |
| wincent/wincent | 2026-10-22 | 7483d5d76c1e | 7 commits: Pi agent, deps, tests; no Neovim file |
| crivotz/nv-ide | 2026-10-22 | ebd4f35c3282 | no commit since 2026-10-03 |
| SeniorMars/dotfiles | 2026-10-22 | ea99c6844e1d | no commit since 2026-10-03 |
| folke/dot | 2026-10-22 | 10526a848771 | no commit since 2026-10-03 |
| Allaman/nvim | 2026-10-22 | d62ecf5aa010 | no commit since 2026-10-03 |
| loctvl842/monokai-pro.nvim | 2026-10-22 | a68e38b8e55d | no commit since 2026-10-03; one of the four schemes |

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
