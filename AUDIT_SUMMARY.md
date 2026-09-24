# Config log

What changed, and the reason it changed. Newest first. Older passes are condensed to their
conclusions once a later pass has confirmed them.

## 2026-09-24 (eighth pass): every plugin installed and run, lost icons restored, mermaid added

Earlier passes read upstream source, and the seventh ran a bare Neovim. This one installed all 89
plugins for real under Neovim 0.12.5 (still the latest release), loaded every lazy spec, opened
lua, python, typescript, sql, shell, markdown and mermaid buffers, wrote files through the lint and
format paths, and ran which-key's health check. No errors beyond the expected "debugpy not
installed yet" in a sandbox that has not run Mason. `lazy-lock.json` is regenerated from that
install, so every pin is current as of this pass.

### Icons kept going blank

Glyphs from Unicode's older private-use block (U+E000 to U+F8FF: powerline separators and most
pre-nf-md Nerd Font icons) are dropped by at least one path these files travel through. Measured:
a line holding U+E0BC, U+F188 and U+F00E4 came back holding only U+F00E4. That is the real cause of
the "empty DAP sign" bug an earlier pass fixed; the fix used the same kind of glyph and was blanked
again on the next round trip. Blank today, now restored: five DAP signs, twelve dap-ui icons,
lualine's separators, diff and venv icons, barbar's six separators, neo-tree's expanders and five
git symbols, Trouble's fold and folder icons, the six todo-comments icons, the gitsigns blame
prefix. Rule from here on, also in README: nf-md glyphs (U+F0001 and up) only, and `\u{...}` escapes
for the separators that have no nf-md form. barbar's overrides were removed rather than escaped:
its `slanted` preset already supplies the same glyphs.

### Defects fixed

- `dap-virtual-text.lua` set `virt_text_prefix`, which the plugin never reads.
- `lint.lua` called the private `lint._resolve_linter_by_ft`. `try_lint(nil, { filter = installed })`
  does the same through the public API: nil lets nvim-lint resolve the filetype itself (compound
  ones included), the filter keeps linters whose binary is missing from raising.
- gopls was non-optional, so every start on a machine without Go warned. Mason's `gofumpt` is built
  with `go install`, so it failed on every start there too. Both are now conditional on Go.
- `copilot.lua` ran its own `node --version` probe. copilot.lua does that itself
  (`lua/copilot/lsp/nodejs.lua`, `:checkhealth copilot`), so the duplicate went.
- `mcphub.lua` warned about npm at load; the build step already needs npm, so the warning went.
- Headers and comments that described things that do not exist: `noice.lua` listed
  `<leader>ud` (defined nowhere) and scroll keys it never mapped; `flash.lua` said `;` still repeats
  `t`/`T` (it is the command line); `lspconfig.lua` pointed at a "ts_ls note" and a "header note"
  that were never written; `lint.lua` and `yazi.lua` pointed at header notes that were missing too.
- README said zsh swallows `<C-s>` as XOFF before Neovim sees it. Neovim's TUI puts the tty in raw
  mode, which clears IXON, so `<C-s>`/`<C-q>` always arrive; the freeze only happens at the zsh
  prompt (`unsetopt FLOW_CONTROL`).
- which-key carried label-only entries for `<leader>of` and `<leader>ot`, repeating the `desc` the
  real mappings already have.

### Replacements and removals

- text-case.nvim, last commit 2024-08, replaced by coerce.nvim (commits this month). `gA` + case key
  in normal and visual mode; `ga` stays native. The motion variant was left unmapped, because
  `gAo` next to a `gA` leaf is an overlap which-key's health check flags. Its library, coop.nvim,
  is listed in `deps/shared.lua`.
- FixCursorHold.nvim removed. Archived since 2023, and its own README says Neovim fixed the bug in
  PR 20198. neotest's README still lists it, for CursorHold timing, which `updatetime = 100` covers.
- barbar's `version = "^1.0.0"` pin dropped. The newest tag is v1.9.1 from 2024-07; master has
  commits from 2026-06, so the pin held the plugin two years back.

### Mermaid

snacks.image already renders ` ```mermaid ` fences inline through kitty's graphics protocol when
`mmdc` is on `$PATH`; its markdown query captures them, and `convert.mermaid` picks the `dark` or
`neutral` theme from `background`. Added on top: `convert.notify = true` so a missing `mmdc` or a
bad diagram reports instead of rendering nothing, `<leader>ui` for the image under the cursor in a
float (`Snacks.image.hover()`), the `mermaid` treesitter parser for highlighting the source, and
`utils.mermaid_render()` behind `<leader>uM` for standalone `.mmd` files (0.12 already maps
`.mmd`, `.mmdc` and `.mermaid` to the `mermaid` filetype). Tested with a stub `mmdc`: the PNG opens in
a split, and a second render reloads the same split instead of opening another.

### Kitty and zsh

`map ctrl+t new_tab_with_cwd` in kitty.conf swallowed `<C-t>` before any program saw it: Neovim's
tag-stack and insert-mode indent, the picker's "open in tab", and fzf's Ctrl-T widget that `.zshrc`
loads with `fzf --zsh`. Moved to `ctrl+shift+t`, kitty's own default. No Neovim mapping uses
`alt+1`..`alt+9` or any `ctrl+shift` key. The zsh setup needs nothing from this side: PATH lives in
`.zshenv`, which non-interactive zsh reads, so `:!`, `:make` and formatters find `~/.local/bin`.

### Shells, run under zsh 5.9 and nushell 0.115.1

zsh with the `.zshenv` from this setup: `system()`, `:read !`, `:make` into quickfix and `:terminal`
all work, and `$PNPM_HOME` from `.zshenv` is visible to `:!`. Nushell turned up a real defect in
the flags copied from nushell's own integration: its `shellpipe` saves only stderr to the error
file, so `:grep` (ripgrep and grep both print matches to stdout) always produced an empty quickfix
list, and so did `:make` for any tool reporting on stdout. The pipe now saves stdout and stderr, as
`2>&1| tee` does. Measured before and after: `:make` on stderr worked both ways; `:make` on stdout
and `:grep` went from empty to filled.

### Comments and key documentation

Every plugin header now lists the keys this config binds for the plugin and the plugin's own keys
inside its windows (Lazy, Mason, yazi, avante's sidebar, the scissors editor, neo-tree, Octo,
multicursor, harpoon and others were missing them), each read from the plugin's source defaults.
Comments standing on their own line below a header were removed or folded into end-of-line notes:
section labels in `snacks.lua`, `which-key.lua` and `utils.lua`, and a two-line block in
`lspconfig.lua`.

### Checked and left as is

- which-key health reports only structural overlaps: native `gc` against `gcc`/`gco`/`gcO`/`gcA`,
  and mini.ai's `a`/`i` prefixes. Both are how those features are built.
- No global mapping replaces a stock 0.12.5 default except `Y`, which hardtime wraps and replays as
  the stock `y$`.
- LuaJIT in 0.12.5 decodes `"\u{e0bc}"` to the right three bytes.

### Open for next pass

- barbar across every theme is still only observed on tokyonight and monokai-pro.
- Inline image placement needs a real kitty window; the sandbox has no graphics protocol, so only
  the conversion and split paths were exercised, with a stand-in `mmdc`.
- The 16 reference configs were not re-read this pass; this pass verified against installed sources.
- nvim-window-picker (last commit 2025-02) and guess-indent (2025-03) are quiet but working.

## Earlier passes (2026-09-19 and before): conclusions only

**Seventh pass.** Ran the tree under a bare 0.12.5. `gd`/`gD` are built-in commands, not keymaps,
so which-key cannot discover them; label-only spec entries now name `gd gD ga gJ gq gp gP g& gF g?`
and the `gr*` LSP keys without taking them from Neovim. `diffopt` is assigned whole (appending left
two `linematch:` values). 0.12 took `an`/`in` for node selection, so mini.ai's next-object pair moved
to `aN`/`iN`. nvim-lspconfig registers no commands on 0.12, so `:LspInfo`, `:LspLog` and
`:LspRestart` here are the only source of them.

**Sixth pass.** Built-ins returned: `<C-a>`/`<C-x>` (dial widens them), `>`/`<`, insert-mode
`<C-e>`; select-all moved to `<leader>na`. `dap.configurations.c` and `.rust` are deep copies of
`.cpp`, since rustaceanvim appends runnables to the table in place. Statusline scans are memoised
on `b:changedtick` through `utils.buf_cached()`.

**Fifth pass.** One picker engine (snacks.picker) instead of three. barbar replaced bufferline.
Each terminal layout is a separate snacks terminal, keyed by an env var. `'shell'` follows the
passwd login shell, with nushell's own flags only when the shell is nu. Terminal-mode `<M-w/a/s/d>`
move between splits and pass through in floats.

**First to fourth passes.** `plugins/init.lua` renamed `plugins/loader.lua` after going missing in
seven deliveries (it shared a basename with the root `init.lua`). Keys moved off native ones:
Trouble off `]d`/`[d`, parameter swap to `<leader>a`/`<leader>A`, class motions to `]k`/`[k`,
todo jumps to `]n`/`[n`, tabs to `<leader><Tab>`. Real bugs fixed: `shell = "nushell"` (the binary
is `nu`), duplicate format-on-save, a ufo fallback chain that could not catch treesitter failures,
nvim-lint raising on a missing `typos` inside `BufWritePost` and breaking `:w`, Noice swallowing the
hover border. `mini.icons` stands in for nvim-web-devicons through `mock_nvim_web_devicons()`.
Declined, reasons unchanged: sidekick.nvim, eyeliner.nvim, hydra.nvim, fidget.nvim, nvim-spider,
nvim-navic, nvim-hlslens.
