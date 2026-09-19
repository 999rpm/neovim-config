# Config log

What changed, and the reason it changed. Newest first. Older passes are condensed to their
conclusions once a later pass has confirmed them.

## 2026-09-19 (sixth pass) — claims re-checked against upstream source, shadowed built-ins returned

This pass verified the fifth pass's conclusions rather than trusting them, then fixed what the
check turned up. Every finding below was confirmed against upstream source, not inferred from a
README or from the shape of the code.

### Four claims that were checked and turned out correct

Worth recording so a later pass does not "fix" them back:

- `{ buf = ... }` in `vim.keymap.set` is right, not a typo for `buffer`. Neovim added `buf` in
  0.12 (`runtime/lua/vim/keymap.lua`, release-0.12 branch) and the in-tree TODO soft-deprecates
  `buffer` in 0.13. `nvim_create_autocmd` and `nvim_clear_autocmds` carry the same pair, with
  `buffer` marked deprecated in `api/keysets_defs.h`. Seven files use it; all seven are current.
- `rustaceanvim` `version = "^9"` resolves (v9.2.1), `barbar` `^1.0.0` resolves (v1.9.1),
  multicursor's `1.0` branch exists.
- hardtime's dict-shaped `disabled_filetypes`, better-escape's `default_mappings = false` and
  lualine's list-shaped `disabled_filetypes` are all accepted by the current plugins.
- `messagesopt`'s `progress:c` is a real value in 0.12's option schema.

### Claims that did not survive the check

**`&t_Cs` / `&t_Ce` never did anything.** `option.c` routes tty options through `is_tty_option()`
and returns silently ("Fail silently; many old vimrcs set t_xx options"). The two lines setting
undercurl escape sequences were inherited from a Vim config and have been no-ops here since day
one. Undercurl comes from terminfo. Removed.

**The `diffopt` version branch was dead, and had the wrong model of the option.** 0.12's default is
`internal,filler,closeoff,indent-heuristic,inline:char,linematch:40`. `inline:` highlights changed
characters inside a line; `linematch:` aligns similar lines across a hunk. They are complementary,
not alternatives, so the `has("nvim-0.12")` branch appended a value that was already the default
and never reached the `linematch:60` in its else arm. init.lua requires 0.12 anyway, so the else
arm was unreachable. Both values are now set, and the four defaults that were being re-appended are
gone.

**nvim-surround's opt-out was set too late to fire.** Upstream's doc is explicit: the
`g:nvim_surround_no_*_mappings` flags "must be set before the plugin is loaded", and
`plugin/nvim-surround.lua` reads them at source time. It was set inside `config`, which lazy.nvim
runs after sourcing `plugin/`, so `ys`/`yss`/`yS`/`ySS`/`ds`/`cs`/`cS` were mapped the whole time
while a comment two lines up said "only Visual S/gS remain". The file header described the real
behaviour and the inline comment described the intent. The dead line is gone and the default
keymaps are kept, since `ys`, `ds` and `cs` shadow nothing.

**`debounce_text_changes = 500` was still in `lspconfig.lua`.** The fifth pass recorded removing
it. It had not been removed. Gone now; the default is what every server, rustaceanvim included,
should see.

**`dap.configurations.c = dap.configurations.cpp` shares one table by reference.** This is the
exact bug the third pass found and fixed for `rust` via `deepcopy`, left in place for `c`. Anything
that appends a discovered runnable to one language's list puts it in the other's picker. Now a
deepcopy, like rust.

**Three "This util is used by" lists named files that never called the helper.** `augroup` listed
`barbar.lua`, which has no augroup and, contrary to the fifth pass's notes, no `ColorScheme` hook
either; `rainbow_delimiter_groups` listed `satellite.lua`; `warn_if_missing_exec` listed
`mcphub.lua`, which warns inline instead, and omitted `hex.lua`, which does call it. Corrected
against a grep of actual call sites.

**No `.stylua.toml` existed.** conform runs stylua on every Lua save and the log claims the tree is
formatted at tabs / 140 columns. Without the file, stylua uses its own defaults (spaces, 120
columns), so the first save of any file would have reflowed it and every later diff would have
fought the one before. Added.

### Built-ins returned to Neovim

One earlier decision had cascaded. `<C-a>` was taken for select-all, which left dial.nvim without
the increment key, so dial took `>` and `<` — the indent operators, which have no replacement and
no plugin offering an equivalent. Two built-ins were spent to gain one convenience.

`<C-a>`/`<C-x>` go back to increment, with dial widening what they understand rather than replacing
them; `>`/`<` are the indent operators again; select-all is `<leader>na`. dial also moved from an
eager `config` to declarative `keys`, so it no longer loads at startup.

Insert-mode `<C-e>` was `<Esc><cmd>wq<CR>`. It shadowed "copy the character below the cursor" on
every keystroke, and hung write-and-quit off a single unmodified chord next to `<C-w>` and `<C-u>`.
Removed. `blink.lua`'s header had been advertising `<C-e>` as hide-completion without the keymap
table binding it; it is bound now, with `fallback`, so the built-in works whenever no menu is open.

`vim.g.no_plugin_maps = true` in `textobjects.lua` silences the mappings in every runtime ftplugin,
far wider than the two opt-outs options.lua sets on purpose (`no_gitrebase_maps`, `no_man_maps`),
and nothing in nvim-treesitter-textobjects reads it. Removed.

`H`/`L`, `;`, `q`, `x`/`X`, `f`/`F`, `s` and visual `R` stay taken. Each is deliberate, each has a
covering alternative, and README now tabulates the trade rather than leaving it in a comment.

### Buffer scoping and event correctness

- `non_utf8_file` read `vim.bo` (the current buffer) on a `BufRead` that can fire for another
  buffer, and treated an empty `'fileencoding'` — a new or empty file — as non-UTF-8. Reads
  `vim.bo[ev.buf]` and skips `""`.
- The node_modules handler passed `bufnr = 0` for the same reason. Passes `ev.buf`.
- `undo_disable` and `secure_tmp` both matched `/tmp/*` and both suspended and restored the global
  `'backup'` flag around the same write. `secure_tmp` already covers every tmp path, so
  `undo_disable` keeps only the patterns it alone matches.
- `auto_close_win` counted floating windows toward "only utility windows remain", so a picker or
  notification float over a lone neo-tree could reach `qall`, and it ran while the command-line
  window was open, which cannot be left that way. Floats are skipped and the cmdwin returns early.
- The right-click menu ran `autocmd! nvim.popupmenu` on every single click, which raises E367 once
  the group is gone. Done once, guarded by `pcall`. The two identical `if not _G.Snacks` branches
  next to it are one branch.

### Cost per redraw

`lualine`'s `trailing_space` and `mixed_indent` ran up to five whole-buffer regex searches on every
statusline redraw, which with `globalstatus` means every cursor move. New `utils.buf_cached()`
memoises on `b:changetick`, so each scans once per edit. The yank-position tracker allocated a
table on every `CursorMoved` in every mode; it now records only in normal and visual mode, and
stores `winsaveview()` rather than `getcurpos()`, so a yank near the window edge no longer scrolls
the screen back.

`copilot.lua` had no lazy trigger at all and loaded at startup despite binding insert-mode keys
only. Now `event = "InsertEnter"`.

### Comments, structure and grouping

The `<Tab>`/`<S-Tab>` menu binding was copied into `nvim-bqf.lua` and `harpoon.lua`; both call the
new `utils.menu_nav()`. `autocmds.lua` mixed `vim.api.*` with the local `api` alias it defines;
normalised. `<leader>no`/`<leader>nO` reimplemented what `formatoptions` minus `c,r,o,t` plus the
`format_options` FileType hook already do, and are gone. Four `{ "n", "v" }` maps were narrowed to
`{ "n", "x" }`, since `x`, `X` and `<space>` must stay literal in select mode.

which-key's spec is regrouped around a stated rule — lowercase is the common action, the uppercase
twin is its wider or rarer form (`d`/`D` lists vs debug, `g`/`G` hunks vs review, `t`/`T` terminal
vs test) — with section comments, entries for `<leader>a`/`<leader>A`, which had none, and
labels for the `ys` and `<C-w>` prefixes so the native keys show up in the popup too.

### Verification

All 81 Lua files parse. Upstream sources were cloned or fetched for nvim-surround, hardtime,
better-escape, lualine, nvim-lint and Neovim itself (`keymap.lua` on both master and release-0.12,
`keysets_defs.h`, `option.c`, `options.lua`, `news.txt`); plugin tags were resolved with
`git ls-remote`. The lockfile's 89 entries all correspond to a live spec and no spec is missing
from it. Keymaps were extracted across the tree and cross-checked for same-mode collisions.

Not done here: the reference configs were not re-read line by line. Earlier passes' notes on them
stand, including the two marked as yielding nothing.

### Open for next pass

- barbar's rendering across every theme in the switcher is still only observed on tokyonight and
  monokai-pro. The fifth pass's note about a `ColorScheme` repaint hook in `barbar.lua` refers to
  code that is not in the file; whether it was dropped or never landed is unresolved.
- `lint.lua` calls `lint._resolve_linter_by_ft`, a private function. It is what nvim-lint's own
  `try_lint` uses internally, so it is unlikely to move, but it is not public API.
- text-case.nvim (2024-08) and neotest's FixCursorHold recommendation remain the unmaintained
  surface, with no drop-in replacement.
- avante's build needs cargo and was not exercised.

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
