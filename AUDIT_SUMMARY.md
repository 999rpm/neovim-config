# Config log

What changed, and the reason it changed. Newest first. Older passes are condensed to their conclusions once a later
pass has confirmed them.

## 2026-10-01 (twelfth pass): three regressions, reference configs, fewer hand-written parts

Method: Neovim 0.12.5 (the current stable), every plugin at its latest commit (only avante had moved), a pseudo-terminal
set up like kitty (`COLORTERM=truecolor`, `TERM=xterm-kitty`, answering its startup queries) for the startup checks, and
headless runs for the rest. The sixteen reference repos were cloned; plugin choices, options, autocommands and keymaps
were extracted from all of them, and the files of folke/dot and linkarzu's neobean read in full. Every plugin added has
commits within the last six months.

### Regressions fixed

- **Theme switcher never ran.** `999rpm-themer` and `999rpm-notes` both had `dir = stdpath("config")`; lazy.nvim matches
  local specs by directory, so it merged them into one plugin named `999rpm-notes` with the themer's `lazy = false` and
  the notes spec's `config`. No colorscheme loaded, the `<leader>u` theme keys did not exist, and the notes layer loaded
  at startup. Both are now `virtual = true` specs with a slash-less name (lazy.nvim rejects a spec with only `name`).
- **Colorizer disabled itself.** 0.12 detects truecolor but applies `termguicolors` at `VimEnter`, after the
  `BufReadPre` of a file named on the command line, where colorizer's setup found it off, printed the error and returned.
  The ninth pass had removed the option as a default. It is set again; a side effect is that colorizer now switches off
  0.12's own LSP colour highlighting in the buffers it paints, so colours are drawn once.
- **DAP warned for every missing adapter on any debug key.** `utils.mason_adapter()` wraps each adapter so its Mason file
  is checked when that adapter's session starts. haskell-debug-adapter installs only when `stack` is on `$PATH`: the
  launch configuration runs `stack ghci`.

### Replaced or added

- tiny-inline-diagnostic.nvim replaces the 80-line rounded virtual-lines handler in `utils.lua`; its default already
  draws only the cursor line.
- vim-matchup replaces the bundled matchit and matchparen: `%` pairs `function`/`end` and HTML tags through treesitter.
  Its offscreen popup is off, because treesitter-context shows the same line.
- ts-comments.nvim: `gc` inside JSX writes `{/* */}`.
- mini.align (already inside mini.nvim) on `gl`/`gL`; `ga` stays the built-in character info, `gA` coerce.
- crates.nvim for `Cargo.toml`, through its in-process language server (`gra`, `K`, completion).
- Snacks.rename is hooked into neo-tree and oil, so moving a file updates imports through the language servers.
- Colorizer takes Tailwind colours from tailwindcss-language-server where it runs; blink drops a border it already takes
  from `winborder` and highlights LSP labels with treesitter; pickers rank by frecency and the cwd.
- Options: `shada` keeps 0.12's `/tmp/` and `/private/` exclusions it had overwritten, `sidescrolloff = 8`,
  `switchbuf = useopen,uselast`, `pumborder = rounded`.
- lualine no longer runs `git fetch origin` every 30 seconds: that raced lazygit and gitsigns for git's lock files and
  could raise SSH prompts. Ahead/behind counts come from local refs.
- A first run opens tokyonight moon (upstream's default) instead of the light day style.

### Keys

- `<leader>x` merged into `<leader>d`: one group for every diagnostic view (`df` float, `db`/`dw` quickfix, Trouble on
  `dd` `dD` `ds` `dl` `dq`). LSP workspace folders moved from `<leader>w*` to `<leader>lwa/lwr/lwl`.
- New: `<leader>uu` 0.12's `:Undotree`, `dm` + mark deletes a mark (`dm` has no built-in job), `gl`/`gL` align.
- which-key labels `ZZ`, `ZQ`, 0.12's `ZR` (restart) and matchup's `%` family. 458 global keymaps, none on kitty's
  `ctrl+shift` or `alt+1`..`alt+9`.

### Declined

- kitty-scrollback.nvim: needs remote control in kitty.conf, and the TermOpen autocommand would put its view in insert
  mode; not verifiable without kitty. smart-splits: it would change kitty's split keys.
- quicker.nvim overlaps nvim-bqf, and its `<`/`>` collide with bqf's list history.
- marks.nvim, nvim-treesitter-endwise, themery.nvim, virt-column.nvim: no commits for 9 to 23 months.
- telescope, fzf-lua, bufferline, nvim-cmp, diffview, neogit, alpha, fidget: snacks, barbar, blink, codediff, lazygit
  and noice cover them.
- Reference keymaps such as `j`/`k` to `gj`/`gk`, `<C-d>zz`, `x` to `"_x`, `<C-c>` to `ciw`: each takes a built-in or one
  of hardtime's keys.
- mini.trailspace for the trim-on-write autocommand: no less code, and it would mark trailing spaces that 'listchars'
  already shows.

### Checked and left as is

- Four plugins have had no commits for over a year (promise-async, guess-indent, nvim-dap-virtual-text, hex.nvim). They
  work, and no maintained alternative exists; vim-sleuth is older still.
- `v:errmsg` still holds barbar's silent `dictwatcherdel` E116.
- which-key's health lists prefix overlaps, all by design: Neovim's own `gc`/`gcc` beside `gco` `gcO` `gcA`, and
  mini.ai's `a`/`i` beside 0.12's `an`/`in`, mini.ai's `al`/`aN` and matchup's `a%`/`i%`. No duplicate keymaps. The
  eleventh pass's "no overlaps" line was wrong for the same reason.
- `:grep` fills the quickfix list and `:!` runs under both nushell 0.116 and zsh.

## Earlier passes: conclusions only

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
