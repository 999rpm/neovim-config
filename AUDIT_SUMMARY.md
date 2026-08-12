# Config log

Single running log for this config. File headers describe *what a file currently does and why*;
this file is the *history* — what changed, when, why, and what to check next time. Read this
before making a change (per-file headers won't repeat reasoning that lives here), and add an
entry here (not back into a file header) after making one.

Newest entry first.

## 2026-08-13 — README.md tone and credits

Trigger: the README read as more "forcefully jolly" than intended, and the "Credit where it's
due" section was asked to be removed outright.

Rewrote every prose line in `README.md` (requirements, install, license) in flatter, more
neutral language — cut the asides and chattier phrasing (e.g. "not an error, just nothing to
look at", "if you're curious why", "that's the whole point of putting it up publicly") without
losing any of the actual information underneath. The `## Layout` tree was left untouched — it
was already plain technical reference, nothing jolly to flatten there.

Removed the "Credit where it's due" section entirely, scoped to `README.md` only — the more
detailed, per-pattern attributions in `init.lua`'s header and in individual file headers
(`lspconfig.lua`, `utils.lua`, `autocmds.lua`'s MenuPopup block, `mason.lua`) serve a different,
technical-maintenance purpose (which specific setting or pattern came from where, for future
audits) and weren't touched — the request was read as being about the README's public-facing
acknowledgments section specifically, not every credit line in the codebase.

No code changed; nothing to test beyond confirming the file is still valid Markdown.

---

## 2026-08-13 — icon corruption across 10 files, kitty.conf cross-check, reference-config re-comparison, DAP tutorial, snacks/rainbow integration, Mason-binary warnings

Trigger: a full re-audit against the folder-per-category layout plus an uploaded kitty.conf,
covering (1) plugin/config compatibility and redundancy, (2) a fresh check against jdhao/
nvim-config, craftzdog/dotfiles-public, xero/dotfiles, rafi/vim-config with special focus on
lspconfig.lua, (3) K's hover border, `<C-w>}` inside/around a terminal, whether `<leader>xf` is
still worth keeping next to native `<C-w>d`, (4) Copilot never suggesting anything, (5) no DAP
breakpoint symbols plus `<leader>Dc` appearing to do nothing, (6) flash.nvim's `<C-/>` behaving
like a plain search, (7) a beginner-facing DAP tutorial, (8) utils.lua EOL-comment coverage,
(9) "999rpm" branding, (10) reducing inter-plugin dependencies, (11) a file-structure opinion,
(12) kitty.conf conflicts, (13) a follow-up debugpy ENOENT report, (14) bufferline separator
color, (15) snacks.indent/rainbow-delimiters integration.

**Everything below was checked against real, current upstream source** — cloned fresh:
noice.nvim, flash.nvim, copilot.lua, blink.cmp, nvim-dap-ui, trouble.nvim, nvim-notify,
todo-comments.nvim, neo-tree.nvim, render-markdown.nvim, bufferline.nvim, snacks.nvim,
lazy.nvim, mason.nvim, mason-registry, mason-nvim-dap.nvim, nvim-dap-python — plus Neovim's own
bundled `$VIMRUNTIME` (a real, downloaded v0.12.4 source tree) for the terminal-mode keymap
claim below, and all four reference configs re-cloned rather than diffed from memory.

### 1. Icon corruption: ~65 empty glyph fields across 10 files — the actual DAP bug, and nine more nobody had reported yet

Checked every string literal in the config at the byte level (`.encode("utf-8")`, not how it
renders in any viewer) after `dap.lua`'s breakpoint signs turned out to be genuinely 0-byte
strings, not just hard to see. Validated the method against `lualine.lua`'s separators first as
a control — those came back genuinely non-empty (real U+E0BB/E0BC bytes), matching the
2026-08-12 entry's own finding — before trusting it on anything else. The same sweep, run
across every file, found the identical pattern in nine more places, none previously reported:
`dap-ui.lua` (12 fields), `neo-tree.lua` (11), `notify.lua` (5), `todo-comments.lua` (6),
`bufferline.lua` (2), `plugins/deps` — no, `config/lazy.lua` (3, see below), `lualine.lua` (3),
`trouble.lua` (8, 4 real + 4 dead-config, see below), `render-markdown.lua` (10). Root
mechanism not conclusively identified (both BMP and astral-plane PUA codepoints appear on both
the "survived" and "empty" sides, so it isn't a clean Unicode-plane rule) — reported as a
confirmed, byte-verified fact rather than a guessed cause.

Every replacement value was pulled from the *consuming plugin's own current default config*,
not invented: `dap-ui.lua` from `nvim-dap-ui`'s `lua/dapui/config/init.lua`, `neo-tree.lua`
from `lua/neo-tree/defaults.lua`, `notify.lua` from `lua/notify/config/init.lua`,
`todo-comments.lua` from `lua/todo-comments/config.lua`, `render-markdown.lua` from
`lua/render-markdown/settings.lua`. `dap.lua`'s signs have no upstream default to copy
(`nvim-dap` ships none at all — confirmed, `sign_define` is entirely the user's job), so those
five are this pass's own choice, each now with its own `texthl` linked to a `Diagnostic*` group
(see §5). `bufferline.lua`'s error/warning and `lualine.lua`'s git-diff icons were pointed at
codepoints already used elsewhere in this config for the same concept (lspconfig.lua's
diagnostic signs; neo-tree's git-status symbols) rather than a fourth independent guess.

Two were **not** icon bugs and are documented, not "fixed": `ufo.lua`'s `ft_providers` table
uses empty string `""` as nvim-ufo's own real API for "don't fold this buffer at all" (per
`provider_selector`'s own doc/example.lua pattern) — confirmed correct, untouched.
`todo-comments.lua`'s `highlight.before = ""` is one of that option's own valid enum values
(`"fg"|"bg"|""`) — also untouched.

### 2. `trouble.lua`: two settings that don't exist in the current plugin, removed rather than "fixed"

`use_diagnostic_signs = true` doesn't appear anywhere in trouble.nvim's current source (grepped
the whole plugin, zero matches) — dead config from an older version. Traced how Trouble
actually colors diagnostic severities instead of guessing: `lua/trouble/format.lua`'s
`severity_icon` formatter reads `vim.diagnostic.config().signs.text[severity]` directly — i.e.
lspconfig.lua's diagnostic signs, already correct — with no dependency on `use_diagnostic_signs`
or on `icons.kinds.Error/Warn/Hint/Info` (also not a real field on the current `kinds` table,
which only holds LSP `SymbolKind` names like `Function`/`Class`/`Variable` for the *symbols*
view, unrelated to diagnostics). Both removed. `icons.indent.fold_open/fold_closed` and
`icons.folder_closed/folder_open` **are** real, currently-read options and were genuinely
empty — fixed with trouble.nvim's own current defaults.

### 3. K's hover window has no border — root cause fully traced, not just patched

`noice.lua`'s `lsp.hover.enabled = true` makes Noice register its own `textDocument/hover`
handler (confirmed: `lua/noice/lsp/init.lua` calls `vim.lsp.buf_request(0, "textDocument/hover",
params, require("noice.lsp.hover").on_hover)`), so it's Noice's own "hover" view that actually
renders on `K` — the `border = border_style` passed to `vim.lsp.buf.hover()` in lspconfig.lua's
own keymap never reaches what's drawn on screen, because Noice has already taken over that
code path. That view's real default (`lua/noice/config/views.lua`) is `border = { style =
"none" }` — no border at all, and NOT inherited from options.lua's global `winborder =
"rounded"` either, since Noice sets `style` explicitly rather than leaving it unset for the
global default to fill in. `presets.lsp_doc_border` (`lua/noice/config/preset.lua`) is
upstream's own mechanism for exactly this: it sets `views.hover.border.style = "rounded"` plus
a better on-screen position. Flipped from `false` to `true`; the previous comment ("Blink/LSP
handles borders") was the actual bug — blink.cmp only borders its own completion-doc popup, a
different window, and has no involvement in LSP hover once Noice has intercepted it.

### 4. `<C-w>}` and `<leader>xf` — both are working as intended, documented rather than changed

`<C-w>}` is Neovim's own native "show tag (LSP definition, via `'tagfunc'`) in a preview
window" command. Ruled out both suspected sources directly: grepped Neovim's real
`$VIMRUNTIME/lua/vim/_core/defaults.lua` for every `vim.keymap.set` call — no terminal-mode
(`'t'`) entry exists at all, so this isn't a Neovim terminal default; and kitty.conf's own
header confirms `ctrl+w` was deliberately left unbound (its 2026-08-12 revision already removed
a conflicting `close_tab` binding). Leading explanation for "closes the terminal": opening the
preview window is a real new split, and options.lua's `winminheight = 1` lets an already-open,
non-active terminal split shrink to a single line to make room for it — visually gone, not
actually closed. Documented directly in lspconfig.lua's keymap box rather than remapped, since
the underlying behavior is correct, documented Neovim functionality, not a bug.
`<leader>xf` — confirmed via the code's own existing comment as a deliberate "ergonomic alias"
for `<C-w>d`, kept for consistency with the `<leader>xw`/`<leader>xb` group rather than
oversight; not required, left as-is, now noted explicitly in this log rather than only inline.

### 5. DAP: signs were invisible (§1) *and* uncoloured — both fixed together, plus a Mason-install warning for the actual reported ENOENT

The empty signs (§1) explain the original report ("no symbols for breakpoints") on their own,
but even fixed, none of `DapBreakpoint`/`DapBreakpointCondition`/`DapLogPoint`/`DapStopped`/
`DapBreakpointRejected` had a highlight definition anywhere in this config — confirmed via a
full-tree grep before assuming — so all five would have rendered in whatever plain foreground
happened to be nearby, defeating the point of five distinct signs. Added a
`set_dap_highlights()` function linking each to a `Diagnostic*` group (theme-reactive, not
hardcoded hex) plus a dedicated `ColorScheme` autocmd to re-apply them — needed because, unlike
`RainbowDelimiter*` groups (which colorscheme plugins redefine themselves on every
`:colorscheme` call, confirmed via rainbow-delimiters.lua's own existing note), these are
config-invented group names no colorscheme knows to redefine, so themes.lua's `highlight
clear` would otherwise wipe them on every theme switch with nothing to restore them.

**Follow-up, same day: a real Mason-install failure, not a config bug.** Reported error:
`Executable '/home/999rpm/.local/share/nvim/mason/packages/debugpy/venv/bin/python' not found
... ENOENT`. Re-verified the path construction in `dap-python.lua` against mason.nvim's actual
installer source (not just Mason's registry metadata, which the previous pass already checked):
`lua/mason-core/installer/managers/pypi.lua`'s own `venv_path()` computes exactly
`<package_dir>/venv/bin` (Unix) / `venv/Scripts` (Windows) — byte-for-byte what this file
already builds. The path is correct; the file genuinely isn't there yet, meaning Mason hasn't
finished installing debugpy (most common cause: no system `python3`/`python` for Mason's
`create_venv()` to build the venv from at all — confirmed that function's own fallback order in
source) or the install failed outright. Also re-verified `codelldb`, `js-debug-adapter`, and
`haskell-debug-adapter`'s paths in `dap.lua` the same way, against their real
`mason-registry` `package.yaml` entries — all correct, same risk applies to all four.

Added `utils.warn_if_missing_mason_bin(path, label)`: checks `vim.uv.fs_stat` at plugin-load
time (not mid-debug-session) and, if the binary isn't there, notifies once with what to check
(`:Mason`, `:MasonLog`, `:MasonInstall <name>`) instead of leaving the first sign of trouble to
be a raw ENOENT the moment a debug session is attempted. Wired into all four Mason-managed DAP
binaries (`dap-python.lua`'s debugpy, `dap.lua`'s codelldb/js-debug-adapter/haskell-debug-
adapter) — same "check once at startup, one clear message" shape as `utils.executable()`'s own
existing callers (`nu`/`rg` in options.lua, `tree-sitter-cli` in treesitter.lua), extended to
cover an absolute Mason path rather than a `$PATH` lookup, which `executable()` alone can't do.

Also added: a boxed tutorial at the top of `dap.lua` (the actual six-step workflow — set
breakpoint, Continue, dap-ui opens automatically, step controls, Terminate, and what to check
if step 1 shows no sign or step 2 errors) and a shorter inline one in `flash.lua`, per an
explicit request for beginner-facing walkthroughs on the less-obvious plugins.

### 6. Copilot: config confirmed not at fault; real requirement found and now checked for

Traced `filetypes = { markdown = true, help = true }` against copilot.lua's actual
`is_ft_disabled()` (`lua/copilot/client/filetypes.lua`) rather than assumed: it checks the
user's `filetypes` table, then an *internal* disabled-by-default list (yaml/markdown/help/
gitcommit/gitrebase/hgcommit/svn/cvs), and falls through to enabled for anything neither
mentions — so lua/python/js/etc. were already on; this config's own table only opts markdown/
help back in from the internal defaults. Real finding: copilot.lua's own README states **Node.js
v22+** specifically (not "any Node") — an older LTS (18/20, both still common default installs)
fails silently, no error, just no suggestions ever. Added a version-aware check at plugin-load
time (parses `node --version`, warns if under 22 or missing entirely) and left a commented
`server = { type = "binary" }` note — upstream's own alternative that sidesteps the Node
requirement by downloading a standalone binary instead, not switched to by default since it's a
real trade-off (a second binary to keep updated), not a strict improvement.

### 7. flash.nvim's `<C-/>`: matched to upstream's own tested default

flash.nvim's README documents `<c-s>` — never `<c-/>` — for exactly this "toggle flash labels
inside an active `/` search" feature; the toggle mechanism itself (`flash.plugins.search.toggle`,
a live runtime flip, confirmed in source) isn't the issue either way. Changed to `<C-s>` in
cmdline mode, which doesn't collide with this config's other `<C-s>` uses (mappings.lua's
normal-mode save, lspconfig.lua's insert-mode signature help) since keymaps are mode-scoped.
Leading explanation for the original symptom: `<C-/>` and `<C-_>` are frequently
indistinguishable at the raw keycode level depending on terminal/OS keyboard layer, which is
very likely why upstream picked `<c-s>` in the first place rather than an oversight on their
end. Also documented directly in the file: this key only does anything from an active `/`/`?`
search (cmdline mode) — pressed from Normal mode it's a no-op by design, use `f`/`F` there.

### 8. `lua/plugins/init.lua` missing again — same failure mode, same fix, now with a permanent note in the file itself

Absent again, for the exact reason the 2026-08-12 entry already diagnosed: the root `init.lua`
and this file share a literal filename, and whatever prepares project files for a chat session
keeps only one. Reconstructed identically (`{ import = "plugins.lsp" }` etc. for all 13
category folders — one more than the 2026-08-12 count, `deps`, added that same day for
plugins/deps/shared.lua+web-devicons.lua). Verified by counting: 55 `.lua` files total minus 7
non-plugin-spec files (root init.lua, utils.lua, 4× config/*.lua, this file) = 48, matching the
actual count of files under the 13 category folders exactly. Given this has now happened three
times, added a permanent note inside the file itself explaining why, so a future pass (or a
future session missing this same file) doesn't have to re-derive the diagnosis from scratch.

### 9. Reference-config re-comparison: nothing new to adopt, confirmed rather than assumed

Re-cloned all four fresh (not diffed against a remembered state) with focus on lspconfig.lua
per the request. jdhao/nvim-config's `lua/lsp_conf.lua`: same shape throughout (gd de-dup,
`<C-]>`, hover/signature help, workspace folder commands, LspProgress echo) — this config is
already ahead in several places jdhao's isn't (schemastore, document-highlight-on-CursorHold,
diagnostics-to-quickfix, basedpyright+ruff split). craftzdog/dotfiles-public's `lsp.lua`:
confirmed its `ts_ls`/`tailwindcss` `root_pattern(".git")` + `single_file_support = false`
override is the exact pattern the 2026-08-12 entry already identified and removed from this
config as a regression — craftzdog's is, if anything, a step behind this config on that specific
point, not ahead. xero/dotfiles' `lsp/init.lua`: still lists `spellwarn.nvim`/`diagflow.nvim`/
`lsp_lines.nvim` as dependencies — the same three items the 2026-08-12 entry already considered
and declined (native `virtual_lines` supersedes `lsp_lines` on current Neovim; the other two are
style alternatives, not improvements). rafi/vim-config's `lsp.lua` is a LazyVim-extension diff,
not a standalone config — its incoming/outgoing-calls keys already have an equivalent here
(telescope.lua's `<leader>sc`/`<leader>sC`). Net result: nothing new found for lspconfig.lua
specifically, for the second pass running — re-confirmed rather than re-asserted from memory.

### 10. Smaller fixes and confirmations

- `config/lazy.lua`: removed `icons.git` (added/modified/removed) — confirmed via a full grep
  of lazy.nvim's real `lua/lazy/view/render.lua` (the only place `Config.options.ui.icons.*`
  gets read at all) that `icons.git` is never consumed anywhere in the current plugin, unlike
  every other icon in that table, which is. Dead config from an older lazy.nvim version, not a
  currently-broken feature — removed rather than "fixed" with icons that would do nothing.
- `plugins/ui/bufferline.lua`: added explicit `highlights.separator_selected`/`separator`/
  `separator_visible` (linked, not hardcoded hex, so they track the active theme) for a visibly
  colored tab divider — previously left at bufferline's own default, a subtle same-as-background
  tint. Verified via `lua/bufferline/config.lua`'s real `update_highlights()` that a `link`
  passed once in `setup()`'s opts survives every subsequent theme switch, not just the first
  call. Also corrected a stale claim in this file's own header (and in themes.lua's
  `ThemeChanged` note) that this config's custom `ThemeChanged` event drives bufferline's
  highlight refresh — traced `lua/bufferline.lua`'s `setup_autocommands` directly and found
  bufferline registers its own native `ColorScheme` listener internally; the custom event was
  never involved for this plugin specifically.
- `plugins/ui/snacks.lua` + `utils.lua`: `snacks.indent`'s per-level guide color
  (`indent.indent.hl`) now points directly at `utils.rainbow_delimiter_groups` — the same 7
  `RainbowDelimiter*` group names rainbow-delimiters.lua uses for brackets — confirmed via
  `lua/snacks/indent.lua` that `indent.hl` accepts a list (its own commented-out
  `SnacksIndent1..8` example shows the shape) and cycles it with `(level - 1) % #hl + 1`, so no
  new numbered groups needed defining. This is not a repeat of the rainbow-indent approach
  rejected earlier in this log: that complaint was two *different*, independently-cycling
  rainbow systems visually competing (ibl's own vs. rainbow-delimiters'); this shares one color
  source for both brackets and indent levels, so level 3 means the same color in both places.
  `chunk`/`scope` (the current-scope highlight) deliberately stay single-color, so the "this is
  where you are" indicator still stands out against the now-rainbow backdrop around it.
- "999rpm" branding: audited every existing use (every custom augroup via `utils.augroup()`,
  `themes.lua`'s `name = "999rpm-themer"` plugin spec) and found it already comprehensive:
  augroups are the one place a config-wide namespace genuinely belongs (`:autocmd`/`:augroup`
  output), and forcing it into e.g. the dashboard or window title would be decoration for its
  own sake rather than function. No changes made here on purpose, not an oversight.
- `which-key.lua`: audited every `<leader>*` mapping actually defined anywhere in the tree
  (grepped, not eyeballed) against the group `spec` table — every prefix with 2+ children
  already has an accurate entry, none stale. One rename: `<leader>n`'s group label now says
  "No-yank / Paths / Registers" instead of just "Registers", since `<leader>ny`/`<leader>nY`
  (yank a relative/absolute path to the clipboard) aren't really a register operation in the
  sense the rest of that group's keys (`nc`/`nd`/`np`/etc.) are.
- Dependency architecture (item 10 of the original request, "reduce plugin dependencies, keep
  them independent"): re-checked the existing `plugins/deps/` split (§8 of the 2026-08-12
  entry below) against this pass's full re-read of every file — still the right shape, nothing
  found that's newly coupled and should be split out, nothing in `deps/` that's grown a second
  consumer-specific concern that should move back out. No changes.
- File structure (item 11, "suggest better structure"): re-confirmed the category-folder layout
  is already sound, consistent with the 2026-08-12 entry's own conclusion after the same
  question — nothing changed this pass either, not re-litigated without new evidence.

### Testing this pass actually did

- All 55 `.lua` files pass `luac5.1 -p` after every edit in this entry (checked file-by-file as
  each was written, plus one final full-tree sweep at the end).
- Downloaded a real Neovim source tree (v0.12.4) and grepped its actual
  `runtime/lua/vim/_core/defaults.lua` for the terminal-mode `<C-w>` claim in §4 — checked
  directly, not recalled.
- Cloned and read real, current upstream source for every plugin named in §1–§9 above
  (noice.nvim, flash.nvim, copilot.lua, blink.cmp, nvim-dap-ui, trouble.nvim, nvim-notify,
  todo-comments.nvim, neo-tree.nvim, render-markdown.nvim, bufferline.nvim, snacks.nvim,
  lazy.nvim, mason.nvim, mason-registry, mason-nvim-dap.nvim, nvim-dap-python) plus all four
  reference configs, re-cloned fresh rather than diffed from memory.
- Verified icon replacements at the byte level after writing them (UTF-8 encode + hex-dump each
  one), using explicit codepoint construction (Python's `chr()`) rather than typing glyphs
  directly into any tool call — the 2026-08-12 entry's own "process note" on this exact risk
  (a directly-typed glyph can silently produce an empty string) was followed, not repeated.
- Did **not** attempt a full plugin install/bootstrap or a real headless-launch test — same
  scope boundary every prior entry in this log draws, for the same reason. In particular, the
  debugpy ENOENT in §5 could not be reproduced or confirmed-fixed end-to-end from here — no
  access to the machine it was reported on — only the code path and the warning that now
  surfaces earlier are verified; whether Mason itself completes the install is outside this
  pass's reach and needs `:Mason`/`:MasonLog` checked directly on that machine.

### Check next time

- If `<leader>Dc` still appears to "do nothing" after this pass, confirm the breakpoint sign is
  actually visible first (`:sign list`, look for a non-empty `text=` on `DapBreakpoint`) before
  suspecting the DAP wiring itself — see the tutorial box in `dap.lua` for the full checklist.
- If any other Mason-managed DAP binary throws ENOENT, `utils.warn_if_missing_mason_bin()`
  should now have already warned about it at startup — check `:messages` for that warning
  first, then `:Mason`/`:MasonLog`, before re-checking the path construction in the Lua itself.
- The exact mechanism behind §1's icon corruption (which specific codepoints/ranges survive vs.
  don't) was not conclusively identified — if it recurs after this pass in a *new* file, that's
  worth investigating properly rather than just re-running the same byte-check-and-replace fix.
- `bufferline.lua`'s colored separators use `link = "Function"`/`link = "Comment"` — a
  reasonable, universally-available default, not a strong aesthetic opinion; swap either link
  target if it doesn't suit a given theme once seen live.

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
