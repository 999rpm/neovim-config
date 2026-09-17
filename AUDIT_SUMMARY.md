# Config log

What changed, and the reason it changed. Newest first. Older passes are condensed to their
conclusions once a later pass has confirmed them.

## 2026-09-18 (fifth pass) — ten reported problems fixed, pickers and tabline consolidated

Ten problems were reported against the fourth-pass tree. Each one below records the symptom, what
actually caused it, and how it was verified. Verification ran on Neovim 0.12.5 with every plugin
installed, headless, 31 assertions.

### 1. A terminal folder for a snacks module

`plugins/terminal/terminal.lua` was a second spec for snacks.nvim that existed only to hold the
terminal options. Merged into `plugins/core/snacks.lua`; the `terminal/` category and its loader
entry are gone.

### 2. Every terminal key opening the same layout

`Snacks.terminal` identifies a terminal by command, working directory, environment and count, and
not by window position (`lua/snacks/terminal.lua`, `M.tid`). All three mappings passed no command,
so all three resolved to the same terminal and inherited whichever layout opened first. Each layout
now passes `env = { NVIM_999RPM_TERM = <layout> }`, which makes the ids distinct while leaving count
prefixes working. Verified: three toggles produce three terminals, one float and two splits.

`<C-\>` also had to go: mapping it in terminal mode shadows the built-in `<C-\><C-n>` that leaves
terminal mode. The float toggle is `<C-,>`, free in both Neovim and kitty.

### 3. Alt+W/A/S/D dead in terminals

Those keys existed in normal mode only. The `TermOpen` autocmd mapped `<C-h/j/k/l>` instead, which
also swallowed zsh's backspace, accept-line and clear-screen. Terminal-mode `<M-w/a/s/d>` now run
`wincmd` from split terminals and pass the key through in floating windows, so lazygit and yazi keep
receiving them. `.zshrc` runs vi mode and binds nothing on those keys, so nothing is shadowed.

better-escape's defaults also mapped `jk` in terminal mode, which broke j/k navigation inside
lazygit and yazi. Setting `t = { j = { k = false } }` was not enough (the plugin still maps the first
key), so `default_mappings = false` with the four wanted modes listed explicitly.

### 4. Terminals always starting nushell

`options.lua` set `shell = "nu"` whenever nu was installed. `'shell'` now comes from the passwd
database through `vim.uv.os_get_passwd()`, which reflects `chsh` immediately, with `$SHELL` as the
fallback. Nushell flags apply only when the detected shell is nu; POSIX shells get Vim's own
shell-family values, and an `OptionSet` hook re-applies the right set if `'shell'` changes mid
session. Verified with the login shell set to zsh and to nu, each time with a stale `$SHELL`
pointing elsewhere: `'shell'`, the flags, the terminal process and `system()` were correct in both.

### 5. Tabline rendering

Two causes. The highlights linked `separator` to `Comment` and `separator_selected` to `Function`,
while slanted separators only work when the separator's foreground is the bar's background, so the
slants were painted in the wrong colours on the wrong background. And bufferline allows one
separator character per focus state, applied with one highlight group, so the requested arrangement
(U+E0BA and U+E0BC around the active buffer, U+E0BB between the rest) cannot render cleanly: a
buffer visible in a second split gets a stray half-edge.

bufferline.nvim was also 20 months without a commit (last: 2025-01-14). It is replaced by
barbar.nvim (last commit 2026-06-10), which takes separate separators and separate `Sign` and
`SignRight` highlights per state, and which covers the same feature set: pin, pick, pick-and-close,
reorder, close left/right/others, reopen, neo-tree offset, diagnostics, clickable buffers. Keymaps
are unchanged apart from three additions (`<leader>bd`, `<leader>br`, `<leader>bs`).

The tabline now draws the current and visible buffers as slanted blocks and flattens inactive
buffers onto the bar, split by a U+E0BB in the accent colour. A `ColorScheme` hook repaints the
edges from whatever the new theme sets, including themes that ship their own `Buffer*` groups and
themes with a transparent background. Verified: the three glyphs are present in the rendered
tabline, the slant colours match the block colours, and inactive buffers sit on the bar colour.

### 6. Monokai variants all looking alike

`colors/monokai-pro.lua` in the plugin contains one line: `require("monokai-pro").set_filter("pro")`.
Loading the colorscheme by that name therefore discards the filter passed to `setup()`. The switcher
now loads the per-filter colorscheme name (`monokai-pro-classic`, `-octagon`, `-machine`,
`-ristretto`, `-spectrum`, `-light`). Verified: all seven filters produce distinct Normal and
Function colours.

### 7. Square corners on virtual-line diagnostics

Neovim 0.12.5 hardcodes the connector characters inside `render_virtual_lines` and re-renders from
its own `CursorMoved` autocmd when `current_line` is on, so wrapping the handler's `show` is not
enough. `utils.setup_rounded_virtual_lines()` registers a `virtual_lines_rounded` handler that
tracks the cursor line itself, calls the built-in renderer for that line, and rewrites the corner in
the extmarks it just placed. No flicker, since the rewrite is synchronous. Verified: the rendered
line reads `╰────` and contains no `└`.

### 8. Rust diagnostics arriving only on save

Reproduced against rust-analyzer 2026-09-14: deleting a character from a macro name produced no
diagnostic for over eight seconds. rust-analyzer marks a diagnostic experimental unless the handler
opts out (`ide-diagnostics/src/lib.rs`, `Diagnostic::new` defaults to `experimental = true`), and
unresolved-macro-call does not opt out, so it is hidden by default; the rustc version of the same
error only arrives through `cargo check` on save. With
`diagnostics.experimental.enable = true` in rustaceanvim's server settings the diagnostic appeared
153 ms after the edit, unsaved. Compiler errors that only rustc can produce still wait for a save,
which is what cargo check is.

`lspconfig.lua` also set `debounce_text_changes = 500`, which delayed every server's view of an edit
by 350 ms beyond the default; rustaceanvim resolves `vim.lsp.config['*']`, so it was affected too.
Removed.

### 9. Debug stack

`<leader>Dp` called a custom `dap.extensions.pick` that needed fzf-lua or a telescope-dap extension
that was never installed, so it did nothing. The debug keys are now nvim-dap's own functions and
cover breakpoints (plain, conditional, log point, clear, list), stepping, run-to-cursor, run-last,
pause, terminate, REPL, hover, scopes and evaluate. nvim-dap-ui's listeners match its README
(`before.attach` and `before.launch` open the panels). mason.nvim no longer waits for `:Mason` to
load, because its setup is what puts `$MASON/bin` on `$PATH`, which is where rustaceanvim looks for
codelldb. nvim-dap loads before rustaceanvim so rust-analyzer advertises its debug actions. Verified:
adapters for codelldb, pwa-node, python and haskell, configurations for rust and python, both UI
listeners, and the keymaps.

### 10. Tab in pickers opening unrelated files

In fzf, `Tab` is bound to `toggle+down`, so navigating with it silently marked files and `Enter`
opened every marked one. fzf runs inside a terminal and has no normal mode, so the requested
behaviour cannot be built on fzf-lua at all.

Telescope, fzf-lua and snacks.picker had been three picker engines for one job since the second
pass, with the fourth pass leaving it open. snacks.picker (already installed, previously disabled)
now serves every picker: it opens with the result list focused in normal mode, `<Tab>`/`<S-Tab>`
move, `<C-Space>` marks for multi-select, `<C-a>` marks everything, `i` or `/` moves to the prompt.
Live sources keep the prompt focused. Telescope, its three extensions and fzf-lua are removed;
telescope-fzf-native stays as dropbar's fuzzy-search library.

Everything that used a picker moved with it: octo (`picker = "snacks"`), nvim-scissors
(`picker = "snacks"`), todo-comments (its own snacks source), codediff's branch and commit keys
(snacks git pickers with a custom confirm), the right-click menu, and text-case's `gA.`, which is
now a `vim.ui.select` list built from the same API its telescope extension used. `<leader>f` finds
files, `<leader>s` searches content, and LSP pickers moved to their own `<leader>l` group.

Menus outside the picker follow the same keys: the quickfix window (nvim-bqf's `<Tab>` item marking
moved to `<C-Space>`), Trouble, the harpoon menu and dropbar menus. hardtime's default exclusions do
not cover the picker, so its list, input, terminal, harpoon and dropbar filetypes were added;
without that, j/k stop after three presses inside a normal-mode picker.

### Other changes

- Two plugins moved home: `echasnovski/mini.nvim` is now `nvim-mini/mini.nvim`, `yetone/avante.nvim`
  is now `avante-corp/avante.nvim`.
- `LspDetach` cleared an autocommand group that only existed if a client had asked for reference
  highlights, so detaching any other client raised `Invalid 'group'`. The group is created once.
- Visual `<M-j>`/`<M-k>` ended in `gv-gv`, which reselects and then moves the cursor; the reindent
  form is `gv=gv`.
- `as` was bound to the treesitter scope object, shadowing the native sentence object; the scope
  object moved to `aS`. Class motions moved off the native `]m`/`[m`/`]M`/`[M` method motions to
  `]k`/`[k`/`]K`/`[K`, and JSX element motions off the native `]]`/`[[` sections to `]j`/`[j`.
- Copilot's dismiss key moved off `<C-]>`, the native insert-mode abbreviation trigger, to `<M-e>`.
- `<leader>on`, `<leader>or` and `<leader>ow` are snacks toggles now, so which-key shows their state;
  `<leader>oS`, `<leader>oi` and `<leader>oD` were added the same way.
- `utils.get_current_branch_name` ran `git rev-parse` on every title redraw for files gitsigns had
  not attached to. It caches per buffer.
- The `TermOpen` autocmd called `startinsert` even when the terminal opened in a background window,
  which put the focused window into insert mode; it now checks the buffer is the current one.
- Single-consumer dependencies moved into `deps/shared.lua` with the shared ones, so no plugin file
  declares another plugin's spec.
- New `core/` category for the plugins everything else leans on: snacks, mini, which-key, themes.
  `search/` and `terminal/` are gone.

### Comments and style

Every file carries a one or two line header saying what the plugin is and which keys it owns, plus
end-of-line comments where the code does not explain itself. The long explanatory blocks, the
section banners and the prose paragraphs inside files were removed, along with the em dashes,
first-person phrasing and "confirmed by reading the source" notes that the fourth pass left behind.
Reasoning that is worth keeping lives here instead. stylua formats the whole tree (tabs, 140
columns).

### Verification

Neovim 0.12.5, all 88 plugins installed from the lockfile, run headless: every file parses; startup
is clean; three terminal layouts stay separate; terminal-mode navigation moves in splits and passes
through in floats; the picker opens focused on the list in normal mode with Tab, Shift-Tab and
`<C-Space>` bound as intended, and completion off in the prompt; hardtime skips picker buffers; the
tabline contains all three separator glyphs with matching colours; the seven monokai filters differ;
the rounded corner renders; the debug adapters, configurations, listeners and keys exist; `gA.`
converts a word; Trouble, bqf and dropbar carry the shared menu keys. Shell detection was checked
against a zsh login shell and a nushell login shell, each with a stale `$SHELL`.

### Open for next pass

- barbar's own rendering has not been exercised against every theme in the switcher; the repaint
  reads whatever the theme provides, but only tokyonight and monokai-pro were seen rendering.
- text-case.nvim (2024-08) and neotest's FixCursorHold recommendation are the two remaining pieces
  of unmaintained surface. Neither has a drop-in replacement yet.
- avante's build needs cargo; it was not exercised here.

## 2026-09-05 (first and second passes) — first full real install, plus a verification pass
## (condensed)

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
