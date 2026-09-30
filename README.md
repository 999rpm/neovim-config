# Neovim config

Neovim 0.12+ (tested on 0.12.5), managed by lazy.nvim. One plugin per file under `lua/plugins/<category>/`, editor
settings under `lua/config/`, shared helpers in `lua/utils.lua`. The change log with the reason for every change is in
`AUDIT_SUMMARY.md`.

88 plugin specs, 11 of which load at startup. On the machine this was measured on, a bare `nvim` reached the
dashboard in 48-71 ms across eight runs, mean 60 ms, against 119 ms before the laziness pass. Treat the figure as a
rough scale rather than a number to hit: it moves with disk cache, terminal and plugin versions. Everything not in
those eleven arrives with the first real buffer or the first keypress that needs it.

## Install

```sh
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
unzip nvim-config.zip -d ~/.config   # writes ~/.config/nvim and ~/.config/kitty/kitty.conf
nvim
```

`kitty/kitty.conf` in the archive is the current file, unchanged. `unzip nvim-config.zip 'nvim/*' -d ~/.config` leaves
kitty alone.

First launch clones the plugins, then Mason installs the language servers, formatters, linters and debug adapters listed
in `lua/plugins/lsp/mason.lua`. Parsers build once the tree-sitter CLI is present (Mason installs it too). `<leader>pl`
manages plugins, `<leader>pm` manages tools, `<leader>ph` reports what is missing.

### External binaries

| Tool | Needed for |
| --- | --- |
| git, a C compiler, `make` | plugin installs, treesitter parsers, telescope-fzf-native |
| tree-sitter CLI | parser builds (Mason installs `tree-sitter-cli`) |
| ripgrep, fd | grep pickers, file pickers, grug-far |
| d2 | d2 diagrams and `d2 fmt`; one static binary, from `curl -fsSL https://d2lang.com/install.sh \| sh -s --` or the release archive at github.com/terrastruct/d2 |
| Node.js 22+ | Copilot, mcp-hub, the JS/TS servers, js-debug-adapter |
| python3 | debugpy, ruff, basedpyright |
| ImageMagick (`magick`) | image conversion for snacks.image (markdown images, math) |
| kitty, or another terminal with the kitty graphics protocol | inline images, math and d2 PNGs |
| lazygit | `<leader>gl` |
| yazi | `<leader>ey` |
| gh (authenticated) | Octo; without it Octo only warns |
| xxd | `<leader>ox` hex view; without it hex.nvim only warns |
| btop | `<leader>tm` |
| cargo | avante's build step compiles its tokenizer |
| Go toolchain (optional) | gopls, and Mason's gofumpt build |
| ghcup's hls (optional) | Haskell language server |
| A Nerd Font | icons in the tabline, statusline, pickers and trees |

## Layout

```
init.lua                    entry point: options, autocmds, mappings, lazy
.stylua.toml                formatter settings: tabs, 140 columns
lazy-lock.json              pinned plugin commits
lua/utils.lua               helpers shared by config and plugin files
lua/config/
  options.lua               editor options, shell detection, filetype rules
  autocmds.lua              autocommands, all in 999rpm-* groups
  mappings.lua              editor-wide keymaps
  lazy.lua                  lazy.nvim bootstrap and runtime settings
lua/plugins/
  loader.lua                imports the category folders below
  core/                     snacks, mini, which-key, themes
  lsp/                      lspconfig, mason, lazydev, inc-rename, symbol-usage, rustaceanvim
  completion/               blink.cmp, copilot, autopairs
  treesitter/               treesitter, tree-sitter-d2, textobjects, context, rainbow-delimiters, hlargs, treesj, autotag
  editor/                   motions, text editing, sessions, snippets
  ui/                       barbar, lualine, noice, trouble, folds, scrollbar, breadcrumbs, markdown
  git/                      gitsigns, codediff, gitlinker, octo
  explorer/                 neo-tree, oil, yazi
  debug/                    nvim-dap and its panels
  test/                     neotest
  lang/                     conform, nvim-lint, and the per-language helpers
  ai/                       avante, opencode, mcphub
  deps/shared.lua           library plugins other files reference by name
```

## Every plugin

| File | Plugin | Loads on |
| --- | --- | --- |
| `core/snacks.lua` | folke/snacks.nvim | startup |
| `core/mini.lua` | nvim-mini/mini.nvim (icons, ai) | startup |
| `core/which-key.lua` | folke/which-key.nvim | `VimEnter` |
| `core/themes.lua` | tokyonight, catppuccin, kanagawa, monokai-pro + the switcher | startup |
| `lsp/lspconfig.lua` | neovim/nvim-lspconfig | first buffer |
| `lsp/mason.lua` | mason, mason-lspconfig, mason-tool-installer | startup / `VeryLazy` |
| `lsp/lazydev.lua` | folke/lazydev.nvim | `ft=lua` |
| `lsp/inc-rename.lua` | smjonas/inc-rename.nvim | `:IncRename` |
| `lsp/symbol-usage.lua` | Wansmer/symbol-usage.nvim | `LspAttach` |
| `lsp/rustaceanvim.lua` | mrcjkb/rustaceanvim | startup, then per filetype |
| `completion/blink.lua` | saghen/blink.cmp | insert or cmdline |
| `completion/copilot.lua` | zbirenbaum/copilot.lua | insert |
| `completion/autopairs.lua` | windwp/nvim-autopairs | insert |
| `treesitter/treesitter.lua` | nvim-treesitter (main) | first buffer |
| `treesitter/textobjects.lua` | nvim-treesitter-textobjects (main) | first buffer |
| `treesitter/context.lua` | nvim-treesitter-context | first buffer |
| `treesitter/rainbow-delimiters.lua` | hiphish/rainbow-delimiters.nvim | first buffer |
| `treesitter/hlargs.lua` | m-demare/hlargs.nvim | first buffer |
| `treesitter/treesj.lua` | Wansmer/treesj | `<leader>cj` |
| `treesitter/ts-autotag.lua` | windwp/nvim-ts-autotag | tag filetypes |
| `treesitter/tree-sitter-d2.lua` | ravsii/tree-sitter-d2 | `ft=d2,markdown` |
| `editor/flash.lua` | folke/flash.nvim | its keys |
| `editor/surround.lua` | kylechui/nvim-surround | `VeryLazy` |
| `editor/coerce.lua` | gregorias/coerce.nvim | `gA` |
| `editor/dial.lua` | monaqa/dial.nvim | `<C-a>` / `<C-x>` |
| `editor/multicursor.lua` | jake-stewart/multicursor.nvim | `VeryLazy` |
| `editor/grug-far.lua` | MagicDuck/grug-far.nvim | `<leader>r*` |
| `editor/harpoon.lua` | ThePrimeagen/harpoon (harpoon2) | `<leader>h*` |
| `editor/persistence.lua` | folke/persistence.nvim | `BufReadPre` |
| `editor/nvim-scissors.lua` | chrisgrieser/nvim-scissors | `<leader>cs*` |
| `editor/neogen.lua` | danymat/neogen | `<leader>cn` |
| `editor/todo-comments.lua` | folke/todo-comments.nvim | first buffer |
| `editor/img-clip.lua` | HakonHarnes/img-clip.nvim | `<leader>cp` |
| `editor/hex.lua` | RaafatTurki/hex.nvim | `<leader>ox` |
| `editor/hardtime.lua` | m4xshen/hardtime.nvim | startup |
| `editor/better-escape.lua` | max397574/better-escape.nvim | insert |
| `editor/guess-indent.lua` | nmac427/guess-indent.nvim | first buffer |
| `editor/numb.lua` | nacro90/numb.nvim | `CmdlineEnter` |
| `ui/barbar.lua` | romgrk/barbar.nvim | startup |
| `ui/lualine.lua` | nvim-lualine/lualine.nvim | `VeryLazy` |
| `ui/noice.lua` | folke/noice.nvim | startup |
| `ui/trouble.lua` | folke/trouble.nvim | `:Trouble` |
| `ui/ufo.lua` | kevinhwang91/nvim-ufo | first buffer |
| `ui/statuscol.lua` | luukvbaal/statuscol.nvim | first buffer |
| `ui/satellite.lua` | lewis6991/satellite.nvim | first buffer |
| `ui/dropbar.lua` | Bekaboo/dropbar.nvim | first buffer |
| `ui/nvim-bqf.lua` | kevinhwang91/nvim-bqf | `ft=qf` |
| `ui/render-markdown.lua` | MeanderingProgrammer/render-markdown.nvim | `ft=markdown` |
| `ui/colorizer.lua` | catgoose/nvim-colorizer.lua | first buffer |
| `ui/modicator.lua` | mawkler/modicator.nvim | `VeryLazy` |
| `ui/stickybuf.lua` | stevearc/stickybuf.nvim | first buffer |
| `ui/colorful-winsep.lua` | nvim-zh/colorful-winsep.nvim | `WinLeave` |
| `git/gitsigns.lua` | lewis6991/gitsigns.nvim | `BufReadPre` |
| `git/codediff.lua` | esmuellert/codediff.nvim | `:CodeDiff` |
| `git/gitlinker.lua` | linrongbin16/gitlinker.nvim | `<leader>gy` / `gY` |
| `git/octo.lua` | pwntester/octo.nvim | `:Octo` |
| `explorer/neo-tree.lua` | nvim-neo-tree/neo-tree.nvim | `:Neotree` |
| `explorer/oil.lua` | stevearc/oil.nvim | `:Oil`, or a directory argument |
| `explorer/yazi.lua` | mikavilpas/yazi.nvim | `<leader>ey` |
| `debug/dap.lua` | mfussenegger/nvim-dap | its keys |
| `debug/dap-ui.lua` | rcarriga/nvim-dap-ui | with nvim-dap |
| `debug/dap-python.lua` | mfussenegger/nvim-dap-python | with nvim-dap |
| `debug/dap-virtual-text.lua` | theHamsta/nvim-dap-virtual-text | `<leader>Dv` |
| `test/neotest.lua` | nvim-neotest/neotest + neotest-jest | `<leader>T*` |
| `lang/conform.lua` | stevearc/conform.nvim | `BufWritePre` |
| `lang/lint.lua` | mfussenegger/nvim-lint | first buffer |
| `lang/boundary.lua` | Kenzo-Wada/boundary.nvim | `ft=tsx,jsx` |
| `lang/template-string.lua` | axelvc/template-string.nvim | JS/TS filetypes |
| `lang/tw-values.lua` | MaximilianLloyd/tw-values.nvim | `<leader>cv` |
| `ai/avante.lua` | avante-corp/avante.nvim | its keys and commands |
| `ai/opencode.lua` | NickvanDyke/opencode.nvim | `<leader>io/ic/iS` |
| `ai/mcphub.lua` | ravitemer/mcphub.nvim | `:MCPHub` |
| `deps/shared.lua` | plenary, nui, nio, coop, promise-async, schemastore, friendly-snippets, neotest-jest, telescope-fzf-native | on demand |

## Keymaps

Leader is `Space`, local leader is `\`. Press the leader and wait for which-key to list what follows, or `<leader>sk`
to search every mapping.

Three rules hold across the whole map. A prefix collects one kind of thing. The lowercase key is the common action and
its uppercase twin the wider or rarer form. Anything that only turns something on or off lives under `<leader>o`, and
nothing else does.

### Leader groups

| Prefix | Group |
| --- | --- |
| `<leader>b` | Buffers: pick, pin, move, close left/right/others, reopen |
| `<leader>c` | Code: format, annotate, split/join, snippets (`cs`), paste image, Tailwind values |
| `<leader>d` | Diagnostic lists through Trouble |
| `<leader>D` | Debug: breakpoints, stepping, REPL, UI, virtual text |
| `<leader>e` | Explorers: neo-tree, oil, yazi, pick a window (`ew`), files in the buffer's directory |
| `<leader>f` | Find files: files, git files, buffers, recent, config, plugin sources, projects |
| `<leader>g` | Git: hunks, blame, lazygit, browse, commits, status, branches, permalinks |
| `<leader>go` | GitHub through Octo |
| `<leader>G` | Review workspace (codediff) |
| `<leader>h` | Harpoon |
| `<leader>i` | AI: avante, opencode |
| `<leader>j` / `<leader>J` | Flash: jump anywhere visible / select a treesitter node |
| `<leader>l` | LSP pickers: definitions, references, symbols, calls |
| `<leader>m` | Multicursor |
| `<leader>n` | No-yank edits, path yanks, register pastes, `na` select whole buffer |
| `<leader>o` | Toggles, and only toggles: numbers, wrap, spell, diagnostics, inlay hints, indent guides, dimming, reference highlights, treesitter context, format on save, git blame, hex view, hardtime |
| `<leader>p` | Plugins and tools: `pl` Lazy, `pm` Mason, `pc` Conform info, `ph` checkhealth |
| `<leader>q` | Sessions, `qq` quit window, `qa` quit all |
| `<leader>r` | Search and replace across files (grug-far) |
| `<leader>s` | Search contents: grep, help, keymaps, commands, diagnostics, marks, undo, todos, resume |
| `<leader>t` | Terminals: float, vertical, horizontal, btop |
| `<leader>T` | Tests |
| `<leader>u` | UI and theme: `ut`/`uT` theme and transparency, `uc`/`uC` style, scratch, zen, zoom, breadcrumbs, markdown, image float, d2 (`ud` image, `uD` text) |
| `<leader>w` | LSP workspace folders |
| `<leader>x` | Diagnostics: line float, buffer and workspace quickfix |
| `<leader>a` / `<leader>A` | Swap the parameter under the cursor with the next / previous one |
| `<leader><Tab>` | Tabs |
| `<localleader>` | Buffer-local keys of codediff reviews, grug-far and Octo |

### Non-leader keys

| Key | Action |
| --- | --- |
| `<M-h>` / `<M-l>` | Previous / next buffer, in tabline order (`]b`/`[b` also cycle) |
| `<M-w>` `<M-a>` `<M-s>` `<M-d>` | Move between windows, terminal mode included |
| `<M-y>` / `<M-x>` / `<M-e>` / `<M-q>` | Split vertical / horizontal / equalize / close |
| `<M-Up>` `<M-Down>` `<M-Left>` `<M-Right>` | Resize the current window |
| `<M-j>` / `<M-k>` | Move the line or selection |
| `<C-s>` | Write |
| `<C-,>` | Toggle the floating terminal, from normal and terminal mode |
| `<C-a>` / `<C-x>` | Increment / decrement, widened to dates, booleans and semver by dial.nvim |
| `gA` + case key | Change the case of the word, or of the selection in visual mode |
| `ys` `ds` `cs`, visual `gs` / `gS` | Add, delete, change a surrounding pair |
| `gco` / `gcO` / `gcA` | Comment on a new line below / above / at the end of the line |
| `]c` `[c` | Git hunks (Neovim's own change jumps in diff mode) |
| `]r` `[r` | Next / previous occurrence of the symbol under the cursor |
| `]m` `[m` / `]M` `[M` | Function start / end, from treesitter, in every language |
| `]k` `[k` `],` `[,` `]j` `[j` | Class, parameter, JSX element |
| `]n` `[n` | Todo comments (normal mode; the visual-mode pair is Neovim's node selection) |
| `[u` | Jump to the enclosing context line |
| `gd` / `gD` | Definition / declaration, where a server answers them |
| `<C-Up>` / `<C-Down>`, `<M-LeftMouse>` | Add a cursor above / below, at the click |
| `zR` / `zM` | Open / close all folds through nvim-ufo |

Case keys after `gA`: `c` camelCase, `p` PascalCase, `s` snake_case, `u` UPPER_CASE, `k` kebab-case, `d` dot.case,
`/` path/case, `n` numeronym, `Space` space case.

### Built-in keys stay built-in

No personal key takes a built-in command away. A personal key sits on a built-in only when it does the same job
better: `<C-a>`/`<C-x>` through dial, `n`/`N` centred, `gd`/`gD` and `grn` through the language server, `]m`/`[m`/`]M`/`[M`
through treesitter, `zR`/`zM` through ufo, `a`/`i` text objects through mini.ai, `%` through the bundled matchit. `K` is
Neovim's own LSP hover (rustaceanvim's hover actions in Rust buffers). hardtime wraps `h` `j` `k` `l` `J` `x` `X` and a few
more to count repeats; each still does its built-in job. hardtime turns the arrow keys off, which is why resizing sits
on `<M-arrows>`.

Earlier versions of this config took these built-ins; all of them are back:

| Key | Built-in job | The personal action now |
| --- | --- | --- |
| `;` `,` | Repeat `f`/`t` forward / back | `:` opens the command line |
| `q` | Record a macro | `<leader>qq` quits the window |
| `x` `X` | Delete a char, yanking it | `<leader>nd` deletes without yanking |
| visual `p` | Paste, yanking the replaced text | visual `P` pastes without yanking (built-in) |
| `<C-q>` | Blockwise visual | `<leader>qq` |
| `H` `L` | Window top / bottom | `<M-h>` `<M-l>` for buffers |
| `f` `F` | Character search | `<leader>j` `<leader>J` for flash |
| `s`, visual `S` | Substitute | visual `gs` / `gS` for surround |
| visual `R` | Replace lines | flash's `R` only after an operator |
| `g]` | `:tselect` for the word | mini.ai's edge jumps are off |
| `<C-LeftMouse>` | Jump to tag | `<M-LeftMouse>` for multicursor |
| `]f` `[f` | Open the file under the cursor | functions moved to `]m` `[m` |
| `]]` `[[` | Section motions | references moved to `]r` `[r` |
| `zr` | Fold one level less | ufo's variant dropped |
| `<Left>` `<Right>` `<End>` on the command line | Move the cursor | blink's command-line preset trimmed |

Built-ins worth knowing are listed at the top of `lua/config/mappings.lua`.

### Neovim 0.12 keys this config leaves alone

`which-key.lua` labels the `g`-prefixed ones, because built-in *commands*, unlike keymaps, appear in no keymap table and
so cannot be discovered by anything:

| Key | Action |
| --- | --- |
| `K` | Hover documentation (LSP) |
| `grn` `gra` `grr` `gri` `grt` `grx` `gO` | Rename, code action, references, implementation, type definition, code lens, symbols |
| `<C-s>` (insert) | Signature help |
| `]d` `[d` / `]D` `[D` | Next, previous / last, first diagnostic |
| `<C-w>d` | Diagnostic float for the line |
| `]q` `[q` / `]l` `[l` | Quickfix / location list |
| `]b` `[b` / `]a` `[a` / `]t` `[t` | Buffers / argument list / tags |
| `]<Space>` `[<Space>` | Blank line below / above |
| `an` / `in` | Select the parent / child treesitter node (visual and operator-pending) |
| `]n` `[n` (visual) | Grow the selection by node |

### Menus

Pickers, the quickfix window, Trouble, the harpoon menu and dropbar menus share one set of keys:

| Key | Action |
| --- | --- |
| `<Tab>` / `<S-Tab>` | Next / previous entry |
| `<CR>` | Open the entry |
| `<C-Space>` | Mark an entry for multi-select |
| `<C-a>` | Mark everything (pickers) |
| `i` or `/` | Type a query (pickers open with the list focused, in normal mode) |
| `<C-s>` / `<C-v>` / `<C-t>` | Open in a split, vertical split or tab |
| `<C-q>` | Send the results to the quickfix list |
| `q` or `<Esc>` | Close |

Live sources (grep, git grep, workspace symbols) open with the prompt focused, since they need a query before there is
anything to list.

## What loads when

A bare `nvim` loads eleven plugins: snacks, mini, barbar, noice, hardtime, rustaceanvim, the theme switcher and its
current colorscheme, mason, lazy and nui. The dashboard draws from snacks, and nothing else has run.

Opening a file adds the language servers, treesitter, completion, git signs and the rest, roughly thirty-six specs in
total. The installers behind Mason wait for `VeryLazy`, so a tool download is never on the path of opening a file, and
the debug stack waits for a `<leader>D` key.

Two dependency entries were dropped to keep that true. mason-lspconfig no longer names nvim-lspconfig, because version 2
carries its own package mappings and the entry would have forced lspconfig to load at startup. barbar no longer names
gitsigns, because it reads `b:gitsigns_status_dict` through a `pcall` and its git-count icons are off by default. Every
file that only wanted mini.icons dropped that entry too: mini loads at priority 1000, before anything that draws an icon.

## Markdown and d2

render-markdown draws headings, lists, callouts and code blocks in place (`<leader>um` toggles it). snacks.image draws
images and ` ```math ` blocks inline, straight into the kitty window; `<leader>ui` opens the one under the cursor in a
float.

d2 replaces mermaid. mermaid's CLI renders through a headless Chromium; d2 is one static binary that writes SVG, PNG and
text itself. `.d2` files and ` ```d2 ` blocks in markdown get treesitter highlighting from tree-sitter-d2. `<leader>ud`
renders the diagram under the cursor to PNG and opens it beside the source, reusing the same split on the next press;
kitty draws it through snacks.image. `<leader>uD` renders the same diagram as box-drawing text in a split, which works in
any terminal; `q` closes it. In a `.d2` file the whole file is the diagram; in markdown it is the ` ```d2 ` block holding
the cursor. A dark background renders with d2's Dark Mauve theme, a light one with its default. conform runs `d2 fmt`
on save. A ` ```mermaid ` block is plain highlighted text now: the markdown image query hands only ` ```math ` blocks
to snacks.image.

## Terminals

`<leader>tf`, `<leader>tv` and `<leader>th` open a floating, vertical and horizontal terminal. Each layout is a
separate terminal, so toggling one never moves another. A count prefix opens more of them: `2<leader>tv` is a second
vertical terminal. `<C-,>` toggles the float from anywhere, terminal mode included. `<Esc><Esc>` switches a terminal to
normal mode, `q` hides it.

## Shells

`'shell'` follows the login shell recorded in the passwd database, so `chsh` applies to the next Neovim start rather
than the next login. Nushell gets the shell flags from nushell's own Neovim integration; zsh, bash and other POSIX
shells get Vim's. Changing `'shell'` inside a session re-applies the matching flags. Non-interactive zsh reads only
`.zshenv`, so `:!cmd`, `:make` and the formatters see the PATH set there, including `~/.local/bin`. Under nushell,
`:make` and `:grep` save a command's stdout and stderr to the quickfix list, the way `2>&1| tee` does for zsh. A `:%!`
filter under nushell takes a nushell pipeline (`lines | sort | str join (char nl)`), or `^sort` for the external
command. The d2 renders, the git calls behind the statusline and the format checks pass an argument list to
`vim.system`, with no shell in between, so they behave the same under zsh and nushell.

`<C-s>` always reaches Neovim: its terminal UI switches the tty to raw mode, which turns off XON/XOFF flow control. At the
zsh prompt the same key still freezes output unless `.zshrc` has `unsetopt FLOW_CONTROL`; the current `.zshrc` does not
set it. Nushell does not take the key at all.

## Kitty

`shell .` in `kitty.conf` makes kitty follow the login shell too. kitty.conf binds `ctrl+shift+*` and `alt+1`..`alt+9`;
Neovim here uses neither. Its Alt keys (`<M-h>` `<M-l>` `<M-j>` `<M-k>` `<M-w>` `<M-a>` `<M-s>` `<M-d>` `<M-y>` `<M-x>`
`<M-e>` `<M-q>` `<M-m>`, `<M-arrows>`) and `<M-LeftMouse>` reach Neovim because kitty.conf has no mapping or
`mouse_map` for them. `ctrl+t` stays unbound in kitty, so `<C-t>` reaches Neovim and fzf's widget. `<C-,>` needs
kitty's keyboard protocol, which is on by default.

## Themes

tokyonight, catppuccin, kanagawa and monokai-pro, each with its styles. `<leader>ut` cycles themes, `<leader>uc` cycles
styles, `<leader>uC` picks one from a list, `<leader>uT` toggles transparency. The choice is saved in
`stdpath("data")/999rpm-theme.json` and restored at startup. Highlight overrides from dap, render-markdown and
multicursor are re-applied after every switch through `utils.on_colorscheme`.

## Conventions

- One plugin per file, named after the plugin. Dependencies with no configuration of their own live in
  `lua/plugins/deps/shared.lua` and are referenced by name. A `dependencies` entry is kept only where it changes load
  order in a way the plugin needs; a plugin that is already loaded at startup is never listed.
- Comments: one header per file saying what the plugin does, the keys this config binds for it and the keys the plugin
  brings inside its own windows, then end-of-line comments only. No full-line comment appears below a file's header.
- Autocommand groups are `999rpm-<name>`, so `:autocmd 999rpm-*` lists everything this config adds. Buffer-local
  variables this config sets are `b:_999rpm_*`, the terminal env var is `NVIM_999RPM_TERM`, the theme state file is
  `999rpm-theme.json`, the d2 cache is `999rpm-d2/` and the d2 text buffer is `999rpm://d2-text`.
- which-key entries carrying only a `desc` are labels, not mappings: which-key calls `vim.keymap.set` only for entries
  that also carry an `rhs`. That is how built-in commands get named in the popup without being taken away from Neovim.
- Keymap descriptions are sentence case, with no trailing period and no repetition of the group name.
- Helpers in `lua/utils.lua` carry an end-of-line note naming the files that call them, so a helper with no caller
  shows up as dead code.
- Icons come from the Nerd Font nf-md range (U+F0001 and up). Older private-use glyphs (U+E000 to U+F8FF) get dropped
  by some copy and paste paths, so the few with no nf-md equivalent, the slanted statusline separators, are written as
  `\u{...}` escapes.
- `.stylua.toml` pins tabs and 140 columns. conform runs stylua on save, so the file has to be present or the whole
  tree reflows to stylua's own defaults on the first write.
