# Config log

Single running log for this config. File headers describe *what a file currently does and why*;
this file is the *history* — what changed, when, why, and what to check next time. Read this
before making a change (per-file headers won't repeat reasoning that lives here), and add an
entry here (not back into a file header) after making one.

Newest entry first.

---

## 2026-08-12 — tree-sitter CLI errors, sharp-to-rounded corners, keymap-vs-builtin conflicts, dependency architecture, fold-column rework

Trigger: a follow-up pass covering five concrete reports — (1) real `:messages` spam,
nvim-treesitter's `main` branch failing to compile every parser with `tree-sitter CLI not
found`, (2) `:Noice history` going quiet, (3) sharp-vs-rounded box-drawing corners throughout,
(4) whether `float-backdrop.lua` (added in the entry below) earns its keep, (5) stale `"slant"`
comments after bufferline/lualine were switched to `"slope"` — plus a full compatibility/
redundancy pass across every file, and a specific ask: make ufo's fold arrows work at unlimited
nesting depth by aligning with snacks.indent's own (uncapped) guide column instead of a
fixed-width foldcolumn.

**Verified against real, current upstream source for every claim below**, cloned fresh:
nvim-treesitter (`main`), noice.nvim, bufferline.nvim, mason-registry, mason-lspconfig.nvim,
statuscol.nvim, snacks.nvim, lazy.nvim — plus Neovim's own bundled `$VIMRUNTIME` (a real,
downloaded v0.12.4) for every native-keymap claim, and lazy.nvim's actual `Spec.new()` resolver
run end to end against this config's real directory tree (not just `lsmod`, as the entry below
did — the full resolution pipeline, including every `dependencies` merge).

### 1. Real bug: nvim-treesitter's `main` branch needs the standalone `tree-sitter` CLI

Confirmed by reading `install.lua` directly: `do_compile` unconditionally shells out to
`tree-sitter build`/`tree-sitter generate` — no C-compiler fallback exists in the current
source, and `health.lua` explicitly checks for the CLI and errors if it's missing. This is a
genuine, current, external system requirement, not a config bug — and it's a direct,
predictable consequence of §5 in the entry below (`ensure_installed` was fixed from a
commented-out no-op into a real `ts.install()` call): before that fix nothing ever tried to
compile a parser, so nothing could hit this error; after it, every one of the ~25 languages in
`ensure_installed` tries and fails identically, once each, every startup.

Two-part fix:
- `mason.lua`'s `ensure_installed` gained `"tree-sitter-cli"` — confirmed present in Mason's
  own registry (`tree-sitter-cli`, v0.26.12, prebuilt binaries, no compiler needed for the CLI
  itself). This is the actual, self-healing fix: Mason installs to a directory it already adds
  to `$PATH`, so once it syncs once, the problem doesn't recur.
- `treesitter.lua`'s `ts.install(ensure_installed)` call is now gated behind
  `require("utils").executable("tree-sitter")`, with a single clear `vim.notify()` warning
  (not 25 stacked ENOENT errors) if it's missing — same pattern already used for `nu`/`rg` in
  `options.lua`. Only fires for real between a fresh install and Mason's first sync.

### 2. `:Noice history` showing nothing — not a bug

Traced through noice.nvim's real source. Routes/`skip` (what `noice.lua` configures) only
controls *live display* — `message/manager.lua`'s `M.add()` unconditionally records every
message into a separate persistent `_history` table regardless of routing. `:Noice history`
itself filters that table via Noice's own unmodified default (`commands.history`'s filter:
`notify` / `error` / `warning` / plain `msg_show` / `lsp message` events only). Before §1 of the
entry below was fixed, every `UfoFallbackException` was hitting that filter as an error,
populating history; once those stopped, there's simply nothing new to show. Confirmation the
fix worked, not a regression.

### 3. Sharp-to-rounded corners

Every box-drawing character in the config found via a full-tree scan (Python, the actual
`\u2500`–`\u257F` Unicode block — not a guess at which files "look relevant"). Changed:
`snacks.lua`'s indent `chunk` box (`corner_top`/`corner_bottom`: `┌`/`└` → `╭`/`╰`),
`lspconfig.lua`'s ASCII-art keymap reference box (all four corners, re-verified 66-char-wide
alignment after), `neo-tree.lua`'s `last_indent_marker` (`└` → `╰`), `trouble.lua`'s
`icons.indent.last` (`└╴` → `╰╴`). Deliberately **not** touched: `options.lua`'s window-split
fillchars (T-junctions/crosses have no rounded Unicode equivalent) and `gitsigns.lua`'s sign
column (plain vertical lines, no corners involved). `init.lua`'s file-layout tree comment and
`neo-tree.lua`'s non-`last` indent markers are tree/indent *connectors*, not box corners, and
were left alone on purpose.

### 4. `float-backdrop.lua` removed

Added in the entry below; on reflection (and per direct instruction) not worth its complexity
for what it did. Deleted, along with all three cross-references: `snacks.lua`'s header (it
built on snacks' window primitive), `toggleterm.lua`'s header, and `init.lua`'s file-layout tree
and feature-overview bullet list.

### 5. Bufferline/lualine: comments only, styles confirmed correct and left untouched

**Explicit instruction this pass: the person had personally checked and verified both styles —
fix documentation, do not touch values.** `bufferline.lua`'s header and inline comment still
said `"slant"`; the actual, working `separator_style` is `"slope"` (confirmed as a real, distinct
bufferline.nvim option — "slanted but sloped to the right" — via bufferline's own source; the
terminal-rendering fallback is `"padded_slope"`, not `"padded_slant"`). Comment corrected to
match; `separator_style` value never touched.

**A mistake made and caught, mid-session, on `lualine.lua`:** this pass initially misread
`component_separators`/`section_separators` as empty strings — they render as literally nothing
in plain-text tool output (`cat`, `grep`, `view`) — and stated that as a "real functional bug."
Wrong. The person supplied a screenshot proving otherwise; checking the actual file bytes
(`repr()`, not the terminal display) confirmed real, non-empty codepoints: `U+E0BA`–`U+E0BC`,
Nerd Font **Powerline Extra Symbols** (`ryanoasis/powerline-extra-symbols`'s "angly" separator
variants, a Private-Use-Area range distinct from the classic `U+E0B0`–`U+E0B3` arrows) — a
font-rendering gap in this session's own tooling, not an empty string in the file. Comment
rewritten to document the real codepoints and explain why they can look blank in a plain-text
view; the separator values themselves were never edited, byte-for-byte identical throughout
(verified by codepoint before and after, not by re-reading the diff). Worth remembering: check
raw bytes before asserting something is "empty," the same discipline the `2026-08-06` entry's
own UTF-8-encoding lesson already called for.

### 6. `lua/plugins/init.lua` missing again — same failure mode as §1 below, same fix

Absent from this delivery for the identical reason documented below (the root `init.lua` /
`plugins/init.lua` filename collision in project-knowledge sync). Reconstructed identically;
also re-fixed `config/lazy.lua`'s header, which had reverted to the same stale "lazy.nvim
recurses into subfolders on its own" claim the entry below already corrected once.

### 7. Keymap-vs-native-builtin conflicts, resolved in favor of the builtin

Full sweep of Neovim's real `$VIMRUNTIME/lua/vim/_core/defaults.lua` "vim-unimpaired style"
block (every `[x`/`]x` native default catalogued: `d/D`, `q/Q/<C-q>`, `l/L/<C-l>`, `a/A`,
`t/T/<C-t>`, `b/B`, `<Space>`) turned up two this config was shadowing that the `2026-08-06`
sweep below missed:
- `plugins/editor/textobjects.lua`'s `]a`/`[a` (parameter-start nav) shadowed native
  `:next`/`:previous` (argument-list nav). Moved to `],`/`[,` — reuses this same file's own
  `a,`/`i,` parameter-select mnemonic rather than inventing a new one.
- `plugins/editor/todo-comments.lua`'s `]t`/`[t` shadowed native `:tnext`/`:tprevious` (tag-stack
  nav). Moved to `]n`/`[n` (confirmed free against the same exhaustive list).

Also documented, not remapped (native impact judged negligible): `textobjects.lua`'s `]]`/`[[`
(jsx nav) technically shadows Vim's ancient `{`-at-column-1 section-jump default, which
essentially never matches in this config's actual filetypes under 2-space indent.

Separately: `comment.lua`'s `gc`/`gcc` intentionally shadow Neovim 0.10+'s own native
`gc`/`gcc` — now documented (confirmed via the same real runtime source) rather than left
unexplained, since unlike the two moves above, this one is a deliberate keep: block comments
(`gbc`/`gb`) and treesitter-aware commentstring switching for embedded languages (JSX-in-.js,
`<script>`-in-.vue) are real capability gaps in the native version.

Added a reference box to `config/mappings.lua`, matching `lspconfig.lua`'s existing box style,
for the native defaults that don't belong to any single plugin file (quickfix/loclist/arglist/
tag-stack/buffer-list navigation) — including a noted, verified gap in the LSP box itself:
`<C-w><C-d>` (alternate chord for `<C-w>d`, floating diagnostic) was missing.

### 8. Dependency architecture: a `deps/` folder for genuinely shared, unconfigured plugins

`plugins/ui/web-devicons.lua` already had the right shape for this — `lazy = true`, no
`event`/`cmd`/`ft` of its own, existing purely to centralize `opts` while every one of its 8
consumers still lists `"nvim-tree/nvim-web-devicons"` in their own `dependencies` (that's what
actually triggers the load; lazy.nvim merges every spec referencing the same plugin name into
one resolved plugin). Confirmed this is load-bearing, not redundant, before touching anything —
removing those 8 references would have silently stopped devicons from ever loading at all.

Extended the same proven pattern to the two other genuinely multi-consumer, nothing-to-configure
dependencies that had no home: `nvim-lua/plenary.nvim` (5 consumers) and `MunifTanjim/nui.nvim`
(2 consumers), both previously just scattered inline `dependencies` entries. New file:
`plugins/deps/shared.lua`. `web-devicons.lua` relocated from `ui/` to `deps/` alongside it, for
one consistent home for "shared infrastructure with no independent trigger." `promise-async`
(nvim-ufo's dependency) deliberately left inline in `ufo.lua` — single-consumer, nothing to
centralize. `plugins/init.lua` gained `{ import = "plugins.deps" }`; `init.lua`'s file-layout
tree updated to match.

Verified with lazy.nvim's actual `Spec.new()` resolver (see "Testing this pass actually did"
below): 65/65 plugins resolve correctly after the move, matching `lazy-lock.json`'s 65 entries
exactly (the one apparent mismatch, `999rpm-themer` present in the resolved set but absent from
the lockfile, is expected — a local, repo-less spec with no git source to pin).

### 9. Fold column: `foldcolumn = "1"`, not `"auto:4"` — unlimited nesting depth, on purpose

Supersedes the `"auto:4"` fix in §3 of the entry below. Traced `statuscol.nvim`'s real
`builtin.foldfunc` source in full this time (not just the one `range = min(level, width)` line
quoted below): at width N>1, the renderer stacks one glyph per level and genuinely runs out of
columns past N — that's the actual cap. At width 1, the per-line check collapses to "does a
fold start on *this exact line*" (`foldinfo.start == args.lnum`), which doesn't depend on depth
at all — a fold starting 12 levels deep gets its `foldopen`/`foldclose` glyph exactly like one
at level 2. What a wide column adds instead — seeing every level you're currently inside, at a
glance — is already covered with no cap of its own by `snacks.indent`'s guides (one virtual-text
character per indent level, nothing capping how many draw). Fold is listed last/rightmost in
`statuscol.lua`'s segments, so at width 1 it sits flush against the first indent guide rather
than floating in its own strip — about as close to "same column" as the real rendering pipeline
allows without custom extmark code fighting two plugins for the same buffer position (checked
`snacks.nvim`'s indent module directly for a hook that would allow that kind of merge; none
exists).

Also removed `foldnestmax = 4`: verified dead code, confirmed against Neovim's own docs — it
only applies to `foldmethod=indent`/`syntax`, and this config uses `manual` (nvim-ufo's own
requirement). It never limited anything nvim-ufo did; the comment claiming otherwise was wrong.

### 10. Smaller fixes

- `mason.lua`: added `"gofumpt"` (`conform.lua`'s `go` formatter, referenced but never actually
  guaranteed installed anywhere) and `"tree-sitter-cli"` (§1). Removed `"selene"`/`"luacheck"`
  — both installed but wired into nothing in `lint.lua` (`linters_by_ft` has no `lua` entry) —
  dead weight, not active redundancy elimination of anything functioning.
- `lazy-lock.json`: removed the orphaned `"indent-blankline.nvim"` entry left over from the
  entry below's plugin-file deletion — the lockfile was never regenerated after.
- `flash.lua`: removed a dangling reference to a "review log" in `mappings.lua` that the entry
  below already deleted outright.
- `neotest.lua`: documented why `antoinemadec/FixCursorHold.nvim` is still a justified
  dependency rather than legacy cruft — checked, not assumed. Its original performance bug (small
  `CursorHold` delays thrashing the swap file) really was fixed in Neovim core years ago, but per
  the plugin author's own clarification, it still does a second, unrelated job core has no
  equivalent for: decoupling `CursorHold`'s delay from the single global `'updatetime'`.
- Checked `craftzdog/dotfiles-public`, `xero/dotfiles`, `rafi/vim-config` again for anything new
  to adopt in `lspconfig.lua` specifically. Nothing found that isn't already incorporated,
  already superseded by a more current mechanism (e.g. this config's native `virtual_lines`
  diagnostic option vs. xero's `lsp_lines.nvim`, which exists to backfill the same thing on
  older Neovim), or a genuine style alternative rather than an improvement (xero's
  `spellwarn.nvim`, `diagflow.nvim` — worth knowing about, not added unasked).

### Testing this pass actually did

- All 55 `.lua` files pass `luac5.1 -p` after every edit in this entry (checked twice — once
  mid-pass, once at the end).
- Downloaded a real Neovim **v0.12.4** binary and cloned real upstream source for every plugin
  named in §1–§9 above (nvim-treesitter, noice.nvim, bufferline.nvim, mason-registry,
  mason-lspconfig.nvim, statuscol.nvim, snacks.nvim) — every claim above was checked against
  that source directly, not recalled from memory.
- Ran lazy.nvim's actual `Spec.new()` — the real spec-resolution engine, not just `lsmod` (see
  the entry below for that narrower check) — against this config's real directory tree: 65/65
  plugins resolved, cross-verified byte-for-byte against `lazy-lock.json`'s 65 entries (§8).
- Did **not** attempt a full plugin install/bootstrap or a real headless-launch test — same
  scope boundary the entry below draws, for the same reason (materially bigger undertaking than
  this pass's actual changes warrant). Spec-shape and dependency-graph correctness is verified;
  runtime behavior of each plugin's own `config()`/`opts` function, once installed, is not.

### Check next time

- The `2026-08-06` entry's `foldcolumn = "1"` "check next time" item and this entry's own §9
  cover the *same setting* for *different reasons* — if width 1 ever needs to change again,
  read §9 above, not the 2026-08-06 entry, which reflects an outdated diagnosis.
- `snacks.indent`'s `chunk` box only draws once a scope is at least one `shiftwidth` deep (own
  source: `show_chunk = show_chunk and (scope.indent or 0) >= state.shiftwidth`) — no box at
  true top-level code is expected, not a bug.
- If `snacks.indent`'s animation feels too slow/fast, `animate.duration`/`animate.style` are the
  knobs — see `snacks.lua`.
- A suggested file-structure change (flattening vs. the current category-folder layout) was
  discussed but not applied — current structure is already sound; see the conversation this log
  entry was written from for the actual reasoning, since it's advice rather than a change.

## 2026-08-12 — reference-config comparison, Haskell support, indent guides, fold-arrow nesting, dimmed backdrop

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

Fixed at the time by widening `foldcolumn` to `"auto:4"` — a real Neovim option value (`:help
'foldcolumn'`), sized dynamically up to 4 to match `foldnestmax` (also 4, already set), costing
no extra column width on lines/buffers with no real nesting. **Superseded by the entry above's
§9: `"auto:4"` still caps visible nesting at 4, just at a higher ceiling — narrowed further to
`foldcolumn = "1"` once the actual statuscol.nvim rendering logic was traced in full, which
removes the cap entirely rather than just raising it. `foldnestmax` (mentioned above as the
number this matched) also turned out to be dead code — see the entry above's §9.**

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
- ~~float-backdrop zindex~~ — moot, `plugins/ui/float-backdrop.lua` was deleted in the entry
  above (§4); left struck through rather than silently removed, since the reasoning it links to
  no longer has a file to point at.
- ~~bufferline.lua's "slant"~~ — the value in use is `"slope"`, not `"slant"` (see the entry
  above's §5 for the terminal-rendering fallback, now `"padded_slope"`).
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
