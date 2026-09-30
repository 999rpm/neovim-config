# Config log

What changed, and the reason it changed. Newest first. Older passes are condensed to their conclusions once a later
pass has confirmed them.

## 2026-09-30 (tenth pass): laziness, snacks.words, one rule per prefix

Method: Neovim 0.12.5 was built into a clean sandbox, the tree installed from the archive, and all 88 specs synced.
Findings come from that running instance: a full keymap dump across eight modes (823 maps), `startuptime` averaged over
three runs, `which-key.health.check()`, `checkhealth vim.deprecated`, `stylua --check` against `.stylua.toml`, and
reading the installed source of every plugin whose behaviour was in question. `lazy-lock.json` is regenerated from this
install.

### Startup

21 plugins loaded at startup; 11 do now. Eight warm runs of `nvim --headless --startuptime` afterwards spread across
48-71 ms, mean 60 ms, against 119 ms before; an earlier three-run sample read 42-47 ms, so the spread is wider than
one sample suggests and the mean is the honest figure. Five of the ten plugins were loading for avoidable reasons:

- `harpoon` had no `keys`, `event` or `cmd`: its global maps were set inside `config`, so the whole plugin loaded to
  create nine keymaps. The maps moved into a `keys` table built above the spec, and the `UI_CREATE` extension stayed in
  `config`.
- `mason-lspconfig` listed `nvim-lspconfig` in `dependencies`. Version 2 ships its own `mason-lspconfig.mappings` and
  never requires lspconfig, so the entry did nothing except drag lspconfig, schemastore and blink into startup. Both
  Mason bridges now wait for `VeryLazy`.
- `nvim-lspconfig` itself had no load trigger. It takes `BufReadPre`/`BufNewFile` now, which still runs before the
  first `FileType`, so servers attach exactly as before. `blink.cmp` and `schemastore` follow it off the startup path.
- `barbar` listed `gitsigns.nvim`. barbar reads `b:gitsigns_status_dict` through a `pcall` and its `icons.gitsigns`
  entries default to `enabled = false`, which this config never turns on, so the entry only cost gitsigns its own
  `BufReadPre` trigger.
- Seven files listed `nvim-mini/mini.nvim` for icons alone. mini is `lazy = false` at priority 1000 and is loaded
  before anything that draws an icon, so the entries were noise. `blink.cmp` no longer lists `lazydev.nvim` either:
  its provider is reached by module name, which lazy.nvim's loader resolves, so lazydev stays `ft = "lua"`.

### snacks.words replaces hand-written reference highlighting

`lspconfig.lua` created a `CursorHold`/`CursorHoldI` pair calling `vim.lsp.buf.document_highlight`, a `CursorMoved`
pair calling `clear_references`, a per-buffer guard variable and an `LspDetach` handler to tear all of it down.
snacks.nvim already ships `words`, enabled on `LspAttach`, debounced at 200 ms, with a `jump(count, cycle)` API and no
keymaps of its own. The module is on, roughly thirty lines went, and `]r`/`[r` now walk the occurrences — which the
hand-written version could not do. `<leader>oR` toggles it. `]]`/`[[` stay the built-in section motions.

### Key scheme

Instruction: one rule per prefix. `<leader>o` held nineteen keys mixing toggles with plugin managers and the theme
switcher, and its mnemonics collided (`os` cycled a theme style while `oS` toggled spelling).

- `<leader>o` is now toggles and nothing else, case-paired: `on`/`oN` numbers, `ow` wrap, `os` spelling, `oi` indent
  guides, `od`/`oD` diagnostics and dimming, `oh` inlay hints, `oR` reference highlights, `oc` treesitter context,
  `of`/`oF` format on save, `og`/`oG` git blame and line highlights, `ox` hex view, `oH` hardtime.
- `<leader>u` is UI and theme: `ut`/`uT` next theme and transparency, `uc`/`uC` next style and the picker, then the
  scratch, zen, zoom, breadcrumb, markdown, image and d2 keys it already had.
- `<leader>p` is new, for the things that are not toggles: `pl` Lazy, `pm` Mason, `pc` ConformInfo, `ph` checkhealth.
  `ph` fills a real gap — there was no key for `:checkhealth`.
- `<leader>cf` carried `mode = ""`, which binds n, v *and* operator-pending; the dump showed `o  <Space>cf`. It is
  `{ "n", "x" }` now.
- Descriptions are sentence case throughout, with no trailing period and no repetition of the group name
  ("Avante Ask" → "Avante: ask", "Run Nearest Test" → "Run nearest test").

### Defects fixed

- `jumpoptions` was assigned `stack,view`, dropping 0.12's `clean`. `options.txt` describes the three as independent,
  so `stack,view,clean` keeps the tagstack behaviour and the mark-view restore without leaving unloaded buffers in the
  jumplist.
- `signs_staged` was left at gitsigns' defaults while `signs` was customised, so staged hunks drew `▁ ▔ ~` against the
  unstaged `┃ │ ║`. Both sets match now; only the highlight differs.
- Four executable checks used `vim.fn.executable(...) == 1` directly while six others went through `utils.executable`.
  All ten go through the helper.

### Structure

`frontend/` (three small files) merged into `lang-tools/`, which became `lang/`: formatters, linters and per-language
helpers in one folder, fourteen category folders down to thirteen. `loader.lua` names what each folder holds.

### utils.lua

Two helpers added, each replacing a duplicated block: `mason_path(unix, windows)` builds a path under Mason's data
directory and picks the Windows layout where it differs (four call sites across `dap.lua` and `dap-python.lua`), and
`map_close(buf, wipe)` binds `q` to close a throwaway window (`autocmds.lua` and `d2_text`). `augroup("virtual-lines")`
replaces the one `nvim_create_augroup` call that bypassed the helper. Every entry still carries its "used by" line, and
those lines were re-checked against a grep of the tree.

### 999rpm naming

Buffer-local variables were a mix of `b:user_*` and `b:_999rpm_*`; they are all `b:_999rpm_*` now
(`_999rpm_last_loc`, `_999rpm_secure_tmp`, `_999rpm_backup_was_on`, alongside the existing cache, branch and
virtual-lines flags). The theme state file moved from `theme_state.json` to `999rpm-theme.json`, the d2 cache to
`999rpm-d2/`, and the d2 text buffer to `999rpm://d2-text`. The first theme switch after this pass starts from the
defaults, since the old state file is not read.

### Checked and left as is

- hardtime does map `h j k l J x X . c d y p P C Y ~` and the arrow keys. Its `M.setup` defers the real work by 500 ms,
  so a check that does not wait will report the maps as absent. The notes in `mappings.lua` and the README are correct.
- better-escape inserts the first key immediately through an `expr` map and backspaces it only when the pair completes,
  so its cmdline-mode `j`/`k` maps cost no typing lag.
- nvim-autopairs' global insert `<CR>` sits underneath blink's buffer-local `<CR>`, and blink's `fallback` reaches it.
- 0.12.5's `_core/defaults.lua` does set `grepprg = "rg --vimgrep -uu "` when ripgrep is present, so the override in
  `options.lua` is doing what its comment says.
- which-key health reports only structural overlaps: `gc` against `gco`/`gcc`/`gcO`/`gcA`, and mini.ai's `a`/`i`
  against `an`/`al`/`aN` and matchit's `a%`. `checkhealth vim.deprecated` is clean.
- Quiet but working on 0.12.5: promise-async (2024-08, ufo's library), guess-indent (2025-03), nvim-dap-virtual-text
  (2025-03), hex.nvim (2025-07), harpoon2 (2025-10). Several folke plugins also show 2025 dates, either because the
  spec pins a tag or because the plugin is finished, not because it is abandoned.
- Kitty: the archive's `kitty.conf` and the current one differ by a single commented `shell` line. kitty binds
  `ctrl+shift+*` and `alt+1`..`alt+9`, none of which Neovim uses here, and nothing catches the Alt keys,
  `<M-arrows>` or `<M-LeftMouse>`. No change needed.
- Shells: every external call still passes an argument list to `vim.system`, so zsh and nushell behave the same. The
  current `.zshrc` has no `unsetopt FLOW_CONTROL`, which the README now states rather than implies.

### Open for next pass

- Inline placement of images and d2 PNGs needs a real kitty window. The sandbox has no graphics protocol, so rendering,
  file output and the split were verified, not the drawing.
- Mason's registry was unreachable, so server and tool installs were not exercised; `cargo` is absent, so avante's
  build step fails there as documented.
- `VeryLazy` does not fire under `--headless`, so the two Mason bridges were verified by firing `User VeryLazy` by
  hand.

## Earlier passes (2026-09-24 and before): conclusions only

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
