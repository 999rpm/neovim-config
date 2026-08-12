# Config log

Single running log for this config. File headers describe *what a file currently does and why*;
this file is the *history* — what changed, when, why, and what to check next time. Read this
before making a change (per-file headers won't repeat reasoning that lives here), and add an
entry here (not back into a file header) after making one.

Newest entry first.

---

## 2026-08-12 — plugin-loading bug, ufo/fold bugs, JS diagnostics, Haskell, UI polish

Trigger: a follow-up request covering (1) a line-by-line comparison against jdhao/nvim-config,
craftzdog/dotfiles-public, xero/dotfiles, and rafi/vim-config with special focus on
lspconfig.lua, (2) skewed lualine/bufferline separators, (3) full Haskell support, (4) a dimmed
backdrop behind Telescope/floating-terminal popups, (5) the indent-guide tree-structure
question, (6) a still-live `nvim-ufo` error trace, and (7) fold arrows not nesting. Also folded
in: move every file's dated history out of its own header and into this log, so files stay
readable as pure current-state documentation.

**Everything below was checked against real, current upstream source — cloned fresh from GitHub
(lazy.nvim, nvim-ufo, nvim-treesitter, nvim-lspconfig, statuscol.nvim, snacks.nvim,
mfussenegger/nvim-dap's own wiki, bufferline.nvim, hlchunk.nvim) — not assumed from memory or
carried over from an earlier pass's claims. Two claims from the 2026-08-06 entry below turned
out to be wrong on inspection (see "Corrections" at the end); this pass verifies its own claims
independently rather than repeating that pattern.**

### 1. `lua/plugins/init.lua` was missing — this is why plugins may not load at all

Not present in the files handed to this pass (a project-knowledge upload quirk: both this file
and the root `init.lua` are literally named `init.lua`, and only one survived the sync). Its
absence is silent and total: lazy.nvim's own module discovery (`lazy/core/util.lua`'s `lsmod`)
scans one directory level at a time via `vim.uv.fs_scandir` and only descends into a subfolder
if that subfolder has its own `init.lua` — confirmed by reading that function directly, not
assumed. None of this config's category folders (`lsp/`, `ui/`, etc.) has one, so a bare
`{ import = "plugins" }` in `config/lazy.lua` finds nothing inside them at all.

Reconstructed the file (`{ import = "plugins.lsp" }` etc. for all 12 category folders) and
proved the fix two ways under a real, downloaded Neovim 0.12.4 binary — not just by reading
source:
- Ran lazy.nvim's actual `lsmod` against this config's real directory tree.
- Recursively simulated lazy.nvim's full import-expansion (the same logic
  `lazy/core/plugin.lua`'s `Spec:import` uses) end to end: **49 leaf plugin spec files
  discovered**, matching exactly (50 files under `lua/plugins/` minus `plugins/init.lua`
  itself). See the transcript of that run for the full file list.

Also fixed two now-stale claims that referenced the *opposite*, incorrect belief ("lazy.nvim's
`{ import = "plugins" }` walks subdirectories recursively on its own") in `init.lua`'s and
`config/lazy.lua`'s own comments — both corrected to describe what's actually true.

### 2. `nvim-ufo`'s `UfoFallbackException` spam in `:Noice history`

Root cause: `provider_selector` returned `{ "lsp", "treesitter" }`. Per nvim-ufo's own README
("'lsp' and 'treesitter' as main provider, 'indent' as fallback provider") and its
`doc/example.lua`, only `'indent'` is a safe *unconditional* fallback — it's the one provider
that can't itself throw. Putting `'treesitter'` in that slot means that when treesitter *also*
can't produce folds for a buffer (missing/broken parser, or a construct its `folds.scm` doesn't
cover), there's nothing left to catch the exception, and it surfaces as an unhandled promise
rejection — exactly the error trace reported.

Fixed with nvim-ufo's own documented pattern (`doc/example.lua`'s
`selectProviderWithChainByDefault`, which rafi/vim-config also uses verbatim for the same
reason): a `customize_selector` function that chains `lsp -> treesitter -> indent`, explicitly
catching `'UfoFallbackException'` at each stage and retrying with the next provider. See
`plugins/ui/ufo.lua`.

**Likely compounding factor, also fixed (see §5):** `nvim-treesitter`'s `ensure_installed` list
was decorative only — nothing actually called `.install()` on it, so any parser never manually
installed via `:TSInstall` (plausibly `javascript`, matching the "no ufo arrows in .js files"
report) would make the treesitter provider fail immediately for that filetype, on every fold
request, which is exactly the failure pattern the exception trace shows.

### 3. Fold arrows not nesting — "one vertical line", "two arrows on one line"

The 2026-08-06 entry below narrowed `foldcolumn` from `"4"` to `"1"` to fix a reported
double-glyph symptom. That entry's diagnosis doesn't hold up: `statuscol.nvim` completely
replaces Neovim's native foldcolumn renderer (the native rendering issues that entry cited,
neovim/neovim#14751/#21759, don't apply once statuscol.nvim owns the column). Read
`statuscol.nvim`'s actual `builtin.foldfunc` source directly to check: it renders
`range = min(fold_level, width)` columns, one glyph per nesting level. With `width` pinned to
`1`, `range` can never exceed `1` — nesting **cannot** be shown, however deep the actual folds
go, for any buffer, ever. That's the "flat vertical line" report, and it's a direct, inevitable
consequence of the previous fix rather than a separate bug.

(Two *different* glyphs appearing on the same line at two *different* columns, incidentally, is
what correct nested rendering looks like — a line simultaneously closing one fold and starting
another — not necessarily the bug the 2026-08-06 entry took it for. With width stuck at 1 that
distinction was moot either way.)

Fixed by widening `foldcolumn` to `"auto:4"` — a real Neovim option value (`:help
'foldcolumn'`), sized dynamically up to 4 to match `foldnestmax` (also 4, already set), costing
no extra column width on lines/buffers with no real nesting. See `config/options.lua`,
`plugins/ui/statuscol.lua`.

### 4. JS/TS files: no diagnostics, no ufo arrows

Two independent, compounding causes, both fixed:

- **`ts_ls`/`tailwindcss` never attached outside a git repo.** Both had a custom
  `root_dir = lspconfig.util.root_pattern(".git")` override plus `single_file_support = false`
  (`ts_ls` only). Checked nvim-lspconfig's own *current* `lsp/ts_ls.lua` and `lsp/tailwindcss.lua`
  directly: both now ship the modern async `root_dir(bufnr, on_dir)` pattern, which tries
  lockfiles/config markers, then `.git`, and — critically — **falls back to `vim.fn.getcwd()`
  if neither is found**, so it always attaches somewhere. There's no `single_file_support` flag
  in the current default at all; that mechanism is legacy. The override in this config
  actively *regressed* behavior relative to upstream's own current default: a standalone `.js`
  file with no `.git` upward got no server, no diagnostics, and no LSP folding range at all.
  Removed both overrides; they now inherit nvim-lspconfig's own default. See
  `plugins/lsp/lspconfig.lua`.
- **The `javascript` treesitter parser may never have actually been installed** — see §5. Ufo's
  treesitter fallback (§2) needs a real parser to produce folds at all.

### 5. `nvim-treesitter`'s `ensure_installed` was decorative only

`ts.install(ensure_installed)` was commented out, with a comment claiming it "can print noise
before parsers exist yet." Checked this directly against `nvim-treesitter`'s own
`install_lang()` source: for an already-installed language it returns immediately —
`if not force and vim.list_contains(config.get_installed(), lang) then return true end` — zero
I/O, zero output, not even an async yield. The "noise" concern doesn't hold up; the effect of
leaving it commented out is that `ensure_installed` never installed anything at all unless
`:TSInstall` was run by hand for every entry. Uncommented it (real no-op safety confirmed, not
assumed) and added `"haskell"` to the list. See `plugins/treesitter/treesitter.lua`.

Also worth knowing, unrelated to anything in this config specifically: `nvim-treesitter`'s
`main` branch requires Neovim **0.12.0+** (stated in its own README, and this is the exact
commit already pinned in `lazy-lock.json`). Confirmed 0.12 has been the current stable release
since March 2026, so this should be a non-issue on an up-to-date install — but if
`:checkhealth nvim-treesitter` or startup complains, check `:version` first; a real Neovim
0.12.4 binary was used for every runtime check in this pass.

### 6. Haskell support

Starting state was partial: `conform.lua` already had `haskell = {"ormolu"}`, `mason.lua`
already installed `ormolu` and `haskell-debug-adapter`, and `lspconfig.lua` already had `hls` as
an optional external server. Gaps closed:

- **Treesitter**: `"haskell"` added to `ensure_installed` (§5) — without this there was no
  syntax highlighting, textobjects, or treesitter-based folding for `.hs` files at all.
- **Debugging**: `mason-nvim-dap` was installing the `haskell-debug-adapter` binary, but nothing
  in `dap.lua` ever wired up `dap.adapters.haskell`/`dap.configurations.haskell` — the binary
  sat installed and unused. Added both, using mfussenegger/nvim-dap's own documented example
  from its wiki verbatim, `command` pointed at the Mason-installed binary path (matching how
  `codelldb` already does this in the same file) rather than assuming it's on `$PATH`. The
  default `ghciCmd` assumes a Stack project; the comment above it explains the cabal
  alternative, since this is inherently per-project the same way the C++ config already prompts
  per-run rather than hardcoding a path.
- **LSP**: added `formattingProvider = "ormolu"`/`cabalFormattingProvider = "cabal-fmt"` to
  `hls`'s settings, so a manual `:LspFormat` (which calls the LSP client directly, bypassing
  conform) matches what format-on-save already does.
- **Deliberately not changed**: `hls` stays in `external_servers` (executable-gated, not
  Mason-managed). Checked this against multiple current, still-open `mason-org/mason.nvim`
  GitHub issues plus haskell-language-server's own install docs: Mason's package for it has a
  persistent history of failing to match a project's actual GHC version (it shells out to
  `ghcup` under the hood), and HLS's own documentation recommends `ghcup` directly as the
  reliable path. The existing choice to keep this external was already correct; documented why
  rather than silently leaving it unexplained.

### 7. Skewed lualine / bufferline

`bufferline.lua`: `separator_style = "thin"` → `"slant"` (bufferline's own current
`doc/bufferline.txt` confirms `"slant"`/`"slope"`/`"thick"`/`"thin"` as the live option set).

`lualine.lua`: `component_separators`/`section_separators` were both **empty strings** — no
visual separation between statusline sections at all, skewed or otherwise. Set to the standard
Powerline glyphs (U+E0B0–U+E0B3; needs a Nerd Font, already assumed elsewhere in this config).
A pixel-identical angle match to bufferline's slant would need a custom empty-component spacer
per section (a technique documented in a LazyVim discussion thread) — noted in the file as an
optional next step, not implemented, since it's real added fragility for a marginal visual gain
over the standard glyph approach.

*(Process note: the first attempt at writing these glyphs — typed directly rather than via an
escape sequence — silently produced empty strings; caught by checking codepoints after the
fact, not by trusting the diff. Re-done via explicit UTF-8 byte computation. Worth remembering
for any future edit involving a character that can't be visually proofread in this
environment — verify the codepoint landed, don't assume it did.)*

### 8. Dimmed backdrop behind Telescope / floating-terminal popups

New file, `plugins/ui/float-backdrop.lua`. Uses `folke/snacks.nvim`'s own `backdrop` primitive
(`Snacks.win({ backdrop = ... })`) — the same mechanism its own picker/zen/scratch windows use
internally (read `lua/snacks/win.lua` directly to confirm, rather than assume the option
exists) — via a small, invisible anchor window rather than reaching into snacks' private
internals. No new plugin dependency: snacks.nvim is already installed and loaded eagerly.

Deliberately its own file rather than added to `telescope.lua`/`toggleterm.lua`/`snacks.lua`
directly: it depends on all three, but calls neither Telescope's nor toggleterm's own Lua API
anywhere — only generic `FileType`/`TermOpen`/`WinClosed` events and `nvim_win_get_config` — so
it stays correct across version changes to either plugin, and neither of those two files needed
to change at all.

### 9. Indent guides — SUPERSEDED same day, see §10 below

~~Kept `indent-blankline`, did not switch to `snacks.indent`/`mini.indentscope`~~ — this
conclusion was reversed a few hours later in the same session; see §10. Leaving the original
reasoning below rather than deleting it, since the underlying research (no plugin draws a
permanent whole-buffer tree) is still accurate and relevant to §10's decision too.

Re-confirmed on request. Checked `ibl`, `snacks.indent`, `mini.indentscope`, and
`hlchunk.nvim`'s docs directly: **none of the four draws real, context-sensitive tree-junction
characters (`├`/`┬`/`┴`/`┼`) continuously across a whole buffer.** All four use the same
one-virtual-character-per-indent-level model; `snacks.indent`/`mini.indentscope` additionally
animate that same single-character guide. `hlchunk.nvim` is the one partial exception: its
separate `chunk` mod *does* draw real box-drawing corners, but only around the current scope's
boundary box, not as a persistent whole-buffer tree.

Switching to `snacks.indent`/`mini.indentscope` would trade away the rainbow-color-matching +
treesitter scope-highlight integration already correctly wired to `rainbow-delimiters.lua` for
animation — a lateral move, not an upgrade, and it still wouldn't deliver the tree-junction
look that prompted the question. Kept `indent-blankline`. `hlchunk.nvim`'s `chunk` mod as an
*addition* alongside it (not a replacement) was offered but not implemented — a genuinely new
plugin dependency, left for an explicit decision rather than added unasked.

### 10. Follow-up, same day: switched to `snacks.indent` after all — §9 missed something

User feedback: indent-blankline's rainbow coloring reads as visual noise, and specifically asked
for `snacks.indent` with animation and box-drawing. §9's research checked `hlchunk.nvim`
specifically for box-drawing support but did not check `snacks.indent`'s own source deeply
enough before generalizing "same model as ibl" onto it too — that generalization was wrong.
Reading `lua/snacks/indent.lua` directly (not assumed, not re-derived from §9's hlchunk
findings): `snacks.indent` has its own `chunk` sub-feature, disabled by default, that renders
real `┌`/`└`/`─`/`│` box-drawing characters (plus a closing arrow/dash) around whichever scope
contains the cursor — read `M.render_chunk` directly to confirm exactly what it draws before
writing this. It is *not* a permanent multi-level tree (only the current scope gets boxed;
other levels stay plain single-character guides, same limitation §9 found everywhere else) —
but it's a materially better answer than §9 gave, and worth the correction being visible here
rather than quietly folded away.

Also checked before implementing: `snacks.indent`'s default highlight groups are single-color
on their own (`SnacksIndent` -> `NonText`, `SnacksIndentChunk`/`SnacksIndentScope` -> `Special`)
— the numbered `SnacksIndent1..8` rainbow-cycle variant exists but isn't the default, so getting
the "less noise" look didn't need any extra configuration beyond turning the modules on.

Changes: `plugins/ui/snacks.lua`'s `indent` block turned on with `chunk.enabled = true` and
`animate.enabled = true` (both explicit, though animate defaults on for Nvim >=0.10 already);
`chunk.char.arrow` changed from the plugin's own default `">"` to `"╴"` (U+2574), matching the
exact character your original request listed rather than the plugin's plain ASCII default.
`plugins/ui/indent-blankline.lua` deleted. Updated every cross-reference to it: `utils.lua`'s
`rainbow_delimiter_groups` tag (now only rainbow-delimiters.lua), `config/options.lua`'s
`foldtext` comment, `plugins/ui/lualine.lua`'s exclude-filetype comment,
`plugins/ui/themes.lua`'s `ThemeChanged` comment, `plugins/treesitter/rainbow-delimiters.lua`'s
header, and `init.lua`'s file-layout tree and feature overview. `rainbow-delimiters.nvim`
itself (bracket-pair coloring, a separate feature from indent guides) was left untouched — the
noise complaint was specifically about indent-guide rainbow, not bracket rainbow, and wasn't
raised as a separate concern.

Re-verified after the swap, same rigor as §1: full `luac5.1 -p` pass (55 files, one fewer than
§1's count), real `dofile()` of all 49 plugin spec files under a real Neovim 0.12.4 (0 errors),
and the same lazy.nvim recursive-import simulation from §1 re-run end to end — 48 leaf plugin
files discovered (49 total under `lua/plugins/` minus `plugins/init.lua` itself, consistent
with one file having been removed since §1's count of 49).

### Header cleanup (applies to every file touched this pass, and every file that had one)

Every file's dated "on 2026-0X-0X, audited/fixed..." paragraph has been removed from its own
header and folded into this log (mostly into the 2026-08-06 entry below, condensed). File
headers now describe current behavior and non-obvious current design decisions only — no
change-history narrative. Files whose only change this pass was this header trim: `init.lua`
(credits and feature overview kept, audit narrative removed), `config/autocmds.lua`,
`config/mappings.lua` (the "Review log" block removed outright — its content was already
redundant with each mapping's own `desc` field), `plugins/editor/mini.lua`,
`plugins/editor/textobjects.lua`, `plugins/git/gitsigns.lua`, `plugins/lang-tools/conform.lua`,
`plugins/terminal/toggleterm.lua`, `plugins/treesitter/rainbow-delimiters.lua`,
`plugins/ui/snacks.lua`, `plugins/ui/trouble.lua`, `plugins/ui/which-key.lua`, `utils.lua`.

### Testing this pass actually did

- All 56 `.lua` files pass `luac5.1 -p` (syntax-valid).
- Downloaded a real Neovim **v0.12.4** binary (current stable) and, under it: loaded
  `utils.lua` and all four `config/*.lua` files as real `require()` calls (not just parsed) —
  zero runtime errors, `utils.lua` exports confirmed at 18 members.
  `dofile()`'d all 50 files under `lua/plugins/` (their top-level `return {...}` table
  construction, which is everything that runs before lazy.nvim would call a plugin's own
  `config`/`opts` function) — zero errors.
- Ran lazy.nvim's actual `lsmod` and a full recursive simulation of its real import-expansion
  logic against this config's real directory tree — 49/49 leaf plugin files discovered
  correctly (§1).
- Cross-file check, run programmatically: `mason.lua`'s `ensure_installed` vs `lspconfig.lua`'s
  `servers` table — still an exact match, 18/18 both directions, after this pass's edits to
  both files.
- Checked for duplicate `999rpm-*` augroup names across the whole config: none (37 unique).
- Did **not** attempt a full plugin install/bootstrap (all ~50 real plugins, LSP servers via
  Mason, treesitter parser compilation) — that's a materially bigger undertaking than this
  pass's actual code changes warranted, and the parts of the config untouched this pass were
  already reported as working. If something in the untouched 40+ files turns out not to load
  on your machine, that's not something this pass's testing would have caught.

### Corrections to the 2026-08-06 entry below

Two claims in that entry don't hold up under this pass's direct source-checking, noted here
rather than silently edited away:
- "`lazy.nvim`'s own recursive `import` handles this with no changes needed to `lazy.lua`" —
  wrong; see §1. The same entry's own "Addendum" section already contradicted this claim, which
  should have been removed rather than left standing next to its own correction.
- "`foldcolumn = '4'`... not a bug in ufo or statuscol" fixed by narrowing to `'1'` — the root
  cause (a native Neovim foldcolumn rendering bug) doesn't apply once statuscol.nvim owns the
  column; see §3. The fix "worked" in the narrow sense of eliminating the reported symptom, but
  did so by making nested rendering impossible outright rather than by fixing an actual defect.

### Check next time

- Confirm actual installed Neovim version is 0.12+ (`:version`) — needed by nvim-treesitter's
  `main` branch; see §5.
- If you're on a cabal (not stack) Haskell project, edit `dap.lua`'s `ghciCmd` per the comment
  above it before trying to debug.
- If the float-backdrop's `zindex = 45` ever renders in front of a popup instead of behind it
  (possible if some other plugin sets a floating window's zindex below 50), raise the popup's
  own zindex or lower 45 further — see `plugins/ui/float-backdrop.lua`.
- `bufferline.lua`'s `"slant"` can look wrong in some terminal emulators (padding/line-height
  dependent, per bufferline's own docs) — try `"padded_slant"` if so.
- `snacks.indent`'s `chunk` box only draws once a scope is at least one `shiftwidth` deep (its
  own source: `show_chunk = show_chunk and (scope.indent or 0) >= state.shiftwidth`) — don't
  expect a box at true top-level (module-level) code, that's expected, not a bug.
- If `snacks.indent`'s animation feels too slow/fast, `animate.duration` (step/total ms) and
  `animate.style` (`"out"`/`"up_down"`/`"down"`/`"up"`) are the knobs — see §10.

---

## 2026-08-06 — config-wide audit (condensed)

Full file-by-file read of the whole config, cross-checked against fresh clones of all four
reference configs. Real bugs found and fixed:

- `config/options.lua`: `shell = "nushell"` pointed at a binary that doesn't exist (the real
  executable is `nu`) — every `:terminal`/toggleterm session failed to spawn and closed
  immediately. Fixed to `"nu"`, gated behind `utils.executable()`.
- `config/options.lua`: `foldcolumn = "4"` — narrowed to `"1"` to fix a reported "two fold
  arrows on one line" symptom. **Revisited 2026-08-12 above — the underlying diagnosis didn't
  hold up; see the Corrections section above.**
- `plugins/ui/ufo.lua`: `provider_selector` returned `{"lsp","indent"}` while the file's own
  comment claimed `{"lsp","treesitter"}`; fixed to match the comment. **Superseded 2026-08-12
  above by a proper 3-tier chain — the 2-tuple form itself was the deeper issue.**
- `plugins/lsp/lspconfig.lua` vs `plugins/lang-tools/conform.lua`: both independently ran
  format-on-save; removed lspconfig.lua's copy, conform.lua is the sole owner.
- `plugins/ui/bufferline.lua`: removed a `_G.TokyoColors()` reference defined nowhere in the
  project (always silently no-opped).
- `plugins/ui/lualine.lua`: removed a hand-rolled venv lookup that duplicated
  `utils.get_virtual_env()` byte-for-byte; now calls the shared one.

Keymap conflicts with Neovim's own built-ins, resolved in favor of the built-in:
`plugins/ui/trouble.lua`'s `[d`/`]d` (shadowed native diagnostic-jump) removed;
`plugins/editor/textobjects.lua`'s parameter swap moved off `]p`/`[p` (native indent-paste) to
`<leader>a`/`<leader>A`; its class navigation moved off `]c`/`[c`/`]C`/`[C` (native diff-mode
nav) to `]m`/`[m`/`]M`/`[M`, freeing `]c`/`[c` for `plugins/git/gitsigns.lua`'s own hunk nav.

Replaced with standalone plugins: `mini.bufremove` → `famiu/bufdelete.nvim`,
`mini.hipatterns` → `catgoose/nvim-colorizer.lua`. `mini.ai` kept (no equivalent standalone
alternative). `snacks.indent` → `lukas-reineke/indent-blankline.nvim` (rainbow + scope
highlighting; no animation — see the 2026-08-12 entry above for the fuller, re-verified
comparison against snacks/mini/hlchunk).

New: a right-click context menu (`config/autocmds.lua`'s `MenuPopup` block), adapted from
rafi/vim-config, extending Neovim's own default `PopUp` menu with LSP/diagnostic/picker/git
actions, each disabled when the relevant capability or plugin isn't available.

Structural: `plugins/` grouped into category folders instead of one flat ~50-file directory.
**The claim that this needed no change to `lazy.lua` was wrong — see `plugins/init.lua` and the
2026-08-12 entry's §1 above; that file was missing from this delivery.**

Every custom augroup routes through `utils.augroup()`. `utils.lua` gained
`rainbow_delimiter_groups` (shared by `rainbow-delimiters.lua` and `indent-blankline.lua`).

---

## Earlier passes (2026-07-31 and before)

Audited every option in `config/options.lua` against then-current Nvim docs/behavior for stale
comments and silent conflicts (statuscolumn's relativenumber awareness, the shada/viminfo
rename, `winborder` being set twice, the mouse-mode comment, a stray duplicate `mdx`
treesitter-register line). All resolved; not re-narrated in detail here since nothing from this
window is still open.
