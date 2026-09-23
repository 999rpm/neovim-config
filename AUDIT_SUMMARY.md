# Config log

What changed, and the reason it changed. Newest first. Older passes are condensed to their
conclusions once a later pass has confirmed them.

## 2026-09-19 (seventh pass) — checked against a running 0.12.5, built-in keys bound and labelled

Earlier passes read upstream source. This one also ran it: Neovim 0.12.5 was fetched and the whole tree
loaded under it, so every claim below is an observed result rather than a reading of a spec.

### The reported symptom: which-key never shows `gD`

`gd` and `gD` are built-in editor commands, not keymaps. `maparg("gD", "n")` is empty on a stock 0.12.5,
so there is nothing in any keymap table for which-key to read, and its `g` preset
(`lua/which-key/plugins/presets.lua`) lists only `g% g, g; gN gT gf gi gn gt gv gx` — no `gd`, no `gD`.
The popup showed `gd` solely because `lspconfig.lua` binds it on `LspAttach`; `gD` was bound nowhere, even
though the right-click menu had offered Declaration all along.

Two fixes, because the gap had two halves:

- `gD` now maps to `vim.lsp.buf.declaration()` on attach, gated on `textDocument/declaration`. Where no
  server answers it — lua_ls, for one — the key stays Nvim's own file-global declaration search.
- `which-key.lua` gained label-only entries for the built-ins nothing can discover: `gd`, `gD`, `ga`, `gJ`,
  `gq`, `gp`, `gP`, `g&`, `gF`, `g?`. Checked in which-key's own source and then live: `M.parse` calls
  `M.create` only `if m.rhs`, so an entry carrying just a `desc` never reaches `vim.keymap.set` and cannot
  take a key away from Nvim. Measured effect: the `g` popup went from 24 entries to 32, and
  `maparg("gD")` still returns the LSP mapping afterwards.

The same treatment covers `grn gra grx grr gri grt gO`, whose built-in descriptions are raw function names
(`vim.lsp.buf.rename()`); the `gr` popup now reads as six plain labels.

### Defects found by running it

**`diffopt` held two `linematch:` values.** The live string was
`internal,filler,closeoff,indent-heuristic,inline:char,linematch:40,algorithm:histogram,context:3,vertical,linematch:60`.
`:append` deduplicates identical flags, so the appended `inline:char` collapsed into the default, but
`linematch:40` and `linematch:60` are different strings and both survived. 60 wins on parse, so behaviour was
right and the option string was self-contradictory. The sixth pass set out to fix exactly this and appended
instead of assigning. Now assigned outright, all nine values listed.

**`grx` is a real 0.12 default**, `vim.lsp.codelens.run()`. The `lspconfig.lua` header read `grx? no,` — an
unresolved question left in a comment, and wrong. Header rewritten from `_core/defaults.lua`, and it now also
names `]D`/`[D` and `<C-w>d`, which were missing.

**`an` and `in` became built-ins.** 0.12 maps both in visual and operator-pending to select the parent and
child treesitter node, falling back to `vim.lsp.buf.selection_range` where no parser is loaded. mini.ai's
next-object mappings sat on top of them. Moved to `aN`/`iN`; `al`/`il` stay, since nothing claims those.

**nvim-lspconfig registers no commands at all on 0.12.** Its `plugin/lspconfig.lua` returns at
`if vim.fn.exists(':lsp') == 2` before defining anything. So `:LspInfo` and `:LspLog` here are the only
source of those commands, not duplicates as their shape suggests — worth recording, since a later pass
reading only the plugin's README would delete them. `:LspRestart` is a thin alias over the built-in
`:lsp restart` and now forwards its arguments (`"lsp restart <args>"`, `nargs = "*"`), so a client name can
be passed rather than restarting everything. `:LspFormat` removed: conform owns formatting here, and a
second path that skips it contradicts that.

**Two headers described keys that do not exist.** `flash.lua` advertised `s`/`S` while binding `f`/`F`, and
said in the same breath that `f`/`F` keep working. `treesj.lua` advertised `<leader>ct` and `<leader>cs`; the
plugin binds only `<leader>cj`, and `<leader>cs` is the snippets group.

**`messagesopt` was set to 0.12's own default string**, character for character. Kept anyway, with the
comment corrected to say so, because `lspconfig.lua`'s `LspProgress` echo depends on `progress:c` and a
pinned value documents that dependency.

### Confirmed correct, so a later pass does not undo them

- `buf` rather than `buffer` in `vim.keymap.set` and `nvim_create_autocmd`: `release-0.12` carries
  `@field buf?` and `Buffer buffer;  // deprecated - use buf`. Seven files use it; all seven are right.
- `client:supports_method(method, bufnr)` matches the signature in `lsp/client.lua`.
- `vim.diagnostic.handlers.virtual_lines_rounded` still shows and hides without error on 0.12.5, including
  the `user_data.virt_lines_ns` lookup it reaches into.
- The `titlestring` `v:lua.require('utils')` expression evaluates; `nvim_eval_statusline` returns a string.
- Every snacks LSP picker source the config calls exists in `picker/config/sources.lua`.
- `oil` is already in hardtime's default `disabled_filetypes`, so `-` is not blocked in an oil buffer.
- 205 declarative lazy `keys` collide nowhere. The only imperative overlap across 139 `vim.keymap.set` calls
  is `q`, global no-op against the buffer-local close in `close_with_q`, which is the intent.

### Documentation

`mappings.lua`'s header now lists 0.12's own additions, since none of them are re-bound and all of them are
worth knowing: `]d`/`[d`, `]D`/`[D`, `<C-w>d`, `]q`/`[q`, `]l`/`[l`, `]b`/`[b`, `]a`/`[a`, `]t`/`[t`,
`]<Space>`/`[<Space>`, `an`/`in`, visual `]n`/`[n`, `grx`. README gained a table for them, a line for the
`g]` trade mini.ai takes, and the rule that a `desc`-only which-key entry is a label rather than a mapping.
`.stylua.toml` is in the tree, at the tabs / 140 columns the log has claimed since the sixth pass.

### Open for next pass

- barbar across every theme in the switcher is still observed only on tokyonight and monokai-pro.
- `lint.lua` still calls `lint._resolve_linter_by_ft`, a private function.
- text-case.nvim and neotest's FixCursorHold recommendation remain the unmaintained surface.
- avante's build needs cargo and was not exercised.
- Plugins were not installed. Everything above was checked against a bare 0.12.5 plus upstream sources, so
  defects that need a loaded plugin to surface are still out of reach.

## 2026-09-19 (sixth pass) — claims re-checked against upstream source, shadowed built-ins returned (condensed)

Verified the fifth pass rather than trusting it. `&t_Cs`/`&t_Ce` had never done anything (`option.c` drops
tty options silently) and were removed. nvim-surround's `g:nvim_surround_no_*_mappings` opt-out was set
inside `config`, which lazy.nvim runs after `plugin/` is sourced, so it had never fired; the default keymaps
are kept, since `ys`, `ds` and `cs` shadow nothing. `debounce_text_changes = 500` was still present despite
the fifth pass recording its removal. `dap.configurations.c` shared one table by reference with `cpp`, the
bug already fixed for `rust`; now a deepcopy. Three "This util is used by" lists named files that never
called the helper, corrected against a grep of call sites.

Built-ins returned: `<C-a>`/`<C-x>` to increment with dial widening them rather than replacing them, `>`/`<`
to the indent operators, select-all moved to `<leader>na`, insert-mode `<C-e>` given back to copy-char-below,
and `vim.g.no_plugin_maps` dropped as far wider than the two opt-outs options.lua sets deliberately.

Buffer scoping: `non_utf8_file` read the current buffer on a `BufRead` that can fire for another and treated
an empty `'fileencoding'` as non-UTF-8; the node_modules handler passed `bufnr = 0`; `auto_close_win` counted
floats toward "only utility windows remain" and ran inside the command-line window; the right-click menu ran
`autocmd! nvim.popupmenu` on every click. Cost per redraw: `trailing_space` and `mixed_indent` ran up to five
whole-buffer searches per statusline redraw, now memoised on `b:changetick` through `utils.buf_cached()`;
copilot.lua had no lazy trigger despite binding insert-mode keys only.

## 2026-09-18 (fifth pass) — ten reported problems fixed, pickers and tabline consolidated (condensed)

Ten reported symptoms, each root-caused. **Terminals**: `Snacks.terminal` keys a terminal by
command, cwd, env and count, never by window position, so three layout mappings that passed no
command all resolved to one terminal; each now passes `env = { NVIM_999RPM_TERM = <layout> }`.
`<C-\>` had to go, since mapping it in terminal mode shadows the built-in `<C-\><C-n>`; the float
is `<C-,>`. Terminal-mode `<M-w/a/s/d>` run `wincmd` in splits and pass the key through in floats,
so lazygit and yazi still receive them; better-escape needed `default_mappings = false` because its
terminal-mode `jk` broke j/k inside both.

**Shell**: `'shell'` now comes from `vim.uv.os_get_passwd()`, which reflects `chsh` immediately,
with `$SHELL` as fallback; nushell flags apply only when the detected shell is nu, and an
`OptionSet` hook re-applies the right set mid-session.

**Tabline**: bufferline had gone 20 months without a commit and cannot render one separator glyph
per focus state anyway. Replaced by barbar, which takes separate separators and separate `Sign`
highlights per state and covers the same feature set.

**Pickers**: Telescope, fzf-lua and snacks.picker had been three engines for one job. fzf binds
`Tab` to `toggle+down` and has no normal mode, so the wanted behaviour is not buildable on it.
snacks.picker now serves every picker, opening focused on the list in normal mode;
telescope-fzf-native stays only as dropbar's fuzzy library. Octo, nvim-scissors, todo-comments,
codediff, the right-click menu and text-case's `gA.` all moved with it, and hardtime's exclusions
grew to cover picker, harpoon and dropbar filetypes.

**Other root causes found**: `colors/monokai-pro.lua` pins the "pro" filter, so the switcher must
load the per-filter colorscheme name; 0.12 hardcodes the virtual-line connector characters inside
`render_virtual_lines`, so `utils.setup_rounded_virtual_lines()` tracks the cursor line itself and
rewrites the corner in the extmarks it just placed; rust-analyzer defaults `experimental = true` on
unresolved-macro-call, so `diagnostics.experimental.enable = true` is what makes it arrive while
editing rather than on save. `<leader>Dp` had called a picker extension that was never installed.
`LspDetach` cleared an augroup that only existed if some client had asked for reference highlights.
Visual `<M-j>`/`<M-k>` ended in `gv-gv` instead of `gv=gv`. `as` shadowed the native sentence
object and moved to `aS`; class motions moved off `]m`/`[m` to `]k`/`[k`; JSX off `]]`/`[[` to
`]j`/`[j`; Copilot's dismiss off `<C-]>` to `<M-e>`.

Two plugins moved home: `echasnovski/mini.nvim` to `nvim-mini/mini.nvim`, `yetone/avante.nvim` to
`avante-corp/avante.nvim`. New `core/` category; `search/` and `terminal/` gone.

---

## 2026-09-05 (first and second passes) — first full real install, plus a verification pass (condensed)

**One regression that broke `:w` on every save.** `lint.lua` called `lint.try_lint(always)` with
`always = { "typos" }` unconditionally; nvim-lint *raises* on a missing binary rather than
skipping, and the error propagated out of the `BufWritePost` callback into the write itself.
The instructive part is how it shipped: the pass that introduced it recorded the sandbox's
`Error running typos: ENOENT` as *confirmation the fix worked*, which was half right — it proved
the call reached the linter, and was also the failure mode in full view. The same exposure
applied to every entry in `linters_by_ft`. Five further defects were found only by installing all
plugins for real for the first time, none visible from reading specs alone.

**Earlier in the same day**, by verification rather than reading: `vim.highlight.on_yank` →
`vim.hl.on_yank`; `lint.lua`'s `["*"]` wildcard key removed (nvim-lint has no such key, so
`typos` had never run); the bare `t` tab prefix (`te`/`tn`/`tp`/`to`/`tq`) moved to
`<leader><Tab>*`, having shadowed the native `t{char}` motion on five letters and added a full
`timeoutlen` stall to the other twenty-one; `format_check` rewritten (it shelled `black --check`
for Python, absent from Mason's list and contradicting conform's `ruff_format`) to be async,
per-filetype matched to conform, and gated on autoformat being off; `lualine.lua`'s ahead/behind
component ran `git fetch origin` on every `BufEnter`, now throttled to 30s via `utils.throttle()`.

Also: 35 comment lines across 22 files rewritten out of first/second person; `utils.lua` pruned of
seven uncalled functions; `shortmess:append("S")` dropped, traced to a jdhao option assuming a
companion plugin never installed here; `img-clip.nvim` added; autopairs `check_ts = true`;
`jumpoptions = "stack,view"`; `nvim-nio` moved into `deps/shared.lua`. Declined with reasons that
still stand: fidget.nvim, nvim-spider, nvim-navic, nvim-hlslens.

---

## 2026-08-28 — standing candidate backlog cleared (condensed)

11 plugins added, 3 declined. Added: `guess-indent`, `git-conflict`, `window-picker` +
`stickybuf`, `neogen`, `satellite`, `nvim-bqf`, `hlargs`, `modicator`, `colorful-winsep`,
`rustaceanvim`, and the `mini.icons` swap. Each configured from a fresh clone rather than from
memory, which caught four things a from-memory config would have got wrong: `stickybuf`'s
built-in filetype list already covers most of this config's utility buffers;
`nvim-window-picker`'s `tbl_deep_extend` merge matches list-like tables by index, so an
additions-only filetype list would have silently overwritten upstream's four defaults; `neogen`'s
snippet engine had to be `"nvim"`, not `"luasnip"`, which is not installed here;
`git-conflict`'s real default keys are `co`/`ct`/`cb`/`c0`/`]x`/`[x`, all buffer-local.

**`mini.icons` replaced `nvim-web-devicons` outright.** `mock_nvim_web_devicons()` registers a
real shim into `package.preload`/`package.loaded` under that exact name, which is what makes it a
swap rather than two icon systems side by side. All eleven consumers repointed at
`echasnovski/mini.nvim`; `plugins/deps/web-devicons.lua` deleted, not left installed-but-unused.
`mini.lua` moved to `lazy = false, priority = 1000` so the mock registers before alpha.lua's
`VimEnter` dashboard asks for an icon.

**One real bug caught before shipping**, by reading the append mechanism rather than assuming
append-only semantics: rustaceanvim discovers Rust runnables via `table.insert` into
`dap.configurations.rust`, and `dap.lua` assigned that key `= dap.configurations.cpp` — the same
table by reference. Every discovered Rust runnable would have appeared in the C/C++ debug picker
too. Fixed with `vim.deepcopy()`. `rust_analyzer` removed from `lspconfig.lua`'s `servers`
(upstream warns against running both) but kept in mason's `ensure_installed`.

Declined with reasons that still stand: `sidekick.nvim` (needs its own
`copilot-language-server` client alongside copilot.lua's bundled agent — an architectural fork,
not a granular add), `eyeliner.nvim` (flash.lua already replaces `f`/`F`), `hydra.nvim`
(multicursor.lua's `addKeymapLayer` covers the one structurally similar case).

---

## 2026-08-27 — nested tree reconstructed, monokai-pro added as a 4th theme (condensed)

`monokai-pro.nvim` added to `themes.lua`'s switcher, verified against its own
`config/defaults.lua` rather than its README, which omits a seventh filter (`"light"`).

**A real latent bug surfaced while building it**: `Controller.apply()` cleared cached modules with
`pkg:match("^" .. s.theme)`, treating the theme name as a Lua *pattern*. Every prior theme name
was pattern-safe; `monokai-pro` is the first containing a `-`, which in a pattern means "0 or more
of the preceding item", not a literal hyphen — so it would have silently failed to clear
monokai-pro's `package.loaded` entries, leaving stale modules behind rather than erroring. Fixed
with `gsub("%p", "%%%0")`.

Two stale-documentation fixes: `bufferline.lua` refreshes its own highlights through its own
internal `ColorScheme` autocmd, not through `themes.lua`'s `ThemeChanged` event; `avante.lua`'s
model string was a dated May-2025 pin, updated to the current rolling alias.

---

## Earlier passes (2026-08-20 and before) — conclusions only

**Structure.** `lua/plugins/init.lua` went missing on seven separate deliveries — always the same
cause: it shares the basename `init.lua` with the root file, and whichever a flattening tool
processes last silently wins. Fixed at the root cause by renaming it `plugins/loader.lua`.
lazy.nvim's `lsmod()` resolves a plain module file and a `dir/init.lua` package through the
identical branch, so the rename costs nothing. The nested tree — `config/` for editor behaviour,
`plugins/<category>/` one file per plugin, `deps/` for multi-consumer libraries — has been
re-examined at every pass and kept.

**Keymap conflicts resolved toward Neovim's built-ins.** `trouble.lua`'s `[d`/`]d` removed
(shadowed native diagnostic-jump). `textobjects.lua`'s parameter swap moved off `]p`/`[p` (native
indent-paste) to `<leader>a`/`<leader>A`; its class navigation off `]c`/`[c` (native diff-mode
nav) to `]m`/`[m`/`]M`/`[M`, which freed `]c`/`[c` for gitsigns; its parameter nav off `]a`/`[a`
(native argument-list) to `],`/`[,`. `todo-comments`' jumps moved off `]t`/`[t` (native ctags
tag-stack) to `]n`/`[n`. `<Leader>` normalised to `<leader>` throughout.

**Real bugs found and fixed.** `options.lua`'s `shell = "nushell"` pointed at a nonexistent binary
(the real name is `nu`) — every terminal session failed to spawn. `lspconfig.lua` and
`conform.lua` both independently ran format-on-save; lspconfig's copy removed. `ufo.lua`'s
`provider_selector` didn't match its own comment and left nothing to catch a treesitter failure —
rewritten to upstream's documented chain so `indent`, which cannot itself throw, has the last
word. `dap.lua`'s breakpoint signs had empty `text` fields, so no gutter icon ever appeared.
`bufferline.lua` had a dead `_G.TokyoColors()` reference. `lualine.lua` duplicated
`utils.get_virtual_env()` inline. `vim.loop` → `vim.uv` across three files. `noice.lua`'s
`lsp_doc_border = false` was the actual reason `K`'s hover had no border — Noice registers its own
hover handler, so the `border` passed to `vim.lsp.buf.hover()` never reached it.

**avante.nvim's `<leader>a` ambiguity**, root-caused rather than worked around: `auto_set_keymaps`
registers avante's own `<leader>a*` maps regardless of this config choosing `<leader>i*`
specifically to avoid them, because avante's installer only inspects lazy.nvim's declarative
`keys` registry and can't see `textobjects.lua`'s plain `vim.keymap.set`. Net effect: `<leader>a`
became simultaneously a leaf and a prefix. Turned off, and avante's other default actions given
deliberate `<leader>i*` slots.

**Replacements.** `mini.bufremove` → `bufdelete.nvim` (itself retired 2026-09-05, see top);
`mini.hipatterns` → `nvim-colorizer.lua`; `indent-blankline.nvim` → `snacks.indent`, whose
per-level highlights point at `utils.rainbow_delimiter_groups` so brackets and indent levels share
one colour source. `utils.cowboy()` → `hardtime.nvim`. `mini.ai` kept.

**Settled, re-confirmed, not re-changed.** `foldcolumn = "1"` is deliberate: statuscol's
`foldfunc` renders one glyph per fold-start line regardless of depth, so a wider column caps
nothing. `foldnestmax` removed as a genuine no-op under `foldmethod=manual`. `mason.lua`'s
`selene`/`luacheck` removed as dead weight (no matching `lua` entry in `lint.lua`).
`autocmds.lua`/`utils.lua` stay single files. Reference repos with nothing extracted:
nshen/learn-neovim-lua (a superseded course companion whose utils call a nonexistent
`nvim_add_user_command`); linkarzu/dotfiles-latest's keymaps (4,528 lines, almost entirely a
personal blogging workflow).
