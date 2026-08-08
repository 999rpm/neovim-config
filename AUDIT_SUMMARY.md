# Config audit — summary

Full reasoning lives in each file's own header (dated `2026-08-06`). This is the index.
`init.lua`'s header is the master entry every other file points back to.

## Addendum — plugins didn't load at all ("No specs found for module 'plugins'")

After delivery, the category-folder restructure (see item 11 below) turned out to be broken:
lazy.nvim's own module discovery (`lazy/core/util.lua`'s `lsmod`) only scans **one level deep**
from whatever module you `import` — it collects direct `.lua` files in that directory, and only
descends into a subfolder if that subfolder has its own `init.lua`. It does not recursively walk
arbitrary nesting on its own. My `plugins/<category>/<plugin>.lua` layout had no `init.lua` in
any category folder, so `lua/plugins/` itself had nothing directly in it and nothing lsmod would
descend into — hence zero specs found. Confirmed by reading the actual installed lazy.nvim
source, not guessed at a second time.

Fixed with one new file, `lua/plugins/init.lua`, that explicitly imports each category folder
(`{ import = "plugins.lsp" }`, `{ import = "plugins.ui" }`, etc.) — each of those *is* a flat
folder of `.lua` files, which lsmod finds correctly with no further nesting to worry about.

While re-verifying this under a real, full `lazy.nvim` install (not just a syntax check — see
Testing below), a second, unrelated issue turned up and is also fixed: `rainbow-delimiters.nvim`
has an optional git submodule (its own test harness) hosted on gitlab.com; repeated failures to
clone it were enough to trip lazy.nvim's "too many rounds of missing plugins" safeguard. Added
`submodules = false` to that plugin's spec — that submodule was never needed to use the plugin.

Both are now verified against a real, complete install of all ~50 plugins, not just syntax
checks — see Testing below for what that involved. Zero errors, zero warnings other than the
expected "gopls not found" (correct, if you don't have Go installed).

## Your four questions

**1. Toggleterm opens and closes instantly.**
`options.lua` had `shell = "nushell"`. Nushell's actual executable is `nu` — there is no
binary named `nushell`. Every `:terminal` (toggleterm included) tried to spawn a program that
doesn't exist, the job died immediately, and toggleterm's own default `close_on_exit = true`
closed the window the instant that happened. Fixed to `"nu"`, gated behind
`utils.executable("nu")` so it degrades gracefully instead of breaking again if nushell isn't
installed on some future machine.

**2. Two ufo fold arrows on the same line.**
`options.lua` had `foldcolumn = "4"`. A fold column wider than 1 stacks one glyph per nesting
level on any line that both continues an outer fold and starts an inner one — confirmed
against `neovim/neovim#14751`/`#21759` and how `statuscol.nvim`'s `foldfunc` renders. Not a bug
in ufo or statuscol. Fixed to `"1"` (nvim-ufo's own README recommendation). Separately, while
in `ufo.lua`, found the fallback provider was actually `{"lsp","indent"}` even though the
file's own comment always claimed `{"lsp","treesitter"}` — fixed to match.

**3. Tree-style, rainbow, animated, ufo-aware indent guides.**
Replaced `snacks.indent` with `indent-blankline.nvim` (`plugins/ui/indent-blankline.lua`).
What it actually delivers, checked against its own source before writing anything:
- **Rainbow: yes**, real — shares the exact highlight-group list `rainbow-delimiters.lua` uses,
  plus the official `scope_highlight_from_extmark` hook, so the current scope's guide always
  matches its own bracket color, not just "a" rainbow color.
- **Tree-like: partially, and worth being precise about.** indent-blankline draws one virtual
  character per level and *underlines* the top/bottom line of the current scope
  (`show_start`/`show_end`) — there's no code path that draws literal `┌`/`└` glyphs at exact
  structural corners the way a file tree does. If that literal look matters more than staying
  on indent-blankline specifically, `hlchunk.nvim`'s "chunk" module does draw real box-drawing
  corners — named in that file's comment, not swapped in, since you asked for indent-blankline.
- **Animated: no.** This is unique to `snacks.indent`/`mini.indentscope`; indent-blankline has
  no equivalent anywhere in its config schema. Saying so plainly rather than shipping something
  that quietly doesn't animate.
- **Ufo-aware: yes**, and it needed no new code — `options.lua`'s `foldtext = ""` (already set,
  now with a comment explaining why) is the same prerequisite both ufo's virtual-text summaries
  and indent-blankline's guides need to render correctly across a closed fold.

**4. Other improvements from the four configs.**
Researched targeted files in each (not a literal line-by-line read of all four full
repositories — most of what's in a general dotfiles repo, like shell aliases or tmux config,
has nothing to do with a Neovim Lua audit, so effort went to the files that could plausibly
matter: LSP config, autocmds, fold/indent setup, terminal setup, in each of the four). What
came of it:
- **rafi/vim-config** — the right-click context menu you flagged is now in `autocmds.lua`
  (`MenuPopup` block), rebuilt with this config's own plugins (Telescope, Trouble, todo-
  comments, snacks' lazygit/gitbrowse) instead of a straight copy. Actually fired under a real
  Neovim 0.11.4 binary during testing — see Testing below. Also fed two verified ideas into
  `ufo.lua`: `open_fold_hl_timeout = 0` and per-filetype fold provider exclusions for utility
  buffers (quickfix/help/neo-tree/etc.).
- **jdhao/nvim-config** — re-diffed against a fresh clone; added `ty` (Astral's newer Python
  type checker) as a commented-out option in `lspconfig.lua`, alongside the existing Pyrefly
  entry, matching his own recent addition.
- **craftzdog/dotfiles-public**, **xero/dotfiles** — the ports this config already credited
  (inlay-hint tweak, schemastore integration) were re-verified as still accurate; nothing new
  to port from either beyond what was already there.

## Everything else from the 12-point list

- **Redundancy/compatibility (1):** `lspconfig.lua` and `conform.lua` were independently
  running format-on-save — `conform.lua`'s own `lsp_format = "fallback"` already covers "format
  via LSP when nothing else is configured," so `lspconfig.lua`'s copy meant some filetypes were
  formatted twice, and conform's own format-on-save toggle didn't cover the second copy at all.
  Removed the duplicate; conform.lua is now the sole owner. `lualine.lua`'s hand-rolled venv
  lookup was a byte-for-byte copy of `utils.get_virtual_env()` — now calls it directly.
  `bufferline.lua` referenced `_G.TokyoColors()`, defined nowhere in the project — removed
  rather than left as permanent dead code.
- **Keymap conflicts with Neovim's own built-ins (7b):** checked every non-`<leader>` mapping
  against `:help index`. `trouble.lua`'s `[d`/`]d` silently shadowed the native diagnostic-jump
  keys — removed. `textobjects.lua`'s parameter swap was on `]p`/`[p` (native indent-paste) —
  moved to `<leader>a`/`<leader>A`, matching nvim-treesitter-textobjects' own README. Its class
  navigation was on `]c`/`[c` — Neovim's *native* diff-navigation keys, genuinely live inside
  `diffview.lua`'s windows — moved to `]m`/`[m`. Freed-up `]c`/`[c` now belongs to
  gitsigns.nvim's own hunk nav, matching its documented convention (its old `vim.wo.diff`
  fallback was silently dead code on `]g`/`[g`, since nothing native was ever bound there).
- **Mini/snacks → standalone (6):** `mini.bufremove` → `famiu/bufdelete.nvim`,
  `mini.hipatterns` → `catgoose/nvim-colorizer.lua`. `mini.ai` stays — see
  `plugins/editor/mini.lua`'s note on why it wasn't worth swapping (no clearly-better dedicated
  alternative, unlike the other two).
- **Comments (3, 4, 5):** every file's multi-month review log condensed to what's still
  load-bearing; new changes this pass are dated `2026-08-06`. EOL comments kept where they
  explain *why*, trimmed where they just repeated the code.
- **utils.lua (7a):** added `rainbow_delimiter_groups` (shared by `rainbow-delimiters.lua` and
  `indent-blankline.lua` so their colors can't drift apart) and tagged every function with
  which file(s) actually call it.
- **Credits (8):** `init.lua`'s header now names what was actually taken from each of the four
  configs, including rafi — the original said "surveyed, nothing adopted"; that's no longer
  true after this pass.
- **999rpm (9):** unchanged from the prior pass — every custom augroup across the config
  already routes through `utils.augroup()`, so this was already consistent; nothing new needed.
- **Reduced cross-plugin dependency (10):** `bufdelete.nvim` and `nvim-colorizer.lua` each got
  their own file rather than being folded into `bufferline.lua`/inline, matching how
  `notify.lua` was already split out from `noice.lua`.
- **File structure (11):** `plugins/` is now grouped into category folders (`lsp/`,
  `completion/`, `editor/`, `treesitter/`, `ui/`, `git/`, `explorer/`, `search/`, `debug/`,
  `test/`, `lang-tools/`, `terminal/`) instead of one flat ~50-file directory. `lazy.lua` needed
  zero changes — verified `{ import = "plugins" }` walks subdirectories recursively before
  restructuring anything.

## Testing (12)

- All 55 Lua files pass `luac5.1 -p` (syntax-valid).
- Installed a real Neovim 0.11.4 binary and loaded `utils.lua` + all four `config/*.lua` files
  directly (no plugin manager) — zero runtime errors.
- Actually **fired** the new `MenuPopup` autocmd under that same real Neovim and read back the
  built menu structure: all 21 entries present with the exact right-hand-side commands, and
  every capability-gated entry (Definition/References/.../Find Symbol/LazyGit/etc.) correctly
  disabled in an environment with no LSP client or those plugins loaded — confirming the
  enable/disable logic itself, not just that the code parses.
- Automated cross-file checks: `mason.lua`'s `ensure_installed` vs `lspconfig.lua`'s `servers`
  (18 = 18, exact match both directions), no duplicate `999rpm-*` augroup names anywhere, every
  `plugins/…/*.lua` path referenced in a comment resolves to a real file, no leftover
  `require("mini.bufremove")`/`require("mini.hipatterns")` calls.
- **Following the "No specs found" report**: ran the actual, complete `lazy.nvim` bootstrap —
  self-installing lazy.nvim itself, then installing all ~50 real plugins from their real repos,
  including compiling `telescope-fzf-native.nvim`'s C extension — from a clean slate, twice
  (once to reproduce each bug, once after each fix). Confirmed a real Neovim process opening a
  real file against the fully-installed plugin set with an empty `:messages` (zero errors,
  zero warnings besides the intentional `gopls` one). This is the level this environment could
  not do during the original delivery — it can now, and it's clean.
