# Config log

What changed, and the reason it changed. Newest first. Older passes are condensed to their conclusions once a later
pass has confirmed them.

## 2026-09-24 (ninth pass): d2 replaces mermaid, built-in keys returned, double work removed

Method: the tree was rebuilt from the project copy and run under Neovim 0.12.5, the latest release, with all 87 plugins
installed and 29 parsers built. 58 scripted checks cover startup laziness, every spec loading, d2 rendering, restored
built-ins, comment keys, theme switches and the d2 formatter. Every global map was compared with Neovim's own
`runtime/doc/index.txt`. which-key's health check and `stylua --check` against `.stylua.toml` came back clean apart from
the structural overlaps listed below. `lazy-lock.json` is regenerated from this install.

### d2 instead of mermaid

mermaid-cli (`mmdc`) renders through Puppeteer and a headless Chromium. d2 0.9.0 is one static binary that writes SVG,
PNG and text itself: a PNG render took 17 ms here and downloaded nothing. The earlier note on this change said d2's PNG
export needs Playwright; 0.9.0 does not.

- Added `tree-sitter-d2.lua` (ravsii/tree-sitter-d2 v0.7.2, parser and queries, registered with nvim-treesitter's main
  branch), `utils.d2_render()` on `<leader>ud` (PNG in a split, drawn by snacks.image in kitty), `utils.d2_text()` on
  `<leader>uD` (box-drawing text, any terminal), the `d2` filetype (0.12.5 does not detect `.d2`) and conform's `d2`
  formatter.
- Removed the `mermaid` parser, `utils.mermaid_render()`, `<leader>uM` and every mmdc mention. snacks.image's own
  markdown query sends ` ```mermaid ` blocks to mmdc, so `snacks.lua` sets that query to ` ```math ` blocks only through
  `vim.treesitter.query.set`.
- Declined terrastruct/d2-vim: loading it maps `<leader>d2`, `<leader>rd2` and `<leader>yd2` globally with no opt-out,
  and it runs `d2 fmt` on save by default, doubling conform. Its text preview is one d2 call, which `utils.d2_text()`
  makes.
- snacks.image has no d2 converter, so a d2 block inside markdown renders on request rather than automatically.

### Built-in keys returned

Instruction 7 prefers built-in keymaps. Earlier passes kept nine built-ins as documented trades, and the key scan found
five more. All fourteen are back, each personal action on a free key: `;` `,` `q` `x` `X`, visual `p`, `<C-q>`, `H` `L`
(buffers on `<M-h>` `<M-l>`), `f` `F` (flash on `<leader>j` `<leader>J`), `s` and visual `S` (surround on visual `gs`
`gS`), visual `R`, `g]` (mini.ai edge jumps off), `<C-LeftMouse>` (multicursor on `<M-LeftMouse>`), `]f` `[f` (functions
on `]m` `[m` `]M` `[M`, the built-in method motions extended by treesitter), `zr`, and the command-line `<Left>`
`<Right>` `<End>` (trimmed from blink's preset). Kept on built-in keys because they do the same job better: dial on
`<C-a>`/`<C-x>`, centred `n`/`N`, LSP on `gd`/`gD`/`grn`, ufo on `zR`/`zM`, mini.ai on `a`/`i`, matchit on `%`.

### Defects fixed

- hardtime maps `h` `j` `k` `l` `J`, the arrows and a few more keys itself and does not chain existing maps, so the
  config's `j`/`k` screen-line maps, its `J` join map and the arrow-key resizing never ran. The dead maps went; resizing
  moved to `<M-arrows>`.
- `<leader>io` called `require("opencode").toggle()`, which opencode.nvim no longer has. The TUI now toggles through
  snacks.terminal, as upstream's README shows, and `<leader>iS` opens opencode's action picker.
- `lspconfig.lua` mapped `K` on every attach, replacing rustaceanvim's buffer-local hover actions in Rust buffers. `K`
  is Neovim's own now (0.12 maps it only where no buffer map exists), and floats take `'winborder'`, which also made the
  bordered `<C-s>` override redundant.
- The `LspProgress` echo duplicated noice's LSP progress and sat outside the `999rpm-*` groups. It went, and so did the
  `messagesopt` pin kept only for it; the value equals 0.12.5's default.
- `lua_ls` set `single_file_support`, which `vim.lsp.config` ignores.
- conform sent Dockerfiles to prettier, which has no Dockerfile parser; `sh` files were linted but never formatted.
- nvim-surround v4 dropped `setup({ keymaps })`. Its visual keys now come from `g:nvim_surround_no_visual_mappings`
  plus two `<Plug>` maps.
- octo's and hex.nvim's `setup()` raised when `gh`/`xxd` were missing, right after the config's own warning. Setup now
  runs only when the binary exists.
- nvim-dap, dap-ui and dap-python loaded at startup: mason-nvim-dap had no load trigger and listed nvim-dap as a
  dependency, and every debug spec carried `VeryLazy`. mason-nvim-dap is gone (mason-tool-installer installs the four
  adapters), and nothing debug-related loads before a debug key.
- blink loaded on `InsertEnter` only, so the command line used the built-in wildmenu until the first insert.
- `close_with_q` listed nine filetypes of plugins that are not installed and force-deleted oil buffers, which could
  drop unsaved renames. `auto_close_win` and neo-tree's `close_if_last_window` both tried to quit on the same event;
  one mechanism is left.
- Highlight overrides in `render-markdown.lua` and `multicursor.lua` were set once and lost on the first theme switch.
  `utils.on_colorscheme()` re-applies them, as `dap.lua` already did by hand.
- `options.lua` set fourteen options to values 0.12.5 already uses, plus `'encoding'` (fixed in Neovim), `'gdefault'`
  (inverts `:s///g`) and `'tildeop'` (turns the built-in `~` into an operator; its comment described `g~`, which is
  always an operator). `'fileencodings'` tried five CJK encodings before latin1, so a Latin-1 file opened as GBK; the
  default order is back. `'nrformats'` alpha did nothing, since dial handles `<C-a>`/`<C-x>`. The clipboard provider
  probe runs after the first redraw.
- `lazy.lua` disabled `tohtml`, `2html_plugin` and `vimballPlugin`, none of which exist in 0.12.5, and matchit, which
  cost the built-in `%` its if/else/end pairs. The update checker no longer notifies at startup; the statusline shows
  the count.
- Filetype lists still named `Trouble` (Trouble v2), `alpha`, `packer`, `notify` and `NvimTree`.

### Replacements

- alpha-nvim → snacks.dashboard, already installed: keys, recent files, startup time.
- nvim-window-picker (last commit 2025-02) → `Snacks.picker.util.pick_win()` on `<leader>ew`.
- The manual `large_file` autocommand → snacks.bigfile at the same 0.5 MB limit, which also keeps treesitter, LSP and
  syntax off big files.
- mason-nvim-dap → four entries in mason-tool-installer.
- The `no_paste` autocommand went: `'paste'` is obsolete in Neovim, where bracketed paste is built in.
- avante loads on its keys and commands, ts-autotag only for tag languages.

### Checked and left as is

- which-key health reports only structural overlaps: `gc` against `gco`/`gcO`/`gcA`/`gcc`, and mini.ai's `a`/`i`
  prefixes.
- Quiet but working on 0.12.5: promise-async (2024-08, ufo's library), guess-indent (2025-03), nvim-dap-virtual-text
  (2025-05), hex.nvim (2025-07).
- Kitty: kitty.conf binds `ctrl+shift+*` and `alt+1`..`alt+9`. Neovim uses neither, and nothing in kitty.conf catches
  the Alt keys, `<M-arrows>` or `<M-LeftMouse>`. kitty.conf needed no change.
- Shells: every external call added this pass passes an argument list to `vim.system`, so zsh and nushell behave the
  same.

### Structure

The category layout holds up. Two optional moves for a later pass: `frontend/` (three small files) could merge into
`lang-tools/`, and `lang-tools/` could become `lang/` once it carries more than formatting and linting.

### Open for next pass

- Inline placement of images and d2 PNGs needs a real kitty window. The sandbox has no graphics protocol, so rendering,
  file output and the split were verified, not the drawing.
- Mason's registry was unreachable from the sandbox, so server and tool installs were not exercised.
- The 16 reference configs were not re-read; this pass verified against installed sources.

## Earlier passes (2026-09-24 and before): conclusions only

**Eighth pass.** First run with every plugin installed under 0.12.5. Icons restricted to nf-md glyphs (U+F0001 and up)
and `\u{...}` escapes, after older private-use glyphs kept vanishing in transit. `lint.lua` moved to the public
`try_lint(nil, { filter = installed })`. gopls and gofumpt became conditional on Go. text-case.nvim → coerce.nvim;
FixCursorHold removed; barbar's version pin dropped. kitty's new tab moved to `ctrl+shift+t`, so `<C-t>` reaches Neovim
and fzf. Nushell's `shellpipe` saves stdout as well as stderr, so `:grep` fills the quickfix list. Its mermaid setup was
replaced in the ninth pass.

**Seventh pass.** Ran the tree under a bare 0.12.5. `gd`/`gD` are built-in commands, not keymaps, so which-key cannot
discover them; label-only spec entries name `gd gD ga gJ gq gp gP g& gF g?` and the `gr*` LSP keys without taking them
from Neovim. `diffopt` is assigned whole (appending left two `linematch:` values). 0.12 took `an`/`in` for node
selection, so mini.ai's next-object pair moved to `aN`/`iN`. nvim-lspconfig registers no commands on 0.12, so
`:LspInfo`, `:LspLog` and `:LspRestart` here are the only source of them.

**Sixth pass.** Built-ins returned: `<C-a>`/`<C-x>` (dial widens them), `>`/`<`, insert-mode `<C-e>`; select-all moved
to `<leader>na`. `dap.configurations.c` and `.rust` are deep copies of `.cpp`, since rustaceanvim appends runnables to
the table in place. Statusline scans are memoised on `b:changedtick` through `utils.buf_cached()`.

**Fifth pass.** One picker engine (snacks.picker) instead of three. barbar replaced bufferline. Each terminal layout is
a separate snacks terminal, keyed by an env var. `'shell'` follows the passwd login shell, with nushell's own flags only
when the shell is nu. Terminal-mode `<M-w/a/s/d>` move between splits and pass through in floats.

**First to fourth passes.** `plugins/init.lua` renamed `plugins/loader.lua` after going missing in seven deliveries (it
shared a basename with the root `init.lua`). Trouble moved off `]d`/`[d`, parameter swap to `<leader>a`/`<leader>A`,
class motions to `]k`/`[k`, todo jumps to `]n`/`[n`, tabs to `<leader><Tab>`. Real bugs fixed: `shell = "nushell"` (the
binary is `nu`), duplicate format-on-save, a ufo fallback chain that could not catch treesitter failures, nvim-lint
raising on a missing `typos` inside `BufWritePost` and breaking `:w`, Noice swallowing the hover border. `mini.icons`
stands in for nvim-web-devicons through `mock_nvim_web_devicons()`. Declined, reasons unchanged: sidekick.nvim,
eyeliner.nvim, hydra.nvim, fidget.nvim, nvim-spider, nvim-navic, nvim-hlslens.
