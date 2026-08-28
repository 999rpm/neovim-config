# Config log

Single running log for this config. File headers describe _what a file currently does and why_;
this file is the _history_ — what changed, when, why, and what to check next time. Read this
before making a change (per-file headers won't repeat reasoning that lives here), and add an
entry here (not back into a file header) after making one.

Newest entry first. Entries get condensed over time (their conclusions stay, the blow-by-blow
of how each was reached doesn't) so this file stays worth reading rather than worth skipping.

## 2026-08-28 — every previously-open candidate resolved (11 added, 3 declined with reasons),

## mini.icons replaces nvim-web-devicons outright, rustaceanvim added (one real dap.lua aliasing

## bug caught before it could bite), delivered as a real nested tree for the first time (zip, not

## project-knowledge sync)

Trigger: the standard re-audit request against the same 15 repos as the entry below (one day
later — re-cloned fresh, not assumed unchanged), plus an explicit, unambiguous instruction to
implement the standing candidate backlog rather than continue listing it. Every open candidate
this log has ever recorded (§6/§7/§5/§4 of the entries below, going back to 2026-08-18) got a
real decision this pass — implemented, or declined with a specific reason — rather than carried
forward again.

### 1. Nine candidates added, each checked against its own current source first

`plugins/editor/guess-indent.lua`, `plugins/git/git-conflict.lua`, `plugins/ui/window-picker.lua`
+ `plugins/ui/stickybuf.lua`, `plugins/editor/neogen.lua`, `plugins/ui/satellite.lua`,
`plugins/ui/nvim-bqf.lua`, `plugins/treesitter/hlargs.lua`, `plugins/ui/modicator.lua`,
`plugins/ui/colorful-winsep.lua` — fresh clones of all eleven, not configured from memory.
Concrete things the clones actually changed versus a from-memory config:

- **`stickybuf.nvim`**: upstream's own built-in filetype list (read `lua/stickybuf.lua`'s
  `builtin_supported_filetypes` directly) already covers quickfix/help/neotest/toggleterm/
  nvim-notify/neo-tree/nvim-dap-ui/grug-far by name — all already installed here, so those
  needed nothing. It does not cover `oil`/`Trouble`/`lazy`/`mason`; `get_auto_pin` layers those
  four on top of (not instead of) `require("stickybuf").should_auto_pin()`, per the README's own
  documented extension pattern, so upstream's internal special cases (`TelescopePrompt`
  deliberately unpinned, DAP prompt buffers pinned by `bufnr` not `filetype`) don't need
  reimplementing here.
- **`nvim-window-picker`**: `setup()`'s merge is a genuine `vim.tbl_deep_extend` (read
  `lua/window-picker/init.lua` directly), but that function matches list-like tables by numeric
  index, not by appending — passing only "the additions" to `filter_rules.bo.filetype` would
  have silently overwritten upstream's own four default entries at the matching indices instead
  of adding to them. Written out in full (upstream's four plus this config's other utility
  filetypes) instead.
- **`hlargs.nvim`**: deliberately left at its own flat default color rather than `link`-ed to an
  existing theme group, unlike almost everything else this config themes — the point of the
  plugin is to look different from whatever the theme already does for a parameter; linking to a
  theme group risks landing on that exact color. Its own default is already `{ fg = color,
  default = true }` (read `lua/hlargs/config.lua`), so a theme that does define its own `Hlargs`
  group would still win.
- **`neogen`**: initial draft used `snippet_engine = "luasnip"` — wrong, caught before shipping,
  not after. This config has no LuaSnip installed at all (blink.cmp's own snippet source
  handles that role). Read `lua/neogen/snippet.lua` directly for the real supported list
  (`luasnip`/`snippy`/`vsnip`/`nvim`/`mini`) and switched to `"nvim"` — Neovim 0.10+'s own
  built-in `vim.snippet`, already satisfied by this config's 0.12+ requirement, needing nothing
  extra installed at all.
- **`git-conflict.nvim`**: `default_mappings = true` kept at upstream's default rather than
  remapped — read `lua/git-conflict.lua` directly for the real key table (`co`/`ct`/`cb`/`c0`/
  `]x`/`[x`, not assumed from memory) and confirmed none of the four bare letters are bound
  anywhere else in this config, and that they only activate inside a buffer with an actual
  detected conflict (wired through the plugin's own `GitConflictDetected` autocommand) — outside
  that context `c0` is untouched, still native "change to column 0".

### 2. `mini.icons` replaces `nvim-web-devicons` — a previously-open candidate, verified live

Read `lua/mini/icons.lua` directly rather than trusting the README summary: `MiniIcons.
mock_nvim_web_devicons()` registers a real shim into `package.preload`/`package.loaded` under
the literal name `"nvim-web-devicons"`, which is exactly what makes this a swap rather than a
second icon system running alongside the first. `plugins/editor/mini.lua` moved from `event =
"VeryLazy"` to `lazy = false, priority = 1000` (matching `plugins/ui/snacks.lua`'s own reasoning)
so the mock registers before the earliest possible consumer — `plugins/ui/alpha.lua`'s dashboard
on `VimEnter` — could ever call `require("nvim-web-devicons")` for real.

All eleven consuming files (`alpha`, `avante`, `bufferline`, `fzf`, `lualine`, `neo-tree`,
`octo`, `oil`, `render-markdown`, `telescope`, `trouble` — a fresh grep, not the nine this log's
own `plugins/deps/shared.lua`-style count from memory would have suggested) had their
`"nvim-tree/nvim-web-devicons"` dependency string repointed at `"echasnovski/mini.nvim"`;
`plugins/deps/web-devicons.lua` removed outright rather than left installed-but-unused, since a
dangling real install would cost a clone and an install step for a plugin nothing loads anymore.

**Live-tested, not just read**: staged a fresh clone of `mini.nvim` in a real Neovim v0.12.5
session, ran this config's own exact `mini.lua` config function (`mini.icons` setup + mock, then
`mini.ai` setup), then called `require("nvim-web-devicons").get_icon("test.lua", "lua", {default
= true})` cold — no real `nvim-web-devicons` on the runtimepath at all. Returned a real icon and
a real `MiniIconsAzure` highlight group. The swap works, not just resolves.

### 3. `rustaceanvim` — a previously-open candidate, and a real bug it exposed before shipping

Upstream's own README carries an explicit warning against also configuring `rust_analyzer`
through `nvim-lspconfig`/`vim.lsp.enable()` — confirmed by reading it, not assumed from general
Rust-tooling knowledge. `rust_analyzer` removed from `plugins/lsp/lspconfig.lua`'s own `servers`
table accordingly; stays in `plugins/lsp/mason.lua`'s `ensure_installed` regardless, since
Mason's job there is only keeping the binary installed, not starting a client. `enable_clippy`
(this plugin's own equivalent of the `check.command = "clippy"` override lspconfig.lua carried)
defaults to `true` already — confirmed against `lua/rustaceanvim/config/internal.lua` — restated
explicitly rather than left implicit, matching how `dap-ui.lua`/`neo-tree.lua` already restate
their own current upstream defaults.

**A real bug, caught by reading the actual append mechanism rather than assuming append-only
semantics**: `lua/rustaceanvim/commands/debuggables.lua` discovers Rust runnables via
`dap.configurations.rust = dap.configurations.rust or {}` then `table.insert(...)` — genuinely
appends, doesn't replace. `plugins/debug/dap.lua`'s own `dap.configurations.rust =
dap.configurations.cpp` assigns the *same table by reference*, not a copy — every Rust runnable
this plugin would ever discover was about to also silently land in `dap.configurations.cpp`/`.c`,
showing Rust test binaries in a C/C++ debug picker. Fixed with `dap.configurations.rust =
vim.deepcopy(dap.configurations.cpp)` before rustaceanvim was wired in at all, not after
something surfaced it in practice.

Keymaps (`K` → `RustLsp hover actions`, `<leader>Tc` → `RustLsp runnables`) live in
`rustaceanvim.lua`'s own `keys` table with `ft = "rust"`, not in `lspconfig.lua`'s shared
`LspAttach` block — lazy.nvim's own per-key `ft` field gives the same buffer-scoping upstream's
suggested `after/ftplugin/rust.lua` location would, without a second file or touching a block
every other language's config also depends on. Native `gra` (code action) deliberately left
alone rather than replaced with `RustLsp codeAction`: the only real gain is grouping related
actions, `gra` already calls the same underlying request, and upstream's own suggested key for
this is `<leader>a` — already `textobjects.lua`'s parameter swap here, so it was never a
candidate to copy verbatim anyway. Rust debuggables need no new keymap: `autoload_configurations`
(upstream default, left on) appends straight into `dap.configurations.rust`, already reachable
through `plugins/debug/dap.lua`'s existing `<leader>Dp` picker once the aliasing fix above made
that table safe to append to.

### 4. `snacks.nvim`'s `image` module — a previously-open uncertainty, settled by reading source

The entry below left this off specifically because its current default-enabled state "wasn't
independently confirmed with the same confidence" as everything else added that pass. Read
`lua/snacks/image/image.lua` directly this time: `enabled = true` is genuinely the current
default, for the module itself and its `doc`/`math` sub-tables — meaning it was already active,
just never acknowledged. `image = {}` added to `plugins/ui/snacks.lua` to make that explicit
rather than leave it an implicit, unstated behavior; no functional change, a documentation one.

### 5. Two small keymaps — a previously-open candidate, four independent sources

`n`/`N` → `nzzzv`/`Nzzzv` (center screen + open a fold after a search jump) and `J` → `mzJ`z`
(join without the cursor jumping to the new joint) — verified present, independently, in
linkarzu/dotfiles-latest, Matt-FTW/dotfiles, and xero/dotfiles (the entry below found all three
sources and still declined to add these, on the standing principle that a verification pass
doesn't extend someone's muscle memory unasked; today's instruction is that ask). Added to
`config/mappings.lua`'s existing Search/Editing sections — no leader prefix involved, so no
`which-key.lua` change needed.

### 6. Three items checked again and deliberately still not added

- **`folke/sidekick.nvim`**: checked its current README specifically for what "adding" it would
  actually require, not just its feature list. Its Next Edit Suggestions need the official
  `copilot-language-server` registered as its own native `vim.lsp.enable()` client — a second,
  separate connection to Copilot's backend alongside `plugins/completion/copilot.lua`'s own
  bundled agent, not a drop-in alongside it. A real architectural fork of the AI stack, not a
  granular add — left open, now with the specific reason rather than a general one.
- **`eyeliner.nvim`**: `plugins/editor/flash.lua` already replaces native `f`/`F` outright with
  its own labelled-jump system (`modes.char.enabled = false`), which is strictly more capable
  than eyeliner's job (highlighting where a single native `f`/`F` press would land) for the two
  keys eyeliner would matter most on. Real remaining value is narrow — unenhanced `t`/`T` only —
  not enough to justify a new plugin for it.
- **`hydra.nvim`**: no current binding in this config presents the repeated-modal-operation case
  this plugin solves. `plugins/editor/multicursor.lua`'s own `addKeymapLayer` already covers the
  one structurally similar case (keys that only mean something once a mode is already active).
- Re-examined and left exactly as-is: the `ty`/`pyrefly` external Python type checkers
  (`lspconfig.lua`, still commented out) — the reason they're off is a real technical conflict
  (duplicate diagnostics alongside basedpyright), not an unmade permission call, so being told to
  clear the backlog of permission calls doesn't apply to this one.

### 7. Delivered as a real nested tree this time, not a flat list needing reconstruction

`init.lua`/lua/config/`*.lua`/`lua/plugins/<15 categories>/`*.lua`, packaged directly — the
recurring flattening this log has diagnosed on nearly every prior delivery is a property of the
project-knowledge chat sync specifically; it doesn't apply to a zip. `init.lua`'s own file-layout
tree and feature-overview updated to include every file this pass added, plus one already-stale
gap independent of this pass: `hardtime.nvim` (added several entries back) was never folded into
either list. `README.md`'s own layout tree and requirements section (added: `cargo`/`clippy` for
rustaceanvim, a graphics-protocol-capable terminal note for §4 above) updated to match.

### Testing this pass actually did

- **Downloaded a real Neovim v0.12.5 binary** and a real `lazy.nvim`; real (not simulated) spec
  resolution via `Config.setup()` + `Plugin.load()` against the reconstructed tree: **95 plugins
  resolved, zero notifications/errors.**
- **A real, targeted load test, not just a spec-shape check**: staged fresh clones of all eleven
  new plugins plus `mini.nvim`/`snacks.nvim` (whose own config this pass changed) at their real
  install paths and called each one's actual `setup()` — from this config's own real option
  values, not a bare smoke call — against real Neovim: **13/13 pass**. Includes the mock-devicons
  functional check in §2.
- `luac5.1 -p` across all 84 `.lua` files — 0 syntax errors.
- Independent keymap-collision and augroup-uniqueness scan, rebuilt fresh rather than reused: 36
  augroups, 36 unique names, 0 duplicates. Two apparent collision flags investigated, both false:
  bare `q` is the same already-settled buffer-local-wins case this log has confirmed several
  times; a batch of files flagging on literal `"n"` turned out to be the scan script's own nested-
  table blind spot (`mode = {"n", "x"}` inside a `keys` entry, not an actual `lhs = "n"` binding)
  — confirmed against every flagged file directly, the exact class of false positive this log's
  own 2026-08-20 entry hit once before for a different reason (Telescope's picker-scoped `map`).
- `servers`/`ensure_installed` cross-check re-run: 17/18 (the intentional gap is `rust_analyzer`,
  now rustaceanvim's job, not lspconfig.lua's — see §3). `conform`/`mason-tool-installer`
  untouched this pass, not re-verified beyond confirming neither file was edited.
- Fresh clones of all 15 named repos (re-confirmed the 9 from the entry below one day later;
  nothing materially new turned up in that single day beyond what's already reflected here).
- Every new keymap this pass introduced (`<leader>ew`, `<leader>cn`, `<leader>Tc`, rust-scoped
  `K`, `n`/`N`, `J`) checked against kitty's three reserved zones (`alt+1..9`, bare `ctrl+t`,
  any `ctrl+shift+*`) — none use a modifier combination anywhere near those, so this is a
  by-inspection confirmation rather than a re-derivation of the fuller 231-ish-binding inventory.
- **Did not**: run a full `:Lazy sync` across all 95 plugins for real (the two-tier check above —
  spec resolution at the full-tree level, real `setup()` calls for every file this pass actually
  wrote or touched — already gives concrete, verified answers to the two things that needed
  checking); confirm `cargo`/`clippy` availability for rustaceanvim's own clippy-on-save
  auto-detection (no Rust toolchain in this sandbox, the same limitation every prior pass's
  avante.nvim `make`-step testing already hit).

### Check next time

- If `rustaceanvim`'s clippy auto-detection doesn't seem to kick in on the real machine: confirm
  `cargo clippy` actually resolves on `$PATH` there first — not independently confirmable from
  this sandbox (see above).
- `hlargs.nvim`'s flat default color (§1) is a deliberate exception to this config's usual
  theme-linked highlighting — not an oversight if it's ever questioned again.
- The three declined-with-reasons items in §6 — sidekick.nvim, eyeliner.nvim, hydra.nvim — if
  raised again with something that changes the specific reason each was declined for (a
  narrower sidekick integration that doesn't need its own LSP client; a concrete repeated-modal
  workflow hydra.nvim would actually solve here).

---
## 2026-08-27 — nested tree reconstructed (86/86 plugins, real Neovim v0.12.5), monokai-pro.nvim

## added as a 4th theme (one real bug caught building it), 2 stale-documentation fixes,

## .typos.toml reconstructed, 6 new reference repos reviewed (wincent, nv-ide, SeniorMars,

## folke/dot, Allaman, monokai-pro.nvim)

Trigger: the standard re-audit request, naming 15 reference repos this time — 9 already covered
in this log (jdhao, craftzdog, xero, rafi, ecosse3, yutkat, Matt-FTW, linkarzu, nshen), 6
genuinely new (wincent/wincent, crivotz/nv-ide, SeniorMars/dotfiles, folke/dot, Allaman/nvim, and
— a real colorscheme plugin rather than a dotfiles config, the first of its kind named in this
log — loctvl842/monokai-pro.nvim).

### 1. Nested tree reconstructed — same recurring cause, re-verified with a two-way diff script

Same flattening this log has diagnosed on every prior delivery: the upload collapses `lua/
config/*.lua` and `lua/plugins/<category>/*.lua` to one flat directory. Rebuilt the real tree
from the category mapping `init.lua`'s own header, `plugins/loader.lua`'s import list, and
`README.md`'s layout tree all three independently describe (checked all three against each
other first — identical), then diffed the reconstructed filename set against the flat upload in
both directions with a script rather than by eye: **74 files, zero missing, zero unaccounted
for.** `plugins/loader.lua` itself was present this time, not missing an 8th time.

### 2. monokai-pro.nvim — added as a 4th theme; a real latent bug surfaced building it, fixed

Named directly in this pass's own repo list (not a candidate a verification pass merely
surfaced), and a trivial fit for the existing adapter shape in `plugins/ui/themes.lua` — added
rather than left as a candidate, unlike the more speculative items in §6 below.

**Verified against its own source, not its README**: the README's "Filters" section lists six
(classic/octagon/pro/machine/ristretto/spectrum). Its actual `lua/monokai-pro/config/
defaults.lua` type-alias documents a seventh, `"light"`, that the README simply never mentions.
All seven are now this theme's `styles` list, cycled through the same `style_index` mechanism
tokyonight's four styles already use — its own separate `day_night` auto-switch feature was left
untouched rather than layered on top as a second, competing switcher. `devicons = true` set
explicitly (upstream default: `false`) — every other icon integration in this config already
assumes devicons are themed, not left at a plugin's own unthemed default.

**A real bug, not a hypothetical one, live-tested**: `Controller.apply()`'s `package.loaded`
cache-bust loop built its match pattern via plain string concatenation (`"^" .. s.theme`) — fine
for `tokyonight`/`catppuccin`/`kanagawa`, none of which contain a Lua pattern-magic character,
but `monokai-pro` is the first theme name in this table with a `-`, which Lua patterns read as
"0 or more of the preceding item, lazily," not a literal hyphen. Confirmed live rather than
reasoned through: fed the exact old and new pattern-construction code a real `package.loaded`
table shaped like a real monokai-pro.nvim install. Old code matched **0 of 4** of the plugin's
own module names; fixed code (escaping via Lua's `%p` punctuation class — `s.theme:gsub("%p",
"%%%0")`, then used as the pattern) matched all 4, with `tokyonight`'s own match count (2/2)
unchanged. Left uncaught, this would have made every setup() after the *first* visit to
monokai-pro silently keep the first visit's filter/transparency instead of the newly-requested
one — a stale-cache bug, not a crash, so it would have been easy to miss without testing it.

Further live-tested end to end against real upstream source (fresh clones of monokai-pro.nvim,
tokyonight.nvim, kanagawa.nvim — not simulated): a real switch sequence kanagawa → monokai-pro
(dark, `filter="pro"`) → monokai-pro (`filter="light"`) → tokyonight → monokai-pro again
(`filter="spectrum"`), using the fixed cache-bust logic. Every step applied cleanly; both
re-visits to monokai-pro correctly cleared **21** stale `package.loaded` entries each time (0 on
the first, uncached visit, as expected) and correctly reported `background=light` only on the
`"light"`-filter visit — confirms both the fix and the filter list against real behaviour, not
just against reading the source.

**Not done, and said plainly rather than left implicit**: upstream's own README currently flags
its v2.0.0 line as a recent internal refactor with short-term regressions possible — noted in
`themes.lua`'s own header as a real, current caveat, not a reason to withhold a plugin the person
named directly. `background_clear` (which plugins get their background force-cleared under this
theme) was left at upstream's own default list rather than extended to match this config's own
transparency-everywhere style — a real customization option, not evaluated with the same
confidence as the two changes above, so left alone rather than guessed at.

### 3. Two stale-documentation fixes — found by fresh grep, not by re-reading old conclusions

- **`plugins/deps/shared.lua`**'s own "Consumers:" comment for `nvim-lua/plenary.nvim` named 5
  files; grepping the actual current tree for the literal dependency string finds **9**:
  the 5 already named, plus `plugins/git/octo.lua`, `plugins/ai/avante.lua`, `plugins/ai/
  mcphub.lua`, and `plugins/explorer/yazi.lua` — all four added across passes after this
  comment was last written, none of which updated it. Same gap for `MunifTanjim/nui.nvim`:
  documented 3, actually 4 (missing `plugins/ai/avante.lua`). Both corrected against the fresh
  grep, the exact drift this file's own stated purpose ("answerable by reading one file instead
  of grepping... across a dozen") exists to prevent.
- **`init.lua`**'s own header said its smaller borrowed-pattern credits came from "three other
  public configs" directly above a list of **four** (craftzdog, xero, rafi, ecosse3) — stale
  since ecosse3 was added as the fourth in the 2026-08-17 pass, which added the bullet but never
  circled back to the summary sentence above it. Corrected to "four."

### 4. `plugins/ai/avante.lua` — model string a year stale, updated

`model = "claude-sonnet-4-20250514"` was a fixed May-2025 snapshot. Anthropic's current lineup
uses undated rolling aliases rather than dated pins — `claude-sonnet-5` is the current fast/
flagship-tier alias as of this pass. Structure unchanged (`providers.claude.endpoint`/`.model`
is still current avante.nvim's own real schema, confirmed against its current docs and several
current usage examples) — only the value was stale, not the shape around it.

### 5. `.typos.toml` reconstructed

Referenced in this log's own 2026-08-17 (second session) entry as already present and adapted
from jdhao/nvim-config's structure; absent from this upload. Same class of gap as
`plugins/loader.lua`'s recurring disappearance, but for a dotfile rather than a nested directory
— apparently dotfiles don't survive this chat's project-knowledge sync at all, a distinct cause
from the directory-flattening one, worth naming separately if it recurs. Reconstructed at the
schema verified against typos' own current reference docs (`[default.extend-words]`, self-
referencing `word = "word"` entries to accept a spelling as-is) with this config's own jargon —
not re-run against a real `typos` binary (no `cargo`/`rustc` in this sandbox to build one from
source, the same limitation every prior pass's avante.nvim `make`-step testing already hit).

### 6. Six new reference repos (first look)

- **folke/dot**: highest-signal of the six, given how much of this config already runs on
  folke's own plugins. Two real, current candidates surfaced, neither added: `folke/
  sidekick.nvim` (his newer, actively-developed "Next Edit Suggestions" + CLI-agent-multiplexer
  plugin) sits in his own config where copilot.lua/an AI sidebar might otherwise — a bigger,
  more architecturally-loaded swap than this pass makes unilaterally, given this config's own
  four-tool AI stack (copilot/avante/opencode/mcphub) is itself already a deliberate, integrated
  choice. `snacks.nvim`'s own `image` module (inline image/LaTeX-math rendering via the
  terminal's graphics protocol) is plausible given kitty.conf confirms a graphics-protocol-
  capable terminal is actually in use and snacks.nvim is already installed — not enabled: its
  current default-enabled state wasn't independently confirmed with the same confidence as §2's
  changes, and it changes buffer rendering behaviour non-trivially enough to want that
  confirmation first.
- **wincent/wincent**: reviewed directly (`aspects/nvim/files/.config/nvim/`), not skipped for
  size (the full repo is 253MB/21,555 files — almost all of it unrelated to Neovim). Built on
  Neovim's native `pack/bundle/opt/` package manager rather than lazy.nvim, with a keymap
  philosophy (`gd` bound to *declaration*, not definition; heavy bare-`<Leader>` use) that is
  wincent's own long-standing personal convention rather than a community one — structurally too
  different for direct portability, the same conclusion a past entry reached independently for
  craftzdog/rafi once they turned out to be LazyVim layers. Nothing extracted.
- **crivotz/nv-ide**, **SeniorMars/dotfiles**: both reviewed (keymaps/config files read
  directly); nv-ide is a thin LazyVim customization (6-line keymaps.lua); SeniorMars runs an
  older, substantially different plugin set (vim-fugitive, Grepper, Neorg, UndotreeToggle) with
  no equivalent gap in this config's own already-covered territory. Nothing extracted.
- **Allaman/nvim**: reviewed directly; its own practice of deleting native `gra`/`gri`/`grn`/
  `grr`/`grt`/`gO`/`]d`/`]D` to declutter which-key is a different, equally valid design choice
  from this config's own (documenting native defaults in reference boxes rather than removing
  them — `mappings.lua`/`lspconfig.lua`'s own boxes) — a preference, not a bug either way.
  Nothing extracted.

### 7. Re-confirmed, not re-changed

Fresh clones of all 9 previously-covered repos (not cached, not assumed unchanged, per this
log's own standing practice) — commit dates range from 2026-08-27 (yutkat, today, an unrelated
zsh commit) back to 2026-03-05 (ecosse3); nothing materially new for this config specifically.
One item worth a note despite no conclusion changing: jdhao added real `after/lsp/ty.lua` and
`after/lsp/pyrefly.lua` configs this past week (2026-08-24) — both are the same two Python
type-checkers already sitting commented-out in this config's own `lspconfig.lua` `external_
servers` with the same reasoning (would double basedpyright's diagnostics if both ran at once).
A second independent data point for an already-open, already-documented candidate, not a new
one.

- **kitty.conf**: fresh upload, content unchanged (same 2026-08-12 header, same reserved zones).
  Re-derived the full current keymap inventory programmatically and checked it against all three
  reserved zones (`alt+1..9`, bare `ctrl+t`, any `ctrl+shift+*`) — explicitly including the
  `ctrl+shift+h/j/k/l` vim-style split-navigation block this file's own header calls out as an
  addition — **zero matches**, same conclusion as every prior pass, re-derived rather than cited.
- **Keymap collisions / augroup uniqueness**: rebuilt the extractor from scratch (brace-depth-
  aware, both binding styles this config uses) rather than reusing a cached script. **36
  `augroup()` call sites, 36 unique names, 0 duplicates** — exact match with every prior count.
  One cross-file same-(mode,lhs) hit, and the same one every prior pass has found: bare `q`
  (global no-op vs. the buffer-local close-window override in utility filetypes) — already
  correct, buffer-local wins, not re-litigated.
- **`servers`/`ensure_installed` and `conform`/`mason-tool-installer` cross-checks**: both still
  an exact match in both directions (18 Mason-managed LSP servers; every CLI-based formatter/
  linter has a matching installer entry) — reconfirmed, not re-asserted.
- Everything else already covered in this log (dial's unconfigured augends, yazi's on-demand-
  only role, octo's ex-command-only surface, the open candidates list below, etc.) — reviewed
  against this pass's own full read of the current tree, nothing found that changes any of it.

### 8. This log condensed further

The 2026-08-18 "nested tree rebuilt + fully re-tested... web-devicons deep dive... rust_analyzer
clippy-on-save" entry carried a full section-by-section investigation narrative for two findings
(web-devicons' actual current option surface, rust_analyzer's one settings change) that are now
ten days settled and re-confirmed twice over since. Condensed to conclusions + the specific
things a future pass would need to know (the `check.command` vs `checkOnSave.command` naming
trap, yutkat's live `mini.icons` alternative) — every "Check next time" item survived. Nothing
cross-referenced by filename from another file's header was touched.

### Testing this pass actually did

- Reconstructed the nested tree and diffed the filename set both directions against the flat
  upload (§1) — 0 missing, 0 unaccounted for.
- **Downloaded a real Neovim binary, v0.12.5** (bumped from every prior entry's v0.12.4) and
  cloned a real `lazy.nvim`. Real (not simulated) spec resolution via `Config.setup()` +
  `Plugin.load()` against the actual tree: **86/86 plugins, 0 errors** both before this pass's
  edits (85, matching the prior entry's own count) and after (86, the +1 being monokai-pro.nvim)
  — confirming the addition resolves correctly, not just parses.
- **Real functional colorscheme-switch test** against fresh clones of monokai-pro.nvim,
  tokyonight.nvim, and kanagawa.nvim (§2) — not simulated, and specifically designed to catch a
  revisit-the-same-theme-twice bug, which is exactly what it caught.
- `luac5.1 -p` across all 74 `.lua` files, before and after every edit — 0 syntax errors.
- `.typos.toml` parsed with a real TOML parser — valid.
- Independent, freshly-written keymap-collision and augroup-uniqueness scans (§7).
- Fresh clones of all 15 named repos (9 re-confirmed, 6 first-look, §6-§7) — not cached.
- **Did not**: run a real `typos` binary against the reconstructed `.typos.toml` (no cargo/rustc
  in this sandbox, §5); independently confirm `snacks.nvim`'s current default `image.enabled`
  state (§6, why it wasn't switched on); complete a full `:Lazy sync` of all 86 plugins for
  real (the lower-level spec-resolution + the targeted 3-plugin functional test already give
  concrete, verified answers to the two things that actually needed checking this pass).

### Check next time

- §6's two new candidates (`folke/sidekick.nvim`, `snacks.nvim`'s `image` module), if raised
  again specifically.
- `monokai-pro.nvim`'s `background_clear` list (§2) — left at upstream's default; extend it to
  match this config's own transparency choices if the transparent-background toggle ever looks
  inconsistent under this theme specifically.
- Every previously-open candidate (rustaceanvim, git-conflict.nvim, nvim-window-picker/
  stickybuf.nvim, guess-indent.nvim, neogen, mini.icons, the smaller aesthetic ones, `ty`/
  `pyrefly` per §7) — unchanged, not re-litigated without new evidence.

---

Trigger: explicit ask to swap the hjkl throttle from the home-grown `utils.cowboy()` to
`hardtime.nvim` — the same plugin the previous entry (below) had just cited as a reason to *keep*
cowboy() (2 reference configs run it with `enabled = false`). That finding was about other
people's defaults, not a verdict on this config; the person weighed it and chose the plugin
anyway, which is exactly the kind of call this log has consistently left to them rather than
re-arguing once made (see e.g. the candidates lists in the last several entries). Implemented the
swap, not re-litigated it.

### What changed

- **`utils.lua`**: removed `cowboy()` entirely (was the LazyVim-derived hjkl/+/- throttle).
  `rand_int()`'s EOL comment claimed cowboy() called it directly — checked, it never did (stale
  even before this pass) — corrected while removing the now-fully-stale claim rather than leaving
  a dangling reference. Removed the file header's cowboy attribution sentence.
- **`config/mappings.lua`**: removed the `utils.cowboy()` call and, since that was the only
  `utils.*` use in the file, the now-dead `local utils = require("utils")` alongside it.
- **`plugins/ui/noice.lua`**: its header cited `utils.lua's cowboy()` as an example plain-
  `vim.notify()` source feeding Noice's toast rendering — swapped for
  `plugins/editor/hardtime.lua`'s hint/restriction messages, which is now the actually-correct
  example of the same thing.
- **`plugins/deps/shared.lua`**: added `plugins/editor/hardtime.lua` as a third consumer of
  `MunifTanjim/nui.nvim` (hardtime's own documented dependency — already installed via
  `noice.lua`, so this doesn't add a new plugin to the tree, just a second/third reason to keep
  installing the one already there).
- **New `plugins/editor/hardtime.lua`**.

### hardtime.lua — what was checked before writing it, not just what it does

Cloned `m4xshen/hardtime.nvim` fresh rather than configuring from memory (per this log's standing
"verify, don't assume" practice) — current default `lua/hardtime/config.lua`, not a cached or
remembered version.

**A real conflict, not a hypothetical one**: upstream's default `disable_mouse = true` would have
fought `options.lua`'s own `opt.mouse = "n"` (deliberate, commented) and broken
`plugins/editor/multicursor.lua`'s Ctrl+click add/remove-cursor feature outright, which needs the
mouse enabled to work at all. Confirmed live, not just by reading the source: called hardtime's
real `setup()` against a real Neovim v0.12.4 binary with `disable_mouse` left at its default,
watched `vim.o.mouse` get forced back to `""` on activation. Set `disable_mouse = false`
explicitly; re-ran the same live test with the override in place and confirmed `vim.o.mouse`
survives untouched.

One small deliberate addition: `restricted_keys["-"]`. cowboy() throttled `h`/`j`/`k`/`l`/`+`/`-`;
upstream's own `restricted_keys` ships `+` (and its own extra set: `gj`/`gk`/`<C-M>`/`<C-N>`/
`<C-P>`, which cowboy() never touched) but not `-`, its natural counterpart. Added it back for the
same symmetry cowboy() already had. Confirmed live that this is a genuine deep-merge, not a
silent full-table replacement — `vim.tbl_deep_extend("force", ...)`, read directly in
`lua/hardtime/init.lua` — by checking that `h`, `+`, and the rest of upstream's defaults (all 34
`disabled_filetypes` entries included) were untouched after the merge.

**Deliberately left at upstream defaults, not tuned toward cowboy's old leniency**:
`max_time`/`max_count` (upstream: 3 presses per 1000ms) are considerably stricter than cowboy's
effective ~10-in-a-row-without-a-2s-gap. Chose not to soften these toward cowboy's old feel —
the person asked to adopt hardtime, not to reskin cowboy under a new name, and hardtime's
`resetting_keys` table (any real edit command resets the streak) already makes the raw numbers
less aggressive in practice than they look in isolation. `disabled_filetypes` also left at
upstream's default rather than given a config-specific override: checked it against every
dashboard/tree/picker/notify surface this config actually installs (alpha, Avante, dapui.*,
Diffview.*, lazy, mason, neo-tree.*, neotest-summary, noice, notify, oil, TelescopePrompt,
Trouble/trouble, qf) — all already excluded by name upstream, so an override here would only
duplicate what's already covered, with more surface to go stale later.

**`lazy = false`, matching upstream's own install instructions** (checked the current README's
"Installation" section directly) rather than an `event` trigger like most of this config's other
`plugins/editor/*.lua` files use — hardtime needs to be watching from the first buffer, not
deferred. Reading `lua/hardtime/init.lua` directly surfaced something worth recording so a future
pass doesn't "fix" this into an event trigger without knowing why: `M.setup()` doesn't do its real
work synchronously at all — it starts its own 500ms timer and defers the actual key-hooking to
that callback. First test of this file's `opts` came back showing *upstream's unmodified
defaults* even with real overrides passed in; turned out the test was reading `hardtime.config`
before the 500ms timer had fired, not that the overrides failed. Re-ran with a `vim.wait(700)`
after `setup()` and got the expected merged config back. `lazy = false` doesn't defeat that
internal delay — it just means the countdown to it starts as early as possible.

Added `<leader>tH` ("Toggle Hardtime") under the existing `<leader>t` (Toggle) which-key group —
no which-key.lua edit needed, since that group already exists with 11 other children and only
new *group* prefixes need an entry there, not individual leaves (which-key.lua's own header).
`H` chosen because `h` is already `<leader>th` (toggleterm's horizontal split); the existing
`tC`/`tc` and `tG`/`tg` pairs in that group already establish case as the way this config
distinguishes closely-related toggles, so this follows the same pattern rather than inventing a
new one.

### Testing this pass did

- Live-tested the `disable_mouse` conflict and its fix, and the `restricted_keys` deep-merge,
  against hardtime.nvim's real `setup()` (not simulated) — see above.
- Re-ran the same `Config.setup()` + `Plugin.load()` live spec-resolution test from the entry
  below: **85/85 plugins resolve** (84 from before, + hardtime.nvim) through the real
  `plugins.loader` → `plugins.editor` chain, 0 errors, 0 notifications. `nui.nvim` correctly
  stayed a single deduplicated entry rather than doubling, confirming the shared-dependency
  declaration in `deps/shared.lua` works as documented.
- Re-ran the same keymap-collision extractor from the entry below against the updated tree: 225
  bindings now (224 + `<leader>tH`), 0 cross-file collisions, same single (already-verified false
  positive) same-file flag in `diffview.lua` as before — nothing new.
- `loadfile()`-parsed all 74 `.lua` files — 0 syntax errors.
- Swept the whole tree for leftover `cowboy` references after removal — only the new
  `hardtime.lua`'s own explanatory mentions of what it replaced remain; nothing stale left behind
  in `utils.lua`, `mappings.lua`, or `noice.lua`.

### Check next time

- `:Lazy sync` (or a restart, since `install.missing` is already true in `config/lazy.lua`) is
  still needed on the actual machine to clone hardtime.nvim for real and let lazy.nvim write its
  own lockfile entry — not done here, deliberately: hand-writing a commit hash into
  `lazy-lock.json` would just be guessing at what `:Lazy sync` does automatically and correctly
  the moment it runs.
- If hardtime's nagging turns out too aggressive in practice, `max_time`/`max_count` (left at
  upstream defaults this pass, see above) are the two to loosen first — `<leader>tH` is the
  faster escape hatch for one-off bursts of repeated movement.

---

## 2026-08-20 — `plugins/init.lua` collision fixed at the root cause (renamed, not reconstructed),
## independent from-scratch collision/redundancy scan, linkarzu/dotfiles-latest + nshen/learn-
## neovim-lua added as first-look reference configs, live lazy.nvim spec-resolution test

Trigger: the standard re-audit request, this time naming 2 genuinely new reference repos
(linkarzu/dotfiles-latest, nshen/learn-neovim-lua) alongside the 7 already covered in this log.
Read this log first rather than re-deriving from scratch — confirmed its own account of the
recurring `plugins/init.lua` flattening bug against this session's own upload (72 `.lua` files,
not 73; `comm`-diffed the full source/destination filename sets after reconstructing the nested
tree from README.md's own documented layout — zero files unaccounted for either direction) before
doing anything else.

### 1. `plugins/init.lua` — fixed the recurring cause instead of re-hitting it an 8th time

Every prior occurrence reconstructed a file named `plugins/init.lua`, which collides with the
root `init.lua` again the moment this tree gets flattened to one directory (both share the
basename "init.lua"). Root `init.lua`'s own header already documented *why* the file has to
exist (lazy.nvim's `lsmod` won't descend into a category folder without its own `init.lua`) —
that reasoning was correct and is unaffected by a rename. Read `lazy.nvim`'s actual
`lua/lazy/core/util.lua` `lsmod()` directly (fresh clone, not memory): a plain module file and a
`dir/init.lua` package resolve through the *same* branch (`match:sub(-4) == ".lua"` fires
identically either way) — nothing about the mechanism requires the specific name `init.lua`.
Renamed the file to `plugins/loader.lua` (same 15 `{ import = "plugins.<category>" }` lines,
same role) and updated the one reference in `config/lazy.lua`
(`{ import = "plugins" }` → `{ import = "plugins.loader" }`), plus the file-layout notes in root
`init.lua` and `README.md` that named the old path. This removes the only basename collision left
in the tree (confirmed only one exists — see §3) permanently, rather than re-fixing it next time.

**Verified live, not just by reasoning through the source**: a full `require("lazy").setup()`
smoke test in this sandbox's headless mode hit unrelated friction (`Loader.setup()`'s handler/
autocmd registration silently short-circuited plugin resolution under non-interactive `-l`
execution — a harness quirk, not a config issue). Went one layer lower instead: called
`Config.setup()` + `Plugin.load()` directly — the actual spec-parsing code path — against a real
downloaded Neovim **v0.12.4** binary and a real cloned `lazy.nvim`. Result: **84 plugins
resolved through `plugins.loader` with zero errors and zero notifications** — an exact match
for `lazy-lock.json`'s 83 locked entries plus `lazy.nvim` itself. Every category (`lsp`,
`completion`, `treesitter`, `editor`, `ui`, `git`, `explorer`, `search`, `debug`, `test`,
`lang-tools`, `terminal`, `ai`, `frontend`, `deps`) is represented in the resolved list by name
(avante.nvim, blink.cmp, telescope.nvim, all three colorschemes, the full DAP/LSP/treesitter
stacks, etc.) — not just a count match.

### 2. Independent redundancy/collision scan — rebuilt from scratch, not re-run from a cached script

Wrote a new Python extractor (not reused from a prior pass) that parses both binding styles this
config actually uses: direct `vim.keymap.set()`/`map()` calls, and lazy.nvim's declarative
`keys = {}` spec tables (brace-depth aware, so nested tables inside a `keys` block don't get
misread as sibling entries). **224 bindings extracted, 0 cross-file collisions** — consistent
with this log's own prior count (216, before this pass's own additions) via a genuinely
independent method. One same-file flag turned out to be a false positive on inspection:
`diffview.lua`'s two `map("i", "<CR>", ...)` calls are inside two different Telescope
`attach_mappings(_, map)` callbacks — that `map` is Telescope's own picker-scoped parameter, not
this config's `vim.keymap.set` alias; nothing to fix.

Also re-derived, independently: **36 `augroup()` calls, 36 unique names, 0 duplicates**
(exact match). A deprecated/stale-syntax sweep (`vim.loop`, pre-0.11 `lspconfig.X.setup{}`,
packer.nvim remnants, `tbl_add_reverse_lookup`, `start_client`/`buf_attach_client`, deprecated
`nvim_buf_get_option`-family calls, old `:hi` strings, positional `vim.validate`) came back
**clean across all 8 checks** — nothing to modernize this pass. Traced every option name touched
in more than one file (`backup`, `relativenumber`/`number`, `smartcase`, `formatoptions`,
`shortmess`, `wildignore`, etc.): every case is either multiple `:append()` calls building one
value in the *same* file, or the already-documented `options.lua` (baseline) / `autocmds.lua`
(reactive) split each file's own header already cross-references — no undocumented redundancy
found.

`which-key.lua` re-checked against the real inventory above: every `<leader>` prefix with 2+
children has a group entry, none stale. Two apparent gaps (`<leader>w`, `<leader>m`) turned out
to be this pass's own extractor missing non-standard local aliases (`multicursor.lua` uses
`local set = vim.keymap.set`; `lspconfig.lua`'s own `map()` helper takes `lhs` first, not mode
first) — verified directly by reading both files rather than trusting the script, confirmed both
groups are real and complete (3 and 13 children respectively). `utils.lua`'s "used by X.lua" EOL
attribution and the `999rpm-` augroup namespacing (§ above) were both already comprehensive going
into this pass — reconfirmed, not re-explained.

### 3. kitty.conf — re-verified against the real 224-binding inventory, independently derived

Fresh upload; content unchanged (same `enabled_layouts`/`cursor_trail_decay`/`ctrl+w` fix
comments, same "ctrl+w intentionally left unbound here" line at 91, matching this file's own
claim). Extracted kitty's full reserved zone directly from the uploaded file (`alt+1`–`9`, bare
`ctrl+t`, every `ctrl+shift+*` combo it binds) and checked it against all 224 nvim bindings
programmatically: **zero `<M-1>`–`<M-9>`, zero bare `<C-t>`, zero `<C-S-*>` of any kind anywhere
in this config.** Same conclusion as every prior pass, re-derived rather than cited.

### 4. Two new reference repos (first look) + refresh on the other 7

**linkarzu/dotfiles-latest**: not a from-scratch nvim config — a large macOS system-dotfiles repo
with 4 different nvim variants under `neovim/`; `neobean` is the actively-used one (confirmed via
its own README: "the Neovim config you see me using on each one of my videos"). Its
`config/keymaps.lua` (4,528 lines) is almost entirely linkarzu's own blogging/content-creation
workflow (Imgur uploads, Obsidian-style daily notes, `osascript`/ForkLift calls) — low signal for
a general-purpose Linux config, nothing ported wholesale. Two things worth noting rather than
silently skipping: (1) its `hardtime.lua` has `enabled = false` — a real user tried the heavier
habit-breaking plugin and turned it off, which is evidence *for* keeping this config's existing
lighter-touch `utils.cowboy()` rather than a reason to swap it; Matt-FTW/dotfiles disables the
same plugin independently, a second data point. (2) `nzzzv`/`Nzzzv` (center screen after a search
jump) and `mzJ`z` (preserve cursor column across `J`) appear in both linkarzu variants, in
Matt-FTW's `smooth-scrolling` extra, and in xero's `commands.lua` — confirmed absent from this
config's own `mappings.lua` via the inventory above. Four independent sources, a real and verified
gap, small and reversible — listed in §5, not added (see that section for why).

**nshen/learn-neovim-lua**: explicitly a paid-course companion repo, self-described in its own
README as since superseded by a newer project (InsisVim). Its `lua/utils/` files are genuinely
dated — a WSL-specific `clip.exe` yank hack, a macOS-only IME switcher, and a `change-colorscheme.lua`
built on an old Telescope sorter API (`get_generic_fuzzy_sorter`) plus a call to
`vim.api.nvim_add_user_command`, which is not a real API (the actual function is
`nvim_create_user_command`) — a bug in the source repo itself, not something to port. Nothing
extracted from this repo.

**The other 7** (jdhao, craftzdog, xero, rafi, ecosse3, yutkat, Matt-FTW): freshly re-cloned, not
cached or assumed unchanged. `git ls-remote` against the GitHub REST API hit this sandbox's shared
egress IP rate limit (a sandbox artifact, not a finding), so recency was checked by clone content
instead. Nothing materially new since the 2026-08-18 comparison in this log — re-confirmed rather
than re-asserted.

### 5. Candidates found, not added

- **`nzzzv`/`Nzzzv` + `mzJ`z`** (§4) — real, multi-source-verified, low-risk keymap additions to
  `mappings.lua`. Not added: this log's own practice throughout has been to add new keybindings
  only against an explicit ask or a confirmed bug, not to invent ones a verification pass merely
  finds elsewhere — the person's own muscle memory is theirs to extend, not to have extended for
  them.
- **`guess-indent.nvim`** — open since the 2026-08-18 entry (§6 there), now with stronger
  evidence: an *active* choice (not just a template default) in 4 of the 9 reference repos
  checked across this log's history, including yutkat's real `pluginlist.lua`. Still a plugin
  addition, still the person's call.
- Everything else still open from the 2026-08-18 candidate list (rustaceanvim, git-conflict.nvim,
  nvim-window-picker/stickybuf.nvim, neogen, and the smaller aesthetic ones) — unchanged, not
  re-litigated without new evidence.

### 6. One style fix: `<Leader>` → `<leader>`

`mappings.lua` had 9 keymaps using capitalized `<Leader>` (the no-yank-register and
new-line-without-comment groups) against 125 uses of lowercase `<leader>` everywhere else in the
tree (confirmed via the same inventory extraction — every other file already used lowercase
exclusively). Functionally identical (Vim's key-notation parser treats the `leader` keyword
case-insensitively), but normalized to match the dominant, otherwise-universal convention.

### Testing this pass actually did

- Reconstructed the real nested tree from this session's flattened upload and diffed the full
  filename set both directions (`comm -23`) against the flat source — zero files unaccounted for.
- `loadfile()`-parsed all 73 `.lua` files (via a real Neovim v0.12.4 binary's bundled LuaJIT,
  `nvim --headless -l`) — 0 syntax errors, before and after every edit in this pass.
- Live spec-resolution test against real `lazy.nvim` source (not simulated): **84/84 plugins**,
  0 errors, 0 notifications (§1).
- Independent, from-scratch Python extraction of all 224 keymap bindings across both styles this
  config uses; independent augroup-uniqueness check (36/36); an 8-point deprecated-syntax sweep;
  a full cross-file option-touch trace; kitty.conf re-derived against the real inventory rather
  than cited from a prior finding (§§2–3).
- Fresh clones of all 9 reference repos named this session (7 re-confirmed, 2 first-look) — not
  cached, not assumed (§4).
- **Did not**: complete a full `:Lazy sync`-equivalent plugin *install* (network/time cost for
  ~84 real clones wasn't spent this pass, since the lower-level spec-resolution test already gives
  a concrete, verified answer to the specific thing that needed checking — whether the renamed
  loader file resolves correctly); test any real interactive UI behavior (same structural
  limitation every headless pass in this log has).

### Check next time

- If `plugins/loader.lua` is ever missing on a future upload: same root cause (basename
  flattening) as the seven `plugins/init.lua` occurrences before it, but this file's own new name
  means it can no longer collide with root `init.lua` specifically — if it still goes missing,
  something else in the upload path changed and the cause needs re-diagnosing, not assumed to be
  the same collision.
- `nzzzv`/`Nzzzv`/`mzJ`z` and `guess-indent.nvim` (§5), if ever raised again specifically.

---

## 2026-08-18 (third session) — avante's other default actions given real `<leader>i*` slots

Trigger: direct follow-up to the entry below — `auto_set_keymaps = false` fixed the `<leader>a`
bug, but as a side effect also silently removed default access to avante's other actions (ask,
new chat, stop, refresh, focus, select model/history, add files, zen mode, repo map), since
they'd only ever been reachable _by accident_, as the same bug. Asked to give the worthwhile ones
real, deliberate keybindings instead of leaving them unreachable.

### What each one actually calls, verified against avante's real installed source, not guessed

Read `avante/init.lua`'s own `H.keymaps()` to confirm its defaults call `avante.api` functions
under the hood, then used the same public module directly (`ia`/`ie` above already do this —
`require("avante")` directly, not `<Plug>` mappings — so this matches, not introduces, the
existing convention): `ask()`, `ask({ new_chat = true })` for new-chat, `stop()`, `refresh()`,
`focus()`, `select_model()`, `select_history()`, `add_buffer_files()`, `zen_mode()` (confirmed an
alias for `full_view_ask` in `api.lua`), and `avante.repo_map.show()` for the repo-map action
(not in `avante.api` — traced `<Plug>(AvanteShowRepoMap)` to find it). "Add current file" doesn't
use the original default's implementation on purpose: config.lua's own `files.add_current` is
wired inside `sidebar.lua`'s `Sidebar:on_mount`, reaching into the live sidebar instance's
internal `file_selector` — fragile to depend on directly. `avante.api.add_selected_file(filepath)`
is the public-module equivalent (confirmed it auto-opens the sidebar if needed, same as
`add_buffer_files`) — used that instead, called with `vim.api.nvim_buf_get_name(0)`.

### Key scheme

New letters (`A`/`n`/`s`/`r`/`f`/`m`/`h`/`b`/`F`/`z`/`R`) checked against every existing
`<leader>i*` binding (avante's own `a`/`e`, opencode.lua's `o`/`c`) and against nesting under
`ia`/`ie` specifically — the latter would silently recreate the exact leaf-vs-prefix ambiguity
the entry below just fixed, one level deeper. All new entries are flat, single-character
`<leader>i*` siblings, not nested. `which-key.lua`'s own `<leader>i` = "AI" group entry already
covers all of these (no new multi-child sub-prefix was created, so no which-key.lua change
needed — checked against that file's own stated completeness rule, not assumed).

Deliberately not given a slot: `toggle.suggestion` (would reintroduce manual access to the exact
feature `behaviour.auto_suggestions = false` in this same file turns off on purpose, to not
compete with copilot.lua); `toggle.debug`/`toggle.selection` (real but narrow — internal debug
logging, the visual-selection ask/edit hint popup — low daily value, still reachable via `:lua`
if ever wanted); `select_acp_model`/`select_acp_mode`/`switch_provider` (avante's ACP bridge to
_other_ agent CLIs — this config's `provider = "claude"` uses avante's direct Anthropic API
instead, so these don't apply to the current setup, not a coverage gap).

### Testing

Headless: every one of the 21 `<leader>i*` (mode, lhs) pairs (11 new + `ia`/`ie`/`io`/`ic`
existing) resolves to its exact intended `desc`, confirmed against `vim.fn.maparg()` — not
inferred from the source alone. Every underlying function (`avante.api.ask`/`stop`/`refresh`/
`focus`/`select_model`/`select_history`/`add_buffer_files`/`add_selected_file`/`zen_mode`,
`avante.repo_map.show`) confirmed to actually exist and be callable in the real installed avante
source, not just assumed present from reading it. Re-ran the full 216-binding collision scan (0
cross-file collisions, up from 204 — the +12 is exactly the new entries' (mode,lhs) pairs), the
18-point functional suite (18/18), `luac5.1 -p` across all 73 files, and re-confirmed `<leader>a`
is still unambiguous (`<leader>aa`/`<leader>at` still absent) — this pass didn't touch that file's
own fix, but re-checked rather than assumed it still held.

---

## 2026-08-18 (second session) — real bug from live usage: `<leader>a` which-key label vs actual

## behavior mismatch, root-caused to avante.nvim's own `auto_set_keymaps` default

Trigger: a direct report from actual use — which-key shows `<leader>a` as "Swap parameter with
next" (textobjects.lua), but pressing it fires an avante command instead. Exactly the class of
bug the 2026-08-17 first-session entry's own testing section had flagged as unreachable headlessly
("did not test any real interactive UI behavior — which-key popup rendering... structurally can't
reach it") — this is that gap, now hit for real.

### Root cause, verified against avante's real installed source, not guessed

`avante.lua` already avoids `<leader>a` for its own `keys` table (`<leader>ia`/`<leader>ie`
instead, per its own header comment) specifically to not collide with textobjects.lua's
`<leader>a`/`<leader>A`. That part was always correct. What wasn't accounted for: `avante.setup()`
_also_ unconditionally installs its own full set of default keymaps
(`config.lua`'s `mappings` table — `ask = "<leader>aa"`, `toggle.default = "<leader>at"`,
`zen_mode = "<leader>az"`, `refresh = "<leader>ar"`, `focus = "<leader>af"`, `stop = "<leader>aS"`,
`select_model = "<leader>a?"`, and several more) unless `behaviour.auto_set_keymaps` is explicitly
set to `false` — a config option this file's `opts` table never touched. avante's own installer
(`avante/utils/init.lua`'s `safe_keymap_set`) claims to skip already-taken keys, but its check only
queries lazy.nvim's _declarative_ `keys` registry (`Keys:have(lhs, mode)`) — it has no visibility
into a plain `vim.keymap.set()` call made directly inside another plugin's `config` function, which
is exactly how textobjects.lua sets `<leader>a`. So avante's own conflict check never saw it, and
registered `<leader>aa`/`<leader>at`/etc. for real. Confirmed live in a headless session (not
inferred): after both plugins load, `<leader>a` correctly resolves to the swap function _and_
`<leader>aa`/`<leader>at` are simultaneously real, separate mappings — making `<leader>a` both a
leaf and a prefix at once, which which-key resolves by descending into avante's group rather than
firing the leaf. This is why the label was accurate but the behavior wasn't: two different systems
(the raw keymap for the exact 2-key sequence, and which-key's prefix-tree navigation) disagreed.

Checked the neighboring risk before concluding this was the only issue: avante's other default
mapping groups (`diff.*`, `jump` `]]`/`[[`, `suggestion.*` `<M-l>` etc.) are _not_ gated by
`auto_set_keymaps` — confirmed they're bound buffer-locally inside `sidebar.lua`, with a matching
`vim.keymap.del(..., { buffer = ... })` on close, so they were never a global conflict with
flash.nvim's own `]]`/`[[` in the first place. Nothing to change there.

### Fix applied

`avante.lua`'s `opts.behaviour` gains `auto_set_keymaps = false`. Verified two ways: (1) the same
headless reproduction re-run post-fix shows `<leader>aa`/`<leader>at` now `<NOT MAPPED>` while
`<leader>a`/`<leader>A` are unchanged (still the swap functions) — `<leader>a` is a leaf only,
no longer ambiguous; (2) this config's own `<leader>ia`/`<leader>ie` (registered via lazy.nvim's
`keys` table, a completely separate mechanism from `Config.behaviour.auto_set_keymaps`) still
resolve correctly, confirming the fix didn't touch what it wasn't meant to. Full 18-point suite
and the 204-binding/0-collision static scan both re-run clean after the change.

### Check next time

Disabling `auto_set_keymaps` removes access to avante's _other_ default actions this config never
gave its own keybinding — `new_ask`, `zen_mode`, `refresh`, `focus`, `stop`, `toggle.debug/
selection/suggestion/repomap`, `select_model`, `select_history`, `files.add_current/
add_all_buffers`, `select_acp_model/mode`. None were reachable _on purpose_ before either (they
were only ever live by accident, as a side effect of the bug this entry fixes) — not treated as a
regression, but worth flagging: if any of these are actually wanted, they belong as deliberate
`<leader>i*` entries in this file's own `keys` table (consistent with how `ia`/`ie` are already
done), a small, low-risk follow-up, not done here since picking which ones is a product call this
pass didn't have a reason to make unilaterally.

---

## 2026-08-18 — nested tree rebuilt + fully re-tested (83/83 plugins, real Neovim v0.12.4),

## yutkat/dotfiles + Matt-FTW/dotfiles (both first look), web-devicons deep dive, rust_analyzer

## clippy-on-save, kitty.conf re-confirmed against a fresh upload (condensed 2026-08-27)

Trigger: the same recurring re-audit request, this time naming 7 reference configs explicitly —
5 already covered (jdhao/craftzdog/xero/rafi/ecosse3) plus yutkat/dotfiles and Matt-FTW/
dotfiles, both new — with an explicit ask to focus on nvim-web-devicons.

`lua/plugins/init.lua` missing again (7th time, same cause/fix). Full nested-tree rebuild, real
Neovim v0.12.4 + real `lazy.nvim` bootstrap: all 83 plugins installed (avante.nvim's own `make`
step failed on this sandbox's missing cargo/rustc, already-diagnosed and not a config bug). An
18-point functional suite passed 18/18; independently re-derived keymap-collision scan: 204
bindings, 0 cross-file collisions; 36 unique augroups, 0 duplicates; `servers`/`ensure_installed`
and `conform`/`mason-tool-installer` both exact matches. kitty.conf re-confirmed unchanged
against a fresh upload, zero conflicts against the 204-binding inventory.

**web-devicons deep dive** (the requested focus): current `{ default = true, strict = true }`
verified against live upstream — both real options, nothing deprecated. `themes.lua`'s light/
dark switch and devicons' own `variant` option already talk to each other for free (devicons
watches `background` internally) — not a gap. xero's ~200-entry manual icon-override table
predates upstream's own current filename-icon coverage — not ported, would be redundant.
ecosse3's own devicons spec is a strict subset of what's already here. **yutkat/dotfiles'
actual live choice is `mini.icons`, not nvim-web-devicons** — a real, maintained alternative,
listed as a candidate (see below), not switched to (a provider swap needing all 12 consuming
files re-tested is a bigger call than a verification pass makes unilaterally).

**One fix applied**: `rust_analyzer` was the one Mason-managed server left as bare `{}` while Go/
Python both have real settings — added `check.command = "clippy"` (verified against
rust-analyzer's own current docs; `checkOnSave.command` is the deprecated pre-0.11-API name
still floating around in older blog posts, and would silently no-op). No inlay-hint block
needed alongside it — rust-analyzer enables its own by default.

**Candidates found, not added** (from yutkat/Matt-FTW specifically): mini.icons (see above),
rustaceanvim, git-conflict.nvim, nvim-window-picker/stickybuf.nvim, guess-indent.nvim, neogen,
and smaller/lower-priority ones (nvim-bqf, satellite.nvim, eyeliner.nvim, hlargs.nvim,
modicator.nvim, colorful-winsep.nvim, hydra.nvim). Deliberately not flagged: edgy.nvim
(architecturally significant, not a granular add) and yutkat's other navigation/textobject
plugins (flash/mini.ai/textobjects.lua/harpoon already cover the same ground). Matt-FTW/
dotfiles turned out to be a thin LazyVim `extras` layer, not a from-scratch config.

Comment-hygiene pass: checked, nothing to change (no real TODO/FIXME cruft, all short
section-header comments deliberate, matching the 2026-08-17 entry's own documented style).

Testing: real Neovim v0.12.4 + real bootstrap (83/83 installed), 18-point suite (18/18),
independent keymap/augroup scans, `luac5.1 -p` clean across 73 files, fresh clones of all 7
named repos, rust-analyzer's own current docs fetched before the one settings change. Did not:
install `clippy` itself to confirm end-to-end (no Rust toolchain in this sandbox); exercise
yutkat's mini.icons shim; switch in any candidate (by design).

Check next time: any of the candidates above, if raised again specifically; `check.command =
"clippy"` assumes the rustup component is actually installed wherever rust_analyzer runs for
real — its absence surfaces as diagnostics quietly not populating, not a crash, so it wasn't
given a startup warning the way the DAP binaries were; worth a second look if that's ever
confusing in practice.

---

## 2026-08-17 (second session) — independent re-verification pass, `.typos.toml` added

## (condensed)

Independent re-verification of the entry below (same-day, same 13-point request re-sent) —
checked everything the way a first pass would rather than trusting the prior conclusions by
reference. `plugins/init.lua` missing (6th time, same cause/fix). Re-derived the keymap-collision
scan from scratch with a brace-matching parser: 202 distinct (mode, lhs) bindings, zero
collisions, confirming the prior finding independently. Deprecated-syntax sweep (`vim.loop.*`,
old `lspconfig.X.setup{}`, packer `use{}`, etc.) clean. Spot-checked `lspconfig.lua`/`utils.lua`/
`avante.lua`/`autocmds.lua` against their own previously-documented fixes: all still in place.
jdhao/nvim-config had squashed its git history since the last check (one 2026-08-14 commit
containing the whole config) — treated as a full fresh read rather than a small diff. One real
candidate surfaced: jdhao's new `typos_lsp` (LSP-based typo checking) — checked against `lint.lua`
first: already lints typos globally via nvim-lint's `typos` CLI integration, so adding `typos_lsp`
on top would double the same diagnostic through two mechanisms; not added. What _was_ missing: no
`.typos.toml` existed anywhere in this repo, so that same lint pass had been flagging this
config's own jargon (`augroup`, `mcphub`, `opencode`, `gopls`, `basedpyright`, etc.) as typos the
whole time — added `.typos.toml`, adapted from jdhao's structure but with this config's actual
vocabulary. Confirmed craftzdog's `cowboy()` (in `utils.lua`) is a genuine LazyVim-derived match,
not craftzdog's own invention — existing attribution was already correct. `rareitems/printer.nvim`
(ecosse3) and `nvim-hlslens`/`yanky.nvim` (rafi doesn't use either) noted as real, standalone
candidates, not added. craftzdog/xero/rafi: no commits since 2026-08-12/13. Tested: `luac5.1 -p`
across all 73 files, `.typos.toml` validated as parseable TOML; no `:Lazy sync` re-run needed (no
plugin/keymap/autocmd content changed this pass).

## 2026-08-17 — ecosse3/nvim (first look), 18 plugins added across two passes, real headless

## test with actual bootstrap (not just import-simulation), kitty.conf re-checked against the

## full new keymap set, autocmds/utils single-file-vs-folder question answered

Trigger: two messages in one sitting. First: the standard 13-point re-audit plus a first-ever
comparison against ecosse3/nvim (jdhao/craftzdog/xero/rafi were already covered as of
2026-08-12/13) and a direct question — separate autocmds/utils folders, or keep single files.
Second, after that pass proposed 14 ecosse3-sourced plugins as "recommended, not added": explicit
instruction to add all 14 anyway, "strictly...without any conflict." Verified against real
upstream source for every plugin touched, a real Neovim v0.12.4 binary, and — for the first time
in this log — a full real `:Lazy sync` (not the import-simulation prior entries relied on): all
83 plugins actually git-cloned, actually configured, checked programmatically via lazy.nvim's own
per-plugin error tracking rather than eyeballing `:messages`.

### 1. Two real bugs, found before any new plugin was considered

- `autocmds.lua`'s `auto_close_win` checked `{ "qf", "vista", "NvimTree", "neo-tree", "aerial" }`
  — `vista`/`NvimTree`/`aerial` correspond to zero plugins in this config (checked against all 65
  then-current `lazy-lock.json` entries programmatically). Dead filetype checks, presumably
  inherited from a template; trimmed to the two real ones.
- `config/lazy.lua` had a `pcall(require, "config.setup")` + `has_user_plugins` filesystem check
  — LazyVim-starter scaffolding for "plugins might not exist yet." No `config/setup.lua` exists
  anywhere in this tree and `lua/plugins/` always exists here, so both branches always resolved
  the same single way regardless of input. Removed; `spec = { { import = "plugins" } }` now
  stated directly.

### 2. ecosse3/nvim — first-ever look at this repo; craftzdog/rafi turned out to be moot

craftzdog/dotfiles-public and rafi/vim-config have both migrated to being LazyVim customization
layers rather than ground-up configs since this config last diffed against them — most of what
either would show now is LazyVim's own code, not either author's. Confirms the existing
narrow-credit approach (one specific pattern each, not their overall shape) was already the right
call. jdhao/nvim-config and ecosse3/nvim remain the two genuinely comparable from-scratch configs.

ecosse3/nvim: 1,624 commits, actively maintained, real README with a full keymap reference.
Extracted every plugin in its list, cross-checked against this config's own. Two added
immediately (low-risk, each closing a gap already visible in this config's own code):

- `plugins/lsp/inc-rename.lua` — confirmed in ecosse3's own plugin list. Overrides `grn` (not a
  new key) and flips `noice.lua`'s pre-existing `presets.inc_rename` from `false` ("use standard
  rename for now") to `true` — that comment was already a stub waiting for this.
- `plugins/editor/persistence.lua` — `options.lua` already trims `sessionoptions` for exactly
  this purpose but nothing called `:mksession` against it. Not literally ecosse3's own session
  plugin (unconfirmed which one backs their `<leader>p s*`) — an independent choice matching the
  folke/* ecosystem already heavily used here, prompted by noticing the gap while reading theirs.

The remaining 14 (grug-far, treesj, text-case, nvim-scissors, symbol-usage, gitlinker, dial,
multicursor, octo, yazi, boundary, template-string, tw-values, avante/opencode/mcphub) were
initially left as "recommended, not added" — several had real, concrete conflicts with this
config's existing keymaps (dial wants `<C-a>`/`<C-x>`, already "select all"; multicursor's
example uses `<up>/<down>/<c-q>/<leader>n/<leader>s/<leader>a/<leader>t`, all already taken;
avante's usual `<leader>a` is already parameter-swap) that seemed like they warranted the
person's own call rather than a unilateral decision. Explicit follow-up instruction overrode
that: added all 14, see §4.

### 3. `autocmds.lua`/`utils.lua`: single files, not folders — answered, not just deferred

Current sizes (538 / 339 lines) are still fully navigable as single files, and both already have
clear internal section headers (EDITING BEHAVIOR/FILE HANDLING/UI-DISPLAY/FILETYPE-SPECIFIC;
General/Git/LSP/Theming/Randomness/UI-misc) — a folder split would add `require()` indirection
without adding wayfinding these don't already have. The `plugins/` folder-per-category split
solves a different problem entirely: ~50 independent, parallel, same-shape plugin _specs_, not a
handful of internally-organized, sequentially-read files. Checked what the two genuinely-custom
reference configs do when _they_ split: jdhao splits `utils.lua` into sibling flat files
(`utils.lua` + `lsp_utils.lua`, by domain) rather than a folder; ecosse3 does the same
(`keymappings.lua`/`colorscheme.lua` as siblings under `config/`, no `config/keymappings/`
folder). If either file roughly doubles from here, that's the precedent to follow — sibling flat
files by domain, not a subfolder.

### 4. The other 14 — added, each keymapped from scratch against this config's own full surface

None of any plugin's own suggested/example keymaps survived unchanged; every one was checked
against every existing keymap in this tree first (leader groups, native-default reference boxes,
LSP-attach block, all of it) and moved on any real collision:

- **dial.nvim** — given no new keys at all. Wired directly onto the _existing_ `>`/`<`
  (mappings.lua's old plain-increment lines removed — leaving both would've been exactly the
  racing/redundant-binding issue point 1 of the original request warns about). Custom
  augends/groups deliberately left unconfigured: that specific API wasn't independently verified
  the way `dial.map.manipulate()` was, and the built-in "default" group already covers everything
  the old native-increment setup did, plus more, with zero risk of a malformed-config startup
  error. No `keys`-based lazy trigger either — its bare-string-trigger form isn't demonstrated
  anywhere else in this config and replay-on-first-press wasn't independently confirmed; loads
  eagerly instead (same choice as noice/notify/snacks), since `>`/`<` need to work on the very
  first press.
- **multicursor.nvim** — upstream's own example collides with window-resize, Quit, the No-yank/
  Search/Toggle/Test group prefixes, the parameter-swap keys, and native diagnostic-jump; not one
  upstream key survived. Full custom scheme under a new `<leader>m` group. `<left>`/`<right>`/
  `<esc>` reuse upstream's own suggestion safely via `mc.addKeymapLayer()` — those bindings only
  exist while 2+ cursors are already active, so outside multicursor mode the existing window-
  resize arrows and nohlsearch Esc are untouched; this is upstream's own documented mechanism for
  exactly this situation, not a workaround invented here.
- **avante.nvim** — `<leader>a` (its usual prefix) is already parameter-swap; new `<leader>i`
  "AI" group instead. Its `opts.mappings` sub-schema was not independently verified, so bound
  `<leader>ia`/`<leader>ie` directly to avante's confirmed top-level API (`.toggle()`/`.edit()`)
  instead of trusting an unverified `opts.mappings` shape.
  `utils.warn_if_missing_env()` (new, generalized sibling to `warn_if_missing_mason_bin()`) warns
  once for `ANTHROPIC_API_KEY` — confirmed firing correctly in testing (§6).
- **opencode.nvim — deliberate substitution.** ecosse3 itself uses `sudo-tee/opencode.nvim`,
  whose own README currently says "in early development... not recommended for production use
  yet." Used `NickvanDyke/opencode.nvim` instead (same underlying `opencode` CLI, no such
  warning) — installing something its own author flags as not production-ready isn't a "verified
  solution" regardless of what ecosse3 happens to use. Its own README example hands snacks.nvim
  `opts = { input = {}, picker = {}, terminal = {} }` — bare `{}` enables a module at defaults;
  `snacks.lua` already deliberately sets `input.enabled = false` / `picker.enabled = false`
  (routed through noice/telescope instead), and lazy.nvim merges every spec for the same plugin
  name. Copied verbatim, this would have silently re-enabled both against this config's own
  settled choice. Rewritten explicitly instead: input/picker stay off, only `terminal` (unclaimed
  by anything else here) is actually opted in.
- **mcphub.nvim** — feeds avante's tool-calling per its own docs. `npm install -g mcp-hub@latest`
  build step; Node is already a documented requirement here (Copilot, JS/TS servers), not new.
- **grug-far.nvim** — new `<leader>r` group; its own commonly-suggested `<leader>sr` is already
  this config's "Goto References" (telescope.lua's LspAttach block).
- **treesj** — nested in the existing Code group (`<leader>cj`) rather than a new single-item
  leader root.
- **text-case.nvim** — kept its own default `ga` prefix (overrides the rarely-used native `ga`,
  show-ascii-value — same trade already made for `gc`). `lazy = false`: its own issue tracker
  documents which-key names sometimes not registering under lazy-loading; confirmed in testing
  (§6) this registers a full 25+-entry keymap set correctly (lower/upper/Pascal/dash/snake/camel/
  CONSTANT case × quick-replace/LSP-rename/operator, plus the Telescope picker).
- **nvim-scissors** — needs VS-Code-format JSON snippets specifically (its own README);
  friendly-snippets (already blink.cmp's dependency) already ships in that exact format, so this
  extends rather than duplicates. `snippetDir` had to be the _same_ path blink.cmp's own snippets
  provider searches or new snippets would be invisible to completion — `blink.lua` updated to
  match (a real cross-file integration point, not just a standalone addition).
- **symbol-usage.nvim** — no keymap by design, same shape as colorizer.lua/rainbow-delimiters.lua
  (fully automatic virtual text).
- **gitlinker.nvim** — its own suggested `<leader>gy`/`<leader>gY` checked against the Git group
  and was actually free; kept as-is.
- **octo.nvim** — nested under the Git group (`<leader>go*`) since `<leader>o` is this config's
  Options group. Kept to stable `:Octo` ex-commands rather than internal Lua functions that
  weren't independently verified with the same confidence as the others. `gh` CLI checked via
  `utils.executable()`, same warn-once shape as everything else.
- **yazi.nvim** — its own README explicitly documents that its `open_for_directories` option
  replaces netrw for `nvim <dir>` — but oil.lua already claims exactly that role
  (`default_file_explorer = true`) and neo-tree.lua already disables netrw-hijacking in oil's
  favor. Left off on purpose (a real, upstream-documented collision this config's own settings
  would have created if copied as-is), keeping yazi purely on-demand (`<leader>ey`, new category
  member alongside neo-tree/oil).
- **boundary.nvim / template-string.nvim / tw-values.nvim** — new `plugins/frontend/` category
  (ft-gated to tsx/jsx/etc; genuinely narrow, unlike lang-tools/ which spans every language).
  `tw-values.nvim`'s own suggested `<leader>sv` was free but put in the Code group (`<leader>cv`)
  instead — better organizational fit than a 17th entry in the already-large Search group.

New categories required updating `plugins/init.lua` (13 → 15 import lines), `init.lua`'s own
file-layout tree/credits/feature-overview, and `README.md`'s layout tree — all three checked for
consistency with each other, not just individually correct.

### 5. kitty.conf — re-checked against the full new keymap set, still zero conflicts

Fresh upload; same content as the 2026-08-13 upload (confirmed via the "ctrl+w unbound, line 91"
cross-reference matching exactly), but the config's own keymap surface has grown by ~40 bindings
since that check, so re-verifying was real work, not a rubber stamp. Specifically checked what's
new: `<C-Up>`/`<C-Down>` (multicursor) against kitty's `ctrl+shift+up/down` (different modifier,
no collision) and its `alt+1..9` tab-switch (different keys entirely); `<C-LeftMouse>` etc.
against kitty's mouse handling (no `mouse_map` entries exist in this file at all, mouse passes
through natively). No new binding introduced this pass uses `alt+<digit>`, bare `ctrl+t`, or any
`ctrl+shift+*` combination — the only three kitty claims. Same two-keyspace separation holds.

### 6. Testing this pass actually did

The first entry in this log with a genuine, complete `:Lazy sync` rather than import-simulation:

- **Downloaded a real Neovim v0.12.4 binary** (matching the version every prior entry's own
  testing used) and ran a full headless `Lazy! sync` against this exact tree in an isolated XDG
  environment. **All 83 plugins** (65 previously-locked + inc-rename + persistence + the 14 from
  §4) **git-cloned and checked out successfully** — zero clone failures, zero checkout failures.
- **One real build failure, investigated to a specific root cause, not just noted**:
  avante.nvim's `make` step failed (`Makefile:52: luajit`). Read its actual `build.sh`: it tries
  a prebuilt-binary download via `api.github.com` first (an allowed domain here) and falls back
  to `cargo build` only if that doesn't resolve — this sandbox has no `cargo`/`rustc` binary
  installed at all, which is almost certainly the proximate cause. **Confirmed directly, not
  assumed, that this doesn't break the plugin**: forced avante's real load path
  (`require("lazy").load({ plugins = { "avante.nvim" } })`, the same mechanism its `VeryLazy`
  trigger uses) and its `config()` — this config's own specific `opts` table, not a generic
  smoke test — ran with zero errors. Flagged for the person to check `cargo`/rustc availability
  on their own machine; the sandbox's specific failure reason may or may not apply there.
- **`utils.warn_if_missing_env()` (new this pass) confirmed firing correctly**:
  `ANTHROPIC_API_KEY not set — avante.nvim will prompt for it or fail on first use.` appeared
  exactly once, at the right time, with the right message — the same "check once, clear message"
  pattern as every other external-prerequisite check in this config, now independently confirmed
  working for the env-var case it was written for.
- **Every plugin checked via lazy.nvim's own internal per-plugin error tracking**
  (`require("lazy.core.config").plugins`, each entry's `_.loaded.error` field) rather than
  eyeballing `:messages` for anything that scrolled past — zero plugins reported a load error.
- **Keymap ground-truth, not assumption**: initial programmatic checks (`nvim_get_keymap`) for
  two new bindings (`<`, `ga`) came back as "not found" — investigated rather than either trusted
  or dismissed. Both were false alarms in the _test script_, not the config: `:map <` confirmed
  `dial.lua`'s binding is real and correctly registered (the literal `<` character apparently
  doesn't round-trip through `nvim_get_keymap` the same way other keys do); `:map ga` confirmed
  text-case.nvim registered its full real keymap set (`ga` itself was never meant to be a
  standalone binding, only a prefix — the test's own expectation was wrong, not the config).
- **Real files opened**: `.py`, `.lua`, `.js`, and (new) `.tsx` — the last specifically to
  exercise `plugins/frontend/`'s ft-gating; `boundary.nvim`/`template-string.nvim`/`tw-values.nvim`
  all loaded and `:TWValues`/`:BoundaryRefresh` both confirmed registered and callable.
- **All three colorscheme families switched live** (tokyonight/catppuccin/kanagawa) — no errors.
- **`lazy-lock.json` regenerated from this real install** rather than hand-edited: 65 → 83
  entries, diffed programmatically against the prior lockfile to confirm the only changes are
  the 18 additions (inc-rename, persistence, and the 16 from §4) — zero unexpected removals or
  changes to any pre-existing entry's pinned commit.
- **`luac5.1 -p` across all 73 `.lua` files** (LuaJIT/5.1 semantics) after every single edit this
  pass, not just once at the end — caught one real mistake this way before it shipped (see
  "Check next time").
- **Did not**: test with a real `ANTHROPIC_API_KEY` or authenticated `gh` CLI (avante's actual
  model calls and octo's actual GitHub calls are therefore unverified beyond "loads without
  error"), confirm `cargo`/rustc availability on the person's own machine, or test any real
  interactive UI behavior (which-key popup rendering, multicursor's on-screen cursors, snacks
  UI) — headless testing structurally can't reach any of these.

### Check next time

- If avante.nvim's native extension matters (faster template rendering — the plugin functions
  without it, confirmed above): check `cargo`/rustc are on `$PATH` on the real machine, or
  `:Lazy build avante.nvim` again once they are.
- `plugins/lsp/octo.lua` was kept to ex-commands rather than internal Lua API calls specifically
  because those weren't independently verified with the same confidence as this pass's other
  additions — if a future pass wants to expose more of octo's own functionality (review
  threads, inline comments), verify the real current Lua API surface first rather than guess.
- `dial.nvim`'s custom-augends API (per-filetype groups, additional augend types) was
  deliberately left unconfigured this pass — the built-in default group covers real, current
  needs, but if a specific augend is ever wanted (e.g. markdown heading-level cycling), verify
  `:h dial-config`'s exact current shape before writing it, the way this pass did for
  `dial.map.manipulate()` but explicitly declined to do for the augends-registration API.
- Caught and fixed before shipping, not left as a lesson for later: an early draft of
  `lspconfig.lua`'s `grn` override briefly had two competing `keymap.set` calls for the same key
  (one via the file's own `map()` helper, which doesn't support `expr = true`, plus a second raw
  call to actually get `expr` — functionally fine since the second wins, but genuinely redundant,
  caught by re-reading the diff before moving on rather than by a later audit pass).

---

## 2026-08-13 — folder structure realized, `plugins/init.lua` missing (5th time), kitty.conf

## re-check, vim.uv cleanup, bufferline/Tokyonight Day screenshot, log condensed

Trigger: a full re-audit against all 13 original request points (compatibility/redundancy,
verified-only improvements, EOL-comment discipline, this log's own upkeep, up-to-date syntax,
utils.lua attribution, native-keymap conflicts + which-key groupings, header accuracy, "999rpm"
branding, dependency reduction, file structure, kitty.conf, and testing) — plus a screenshot of
the bufferline under Tokyonight Day and a fresh kitty.conf upload.

### 1. `lua/plugins/init.lua` missing again — same cause, now realized as real nested files too

Absent again, for the same reason logged four times before: the project-knowledge upload
flattens this file and the root `init.lua` into one name and keeps only one. Reconstructed with
the same 13 `{ import = "plugins.<category>" }` lines as every prior reconstruction, plus a
permanent note inside the file itself (again — see that file if it goes missing a 6th time).

New this pass: every other file was also missing its real nesting (`lua/config/*.lua`,
`lua/plugins/<category>/*.lua`) for the same flattening reason — the _content_ already assumed
that structure throughout (every cross-file comment already said `plugins/lsp/lspconfig.lua`
etc.), it just wasn't laid out that way in what this pass received. Realized the actual
directory tree for the first time as part of this delivery rather than continuing to hand back
a flat file list — see "Suggested file structure" below; this isn't a new structure, it's the
one `init.lua`'s own header and every cross-file comment already described.

### 2. `vim.loop` → `vim.uv`

Confirmed against Neovim's own `:help deprecated` (`vim.loop` deprecated in favor of `vim.uv`)
and separately confirmed kitty's real default keybindings don't factor in here at all — this is
a Lua-API question, not a keybinding one. Three inconsistent forms existed side by side:
`harpoon.lua` (`fs_realpath`, ×2) and `oil.lua` (`fs_stat`, ×1) called `vim.loop` directly;
`utils.lua` and `config/lazy.lua` defensively used `vim.uv or vim.loop`; `utils.lua`'s own
`cowboy()` already called plain `vim.uv`. Since `README.md` hard-requires Neovim 0.12+ (needed
by nvim-treesitter's `main` branch) and `vim.uv` has existed since 0.10, the `or vim.loop`
fallback was unreachable dead code, not real defensiveness. Standardized on plain `vim.uv`
everywhere — matches the newest syntax and removes the inconsistency in one direction rather
than the other.

### 3. `utils.lua`'s "used by" attribution comments — standardized to bare filenames

Every filename in this tree is unique (checked programmatically — the only repeat is `init.lua`
itself, root vs. `plugins/`, never referenced by name in `utils.lua`), so a bare filename is
unambiguous. `utils.lua`'s own attribution comments were inconsistent about this: some already
said e.g. `lspconfig.lua`, others said `plugins/lsp/lspconfig.lua`, one said `config/mappings.lua`
next to a plain `options.lua` two lines above. Standardized every one to the bare form — also the
literal wording the request asked for ("this util is used by `{plugin name}.lua`"). Found the
same inconsistency in prose comments _outside_ `utils.lua` (`flash.lua`, `dap.lua`, `snacks.lua`,
`toggleterm.lua`, and two spots in `init.lua`'s own header used `config/mappings.lua`-style
paths while ~25 other cross-references across the tree used the bare form) — fixed all of them
to bare for the same reason. Left alone on purpose: `init.lua`'s file-layout tree diagram and
`plugins/init.lua`'s own header, where a qualified path is the tree itself, not a cross-reference
to it — collapsing those to bare names would make the structure documentation less clear, not
more consistent.

### 4. Bufferline under Tokyonight Day — confirmed correct, not a bug

The screenshot this pass received is exactly the moment the _previous_ entry's own "check next
time" note anticipated ("swap the link target if it doesn't suit a given theme once seen live").
Zoomed into the raw pixels (not just the small thumbnail) rather than guessing from a low-res
read: what looks like a hatched/diagonal texture at a glance is two clean, correctly-rendered
triangular wedges per tab boundary — exactly how bufferline's `"slope"` separator style is
supposed to look, using two adjacent glyphs to fake a continuous slanted cut. The blue wedges are
`separator_selected` (linked to `Function`, blue in Tokyonight); the gray ones are
`separator`/`separator_visible` (linked to `Comment`, gray) — precisely what the prior pass's own
`highlights` block sets. Cross-checked against bufferline.nvim's real source
(`lua/bufferline/config.lua`) and tokyonight.nvim's own bufferline integration (which only sets
`BufferLineIndicatorSelected`, confirming `fill`/`background` are meant to come from bufferline's
own `Normal`/`Comment`/`TabLineSel` derivation, not a hardcoded per-theme override) before
concluding this. No change made — reconfirmed working as designed, not re-litigated without a
concrete complaint. If a similar mismatched-wedge look shows up under a _different_ style
(Catppuccin/Kanagawa, or a non-Day Tokyonight variant), that's the concrete trigger to add an
explicit `highlights.fill = { link = "TabLineFill" }` — not done speculatively here since the one
style this pass has direct evidence for already renders cleanly.

### 5. kitty.conf — re-checked against a fresh upload, no conflicts, confirmed two ways

Independently re-verified rather than just trusting the prior entry's finding: kitty's own
defaults (confirmed via its real docs) exclusively use `ctrl+shift+*`, `ctrl+shift+alt+*`, and
`ctrl+shift+<Fkey>` — by design, specifically so they never collide with a terminal application's
own `ctrl+<key>`/`alt+<key>` shortcuts. Extracted every keymap LHS across all 55 `.lua` files
programmatically and confirmed zero `<C-S-*>` or `<M-[0-9]>` bindings exist anywhere in this
config — the two keyspaces (kitty's explicit + default bindings vs. this config's bare-Ctrl/
bare-Alt/function-key/leader-sequence bindings) don't overlap at all. `ctrl+w` is confirmed
unbound in the actual uploaded file (line 91's own comment says so), matching the previous
entry's finding independently rather than by reference. `font_family Lilex Nerd Font` in the
same file also confirms `options.lua`'s `g.have_nerd_font = true` assumption is correct for this
setup.

### 6. Fresh compatibility/redundancy/keymap-collision sweep — nothing new found

Extracted every `vim.keymap.set`/local-`map`/`keys`-table entry across the whole tree
programmatically (not by eye) and checked for LHS collisions. Three same-LHS matches came back,
all pre-existing and already correctly scoped: `<C-s>` (mode-scoped three ways — normal/save,
insert/signature-help, cmdline/flash-toggle — keymaps are mode-namespaced, not colliding);
bare `q` (global no-op vs. buffer-local close-window in utility filetypes, buffer-local correctly
wins); nothing else. Checked plugin-spec ownership too (which file's `config`/`opts` "owns" a
given plugin vs. just listing it in a `dependencies` table) — no plugin has conflicting config in
two different files. Re-verified two cross-file consistency claims programmatically rather than
re-reading by eye: `lspconfig.lua`'s `servers` table vs. `mason.lua`'s `ensure_installed` (18/18
exact match, both directions) and every `conform.lua` formatter that needs an external binary is
present in `mason-tool-installer`'s list. Checked for duplicate `999rpm-*` augroup names: none
(36 unique). No `.lua` file references a plugin this config no longer installs.

### 7. `which-key.lua` groupings — reviewed fresh, kept as is

Re-derived every `<leader>*` prefix and its real child count directly from the keymap extraction
in §6 (not by re-reading the file's own spec table and trusting it matches reality) — every
group with 2+ children already has an accurate, current entry; nothing stale, nothing missing.
One borderline case considered: `<leader>u` ("UI") currently has exactly one real child
(`<leader>um`, from `render-markdown.lua`), one short of the file's own stated "2+ children"
threshold. Considered moving `<leader>on`/`<leader>or`/`<leader>ow` (line-number/wrap toggles,
currently under the 11-child `<leader>o` "Options" group) into `<leader>u` to both slim down the
largest group and give `<leader>u`'s label real justification — declined: that's an actual
keybinding relocation living in `mappings.lua`, not a `which-key.lua` grouping change, and doing
it risks the still-forming muscle memory the person mentioned. Left `<leader>u`'s single-item
group as a reasonable, forward-looking exception rather than manufacturing a change for its own
sake.

### 8. "999rpm" branding and dependency architecture — reconfirmed, not re-changed

Both re-checked against this pass's own full read of every file (not assumed from the prior
entry's conclusion): every custom augroup already carries the `999rpm-` prefix via
`utils.augroup()` (37 call sites → 36 unique names, one file registers two groups off one call
site's helper), and `themes.lua`'s local theme-switcher spec is still the only other explicit
use, matching the prior pass's own conclusion that this is already comprehensive without forcing
the name into decorative spots (dashboard, window title) that wouldn't add function. Likewise,
`plugins/deps/` (`web-devicons.lua`, `shared.lua` for plenary/nui) is still the right shape for
every genuinely multi-consumer, nothing-of-its-own-to-configure plugin — nothing found this pass
that's newly coupled and should split out, nothing in `deps/` that's grown a second concern.

### 9. Suggested file structure

Not a new suggestion — realizing, as real nested files for the first time in a delivery from
this chat, the structure `init.lua`'s own header and every cross-file comment already assumed:

```
init.lua
lua/
├── utils.lua
├── config/            options.lua · autocmds.lua · mappings.lua · lazy.lua
└── plugins/
    ├── init.lua        imports every folder below — see its own header if this goes missing
    ├── lsp/            lspconfig · mason · lazydev
    ├── completion/     blink · copilot · autopairs
    ├── editor/         flash · harpoon · surround · comment · textobjects · better-escape ·
    │                   ts-autotag · mini · todo-comments
    ├── treesitter/     treesitter · context · rainbow-delimiters
    ├── ui/             alpha · bufferline · lualine · noice · notify · themes · which-key ·
    │                   statuscol · ufo · snacks · render-markdown · trouble · colorizer ·
    │                   bufdelete
    ├── git/            gitsigns · diffview
    ├── explorer/       neo-tree · oil
    ├── search/         telescope · fzf
    ├── debug/          dap · dap-ui · dap-python · dap-virtual-text
    ├── test/           neotest
    ├── lang-tools/     conform · lint
    ├── terminal/       toggleterm
    └── deps/           web-devicons · shared
```

This is already sound (matches every prior pass's own conclusion after the same question) —
category-per-folder, one plugin per file, shared/unconfigured dependencies centralized. No
restructuring applied; the only actual change here is that this delivery finally _is_ laid out
this way on disk, rather than describing it while handing back a flat directory.

### 10. This log condensed

The three entries below this one (two dated 2026-08-12, one dated 2026-08-13) carried a lot of
in-the-moment investigation narrative — which control was checked first, which source file was
re-read to confirm a claim, etc. Condensed each to conclusions + the reasoning a future change
actually needs, per this file's own stated purpose; nothing that changes present-day behavior
was dropped, and every "Check next time" item survived the condensing. The 2026-08-13 "README
tone" entry and everything from 2026-08-06 back were already short and are untouched.

### Testing this pass actually did

This pass had access to a real Neovim binary and outbound network access to GitHub, which no
entry in this log below recorded having — so testing went further than "did not attempt a full
bootstrap," the caveat every prior entry carries:

- **A real, full `lazy.nvim` bootstrap against this exact repo tree**, headless, under a
  downloaded Neovim **v0.12.4** binary: `init.lua` -> all four `config/*.lua` ->
  `plugins/init.lua` -> all 13 category imports -> all 48 leaf plugin spec files, end to end, no
  mocking. Exit code 0, zero Lua tracebacks. **All 65 plugins git-cloned and installed
  successfully** — an exact match against `lazy-lock.json`'s 65 entries, confirming §1's
  `plugins/init.lua` reconstruction resolves correctly in practice, not just in the
  `lsmod`/import-simulation sense prior entries verified.
- **Real files opened in the running session**: a `.py`, a `.lua`, and a `.js` file, each
  triggering their respective `BufReadPost`/`FileType` autocmds, treesitter attach attempts, and
  LSP-attach attempts — no errors.
- **All three colorscheme families switched live** (`colorscheme tokyonight` / `catppuccin` /
  `kanagawa`) in the same session — no errors from any of the three.
- **Core UI modules required directly and confirmed loadable**: `bufferline`, `which-key`,
  `lualine`, `telescope`, `neo-tree`, `utils` (19 exported members, confirmed by count).
- **The failure-handling paths this pass didn't otherwise touch, confirmed firing correctly
  rather than assumed correct from reading the source**: `utils.warn_if_missing_mason_bin()`
  printed its intended message for all four DAP binaries (none installed yet in this sandbox),
  `external_servers`' executable-gate warned for `gopls` (absent) without attempting to start
  it, and `treesitter.lua`'s `tree-sitter` CLI check warned once, cleanly, instead of failing
  per-parser. Zero _unexpected_ messages appeared in `:messages` across the whole session —
  every warning present was one of these four, by design.
- Also ran, matching prior entries' own standard: `luac5.1 -p` across all 55 `.lua` files after
  every edit (LuaJIT/5.1 semantics, matching what Neovim actually embeds); the programmatic
  (not by-eye) checks from §6-§8 (keymap collision scan, `servers`/`ensure_installed` set
  equality, `conform`/`mason-tool-installer` coverage, duplicate-augroup scan, filename-
  uniqueness scan); real upstream source fetched fresh for bufferline.nvim, tokyonight.nvim,
  Neovim's own `:help deprecated`, and kitty's documented defaults (§2, §4, §5).
- **Did not** wait out a full Mason tool-install cycle (attempted installing `debugpy` for real
  via `mason-registry`'s own API — the registry-refresh step alone outran what's practical to
  hold open here). That tests PyPI/network latency more than this config; the code path it would
  confirm is already independently verified twice over — once by re-deriving Mason's own
  `pypi.lua` `venv_path()` logic against this file's hardcoded path (an existing check from the
  entry below), and once dynamically, by confirming `warn_if_missing_mason_bin()` correctly
  detects the binary's current absence and says so.
- One artifact of this pass's own testing, not a config bug: `copilot.lua`'s background Node
  language-server process outlived a couple of quick headless sessions and had to be killed
  manually — expected, since a real interactive Neovim session (not a script that opens and
  immediately `:qa`'s) would hold that process for its actual lifetime and it would exit with
  the parent normally.

### Check next time

- If `lua/plugins/init.lua` is missing yet again on a future delivery from this chat: same
  cause, same fix — see that file's own header before re-deriving the diagnosis from scratch.
- If bufferline's separator wedges show a visible seam under Catppuccin, Kanagawa, or a
  Tokyonight style other than Day: that's the trigger for an explicit
  `highlights.fill = { link = "TabLineFill" }` in `bufferline.lua` — not added speculatively
  this pass since Day is the only style with direct screenshot evidence (§4).
- `<leader>u`'s single-child "UI" group (§7) is a deliberate, minor exception to this file's own
  "2+ children" rule for which-key entries — not an oversight if it's ever questioned again.

---

## 2026-08-13 — icon corruption across 10 files, kitty.conf cross-check, reference-config

## re-comparison, DAP tutorial, snacks/rainbow integration, Mason-binary warnings (condensed)

Full re-audit against the folder-per-category layout plus an uploaded kitty.conf. Verified
against real, current upstream source for every plugin touched (noice.nvim, flash.nvim,
copilot.lua, blink.cmp, nvim-dap-ui, trouble.nvim, nvim-notify, todo-comments.nvim,
neo-tree.nvim, render-markdown.nvim, bufferline.nvim, snacks.nvim, lazy.nvim, mason.nvim,
mason-registry, mason-nvim-dap.nvim, nvim-dap-python) plus a real Neovim v0.12.4 tree.

- **Icon corruption, byte-verified**: ~65 empty glyph fields across `dap.lua`, `dap-ui.lua`,
  `neo-tree.lua`, `notify.lua`, `todo-comments.lua`, `bufferline.lua`, `config/lazy.lua`,
  `lualine.lua`, `trouble.lua`, `render-markdown.lua` — each replacement pulled from that
  plugin's own current upstream default, not invented. Root mechanism never conclusively
  identified. Two **not** bugs, confirmed and left alone: `ufo.lua`'s `ft_providers` empty
  string is a real "skip this filetype" API value; `todo-comments.lua`'s `highlight.before = ""`
  is a valid enum member.
- `trouble.lua`: removed `use_diagnostic_signs` and `icons.kinds.Error/Warn/Hint/Info` — neither
  exists in current trouble.nvim; it reads severity icons from
  `vim.diagnostic.config().signs.text` directly (i.e. `lspconfig.lua`'s signs, already correct).
- K's hover had no border: `noice.lua`'s `lsp.hover.enabled = true` means Noice's own hover view
  renders on `K`, not `lspconfig.lua`'s `vim.lsp.buf.hover()` border arg. Fixed via
  `presets.lsp_doc_border = true`.
- `<C-w>}`/`<leader>xf`: both confirmed working as intended, not bugs — documented rather than
  changed (native tag-preview command + `winminheight = 1` shrinking a terminal split reads as
  "closing" it but isn't; `xf` is a deliberate `<C-w>d` alias for group consistency).
- DAP breakpoint signs were invisible (icon bug above) **and** uncoloured (no highlight groups
  existed at all) — fixed together with `set_dap_highlights()` linked to `Diagnostic*` groups
  plus a `ColorScheme` autocmd to re-apply them. Added `utils.warn_if_missing_mason_bin()` for a
  clear startup warning instead of a raw ENOENT mid-session; wired into all four Mason-managed
  DAP binaries. Added a boxed tutorial to the top of `dap.lua`.
- Copilot: config confirmed not at fault; real requirement is Node.js **v22+** specifically
  (older LTS fails silently, no error) — added a version-aware startup check.
- flash.nvim's `<C-/>` changed to `<C-s>`, matching upstream's own tested default (`<C-/>` and
  `<C-_>` are frequently indistinguishable at the raw keycode level depending on terminal/OS).
- `lua/plugins/init.lua` missing (3rd occurrence) — reconstructed; a permanent note was added
  inside the file to explain the recurring cause (though see this pass's own §1 above — the note
  doesn't survive the same flattening that removes the file it lives in).
- Reference-config re-comparison (jdhao/nvim-config, craftzdog/dotfiles-public, xero/dotfiles,
  rafi/vim-config): nothing new to adopt, re-confirmed rather than re-asserted from memory.
- Smaller: `config/lazy.lua`'s dead `icons.git` removed; `bufferline.lua` gained explicit
  `separator_selected`/`separator`/`separator_visible` highlights (linked to `Function`/
  `Comment`); `snacks.lua`'s indent guide colors linked to `utils.rainbow_delimiter_groups`
  (shared with `rainbow-delimiters.lua`, one rainbow source instead of two); which-key's
  `<leader>n` label updated to cover its actual (broader-than-registers) contents.

## 2026-08-13 — README.md tone and credits

Rewrote README.md's prose (requirements/install/license) in flatter, more neutral language and
removed its "Credit where it's due" section per request — the more detailed, per-pattern
attributions in `init.lua`'s header and individual file headers serve a different,
technical-maintenance purpose and weren't touched. No code changed.

---

## 2026-08-12 — tree-sitter CLI errors, sharp-to-rounded corners, keymap-vs-builtin conflicts,

## dependency architecture, fold-column rework (condensed)

Follow-up pass; verified against real upstream source (nvim-treesitter `main`, noice.nvim,
bufferline.nvim, mason-registry, mason-lspconfig.nvim, statuscol.nvim, snacks.nvim, lazy.nvim)
plus Neovim's real bundled `$VIMRUNTIME` v0.12.4, and lazy.nvim's actual `Spec.new()` resolver
run end to end against this config's real tree.

- nvim-treesitter's `main` branch genuinely requires the standalone `tree-sitter` CLI
  (`install.lua` shells out to it unconditionally, no C-compiler fallback) — added
  `"tree-sitter-cli"` to `mason.lua`'s `ensure_installed` (self-healing after first sync) and
  gated `treesitter.lua`'s `ts.install()` call behind an `executable()` check with a single
  clear warning instead of ~25 stacked ENOENTs.
- `:Noice history` going quiet was confirmation the ufo fix (below) worked, not a regression —
  routing only affects live display; the persistent history table records everything either way.
- Sharp→rounded box-drawing corners: `snacks.lua`'s indent chunk box, `lspconfig.lua`'s keymap
  reference box, `neo-tree.lua`'s last-indent-marker, `trouble.lua`'s indent icons. Left alone on
  purpose: `options.lua`'s window-split fillchars (T-junctions/crosses have no rounded
  equivalent) and `gitsigns.lua`'s signs (plain vertical lines, no corners involved).
- `float-backdrop.lua` (added in the entry below) removed — not worth its complexity on
  reflection, per explicit instruction.
- `bufferline.lua`/`lualine.lua`: comments corrected, values confirmed already correct and left
  untouched per explicit instruction — the live `separator_style` was already `"slope"` (comment
  said stale `"slant"`); `lualine.lua`'s Powerline separators were verified as real non-empty
  U+E0BA–E0BC codepoints via a person-supplied screenshot after this pass initially misread them
  as empty strings from plain-text tool output — a lesson in checking raw bytes before asserting
  "empty," not a file bug.
- `lua/plugins/init.lua` missing (2nd occurrence) — same cause/fix as every other occurrence.
- Keymap-vs-native-builtin conflicts resolved in favor of the builtin: `textobjects.lua`'s
  `]a`/`[a` (shadowed native `:next`/`:previous`) moved to `],`/`[,`; `todo-comments.lua`'s
  `]t`/`[t` (shadowed native `:tprevious`/`:tnext`) moved to `]n`/`[n`. `comment.lua`'s `gc`/`gcc`
  intentionally keep overriding Neovim's own native 0.10+ equivalents (adds block comments +
  treesitter-aware commentstring across embedded languages — real gaps in the native version).
  Added a native-defaults reference box to `config/mappings.lua`.
- Dependency architecture: created `plugins/deps/` for genuinely shared, nothing-to-configure
  plugins — `web-devicons.lua` relocated there, `shared.lua` added for `plenary.nvim`/`nui.nvim`
  (5 and 2 consumers respectively). `promise-async` deliberately left inline in `ufo.lua`
  (single consumer, nothing to centralize).
- `foldcolumn` narrowed from `"auto:4"` to `"1"`: `statuscol.nvim`'s `builtin.foldfunc` stacks one
  glyph per level up to the column _width_ — a wide column is the actual nesting cap, not a
  feature. At width 1 the per-line check is depth-independent (a fold starting 12 levels deep
  gets its glyph exactly like one at level 2); the "see every level you're inside" job is already
  covered with no cap by `snacks.indent`'s guides. `foldnestmax` removed as confirmed dead code
  (only applies to `foldmethod=indent`/`syntax`; this config uses `manual`).
- Smaller: `mason.lua` gained `gofumpt`/`tree-sitter-cli`, dropped dead `selene`/`luacheck`
  (wired into nothing); orphaned `lazy-lock.json` entry removed.

## 2026-08-12 — reference-config comparison, Haskell support, indent guides, fold-arrow nesting,

## dimmed backdrop (condensed)

Trigger: comparison against jdhao/nvim-config, craftzdog/dotfiles-public, xero/dotfiles,
rafi/vim-config (focus on `lspconfig.lua`), plus five concrete reports. Verified against real
upstream source (lazy.nvim, nvim-ufo, nvim-treesitter, nvim-lspconfig, statuscol.nvim,
snacks.nvim, mfussenegger/nvim-dap's wiki, bufferline.nvim, hlchunk.nvim).

- `lua/plugins/init.lua` missing (1st occurrence, diagnosed here for the first time) — the root
  `init.lua`/`plugins/init.lua` filename collision in project-knowledge sync. Reconstructed;
  proved the fix under a real Neovim 0.12.4 binary by simulating lazy.nvim's actual recursive
  import-expansion logic end to end.
- `nvim-ufo`'s `UfoFallbackException` spam: `provider_selector`'s fallback slot held
  `'treesitter'`, which can itself throw — only `'indent'` is a safe unconditional fallback per
  nvim-ufo's own docs. Fixed with its documented `lsp -> treesitter -> indent` chained-catch
  pattern (`customize_selector`). Compounding cause: `ensure_installed` never actually called
  `.install()` (see below), so any never-manually-installed parser made the treesitter provider
  fail on every fold request for that filetype.
- Fold arrows not nesting: the _previous_ pass's `foldcolumn` narrowing to `"1"` (see 2026-08-06
  below) made nesting display impossible outright, not just capped — temporarily widened to
  `"auto:4"` (later superseded by the entry above's more complete fix).
- JS/TS: no diagnostics, no ufo arrows outside a git repo — `ts_ls`/`tailwindcss` had
  `root_pattern(".git")` + `single_file_support = false` overrides that actively regressed
  nvim-lspconfig's own current default (which already falls back to cwd) — removed. Compounding
  cause: the `javascript` treesitter parser may never have been installed (see below).
- `nvim-treesitter`'s `ensure_installed` was commented out believing it caused install noise —
  confirmed false (`install_lang()` is a genuine no-op for anything already installed) —
  uncommented; added `"haskell"`.
- Full Haskell support closed out: treesitter parser added; `dap.adapters.haskell`/
  `dap.configurations.haskell` wired up (the Mason-installed binary sat unused before this);
  `hls` settings gained matching `ormolu`/`cabal-fmt` formatting providers. `hls` deliberately
  stays external/`ghcup`-installed rather than Mason-managed — Mason's package has a history of
  GHC-version mismatches.
- `bufferline.lua`'s `separator_style` corrected to a real option value; `lualine.lua`'s
  separators (genuinely empty at the time) set to real Powerline glyphs.
- Indent guides: researched ibl/snacks.indent/mini.indentscope/hlchunk.nvim — none draws a
  permanent whole-buffer tree; `snacks.indent`'s `chunk` mode draws a real box, but only around
  the _current_ scope. Switched from indent-blankline to `snacks.indent` (`chunk` + `animate` on)
  after user feedback that ibl's rainbow coloring read as noise — colour-linked to
  `rainbow-delimiters.lua`'s own groups via `utils.rainbow_delimiter_groups` so brackets and
  indent levels share one color source instead of two competing rainbows.
- Added then later removed `float-backdrop.lua` (dimmed backdrop behind floats) — see the entry
  above for the removal.
- Moved every file's dated change-history out of its own header and into this log, so file
  headers describe current behavior only.

---

## 2026-08-06 — config-wide audit (condensed)

Full file-by-file read, cross-checked against fresh clones of all four reference configs. Real
bugs found and fixed: `options.lua`'s `shell = "nushell"` pointed at a nonexistent binary (real
name `nu`) — every terminal session failed to spawn; `foldcolumn` narrowed `"4"` → `"1"` (later
revisited, see 2026-08-12 above); `ufo.lua`'s `provider_selector` didn't match its own comment;
`lspconfig.lua` and `conform.lua` both independently ran format-on-save (removed lspconfig's
copy, conform is sole owner); `bufferline.lua` had a dead `_G.TokyoColors()` reference;
`lualine.lua` had a hand-rolled venv lookup duplicating `utils.get_virtual_env()`.

Keymap conflicts resolved in favor of Neovim's own built-ins: `trouble.lua`'s `[d`/`]d` removed
(shadowed native diagnostic-jump); `textobjects.lua`'s parameter swap moved off `]p`/`[p` (native
indent-paste) to `<leader>a`/`<leader>A`, class navigation moved off `]c`/`[c`/`]C`/`[C` (native
diff-mode nav) to `]m`/`[m`/`]M`/`[M`, freeing `]c`/`[c` for `gitsigns.lua`'s hunk nav.

Replaced with standalone plugins: `mini.bufremove` → `bufdelete.nvim`, `mini.hipatterns` →
`nvim-colorizer.lua`, `indent-blankline.nvim` → later `snacks.indent` (see 2026-08-12 above).
`mini.ai` kept (no equally-capable standalone alternative).

New: a right-click context menu (`autocmds.lua`'s `MenuPopup` block), adapted from
rafi/vim-config. Structural: `plugins/` grouped into category folders instead of one flat
~50-file directory (the claim this needed no `lazy.lua` change was wrong — see `plugins/init.lua`
and the 2026-08-12 entry above). Every custom augroup routed through `utils.augroup()`.

---

## Earlier passes (2026-07-31 and before)

Audited every option in `options.lua` against then-current Nvim docs/behavior for stale comments
and silent conflicts (statuscolumn's relativenumber awareness, the shada/viminfo rename,
`winborder` set twice, the mouse-mode comment, a stray duplicate `mdx` treesitter-register line).
All resolved; not re-narrated in detail here since nothing from this window is still open.
