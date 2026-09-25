# Neovim config

Neovim 0.12+ (tested on 0.12.5), managed by lazy.nvim. One plugin per file under `lua/plugins/<category>/`, editor
settings under `lua/config/`, shared helpers in `lua/utils.lua`. The change log with the reason for every change is in
`AUDIT_SUMMARY.md`.

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
in `lua/plugins/lsp/mason.lua`. Parsers build once the tree-sitter CLI is present (Mason installs it too). `:Lazy`
manages plugins, `:Mason` manages tools, `:checkhealth` reports what is missing.

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
| xxd | `<leader>oX` hex view; without it hex.nvim only warns |
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
  core/                     snacks (picker, dashboard, terminals, images, big files), mini, which-key, themes
  lsp/                      lspconfig, mason, lazydev, inc-rename, symbol-usage, rustaceanvim
  completion/               blink.cmp, copilot, autopairs
  treesitter/               treesitter, tree-sitter-d2, textobjects, context, rainbow-delimiters, hlargs, treesj, autotag
  editor/                   motions, surround, case, multicursor, search and replace, snippets, sessions
  ui/                       barbar, lualine, noice, trouble, folds, scrollbar, breadcrumbs, markdown
  git/                      gitsigns, codediff, gitlinker, octo
  explorer/                 neo-tree, oil, yazi
  debug/                    nvim-dap and its UI, python and virtual text
  test/                     neotest
  lang-tools/               conform, nvim-lint
  ai/                       avante, opencode, mcphub
  frontend/                 boundary, template-string, tw-values
  deps/shared.lua           library plugins other files reference by name
```

## Keymaps

Leader is `Space`, local leader is `\`. Press the leader and wait for which-key to list what follows, or `<leader>sk`
to search every mapping. Lowercase and uppercase prefixes pair up: the lowercase one is the common action, the
uppercase twin is its wider or rarer form.

### Leader groups

| Prefix | Group |
| --- | --- |
| `<leader>b` | Buffers: pick, pin, move, close left/right/others, reopen |
| `<leader>c` | Code: format, annotate, split/join, snippets (`cs`), paste image, Tailwind values |
| `<leader>d` | Diagnostic lists through Trouble |
| `<leader>D` | Debug: breakpoints, stepping, REPL, UI, virtual text |
| `<leader>e` | Explorers: neo-tree, oil, yazi, pick a window (`ew`), files in the buffer's directory |
| `<leader>f` | Find files: files, git files, buffers, recent, config, plugins, projects |
| `<leader>g` | Git: hunks, blame, lazygit, browse, commits, status, branches |
| `<leader>go` | GitHub through Octo |
| `<leader>G` | Review workspace (codediff) |
| `<leader>h` | Harpoon |
| `<leader>i` | AI: avante, opencode |
| `<leader>j` / `<leader>J` | Flash: jump anywhere visible / select a treesitter node |
| `<leader>l` | LSP pickers: definitions, references, symbols, calls |
| `<leader>m` | Multicursor |
| `<leader>n` | No-yank edits, path yanks, register pastes, `na` select whole buffer |
| `<leader>o` | Options and toggles: numbers, wrap, spell, diagnostics, inlay hints, theme, format on save; `ol` Lazy, `om` Mason |
| `<leader>q` | Sessions, `qq` quit window, `qa` quit all |
| `<leader>r` | Search and replace (grug-far) |
| `<leader>s` | Search contents: grep, help, keymaps, commands, diagnostics, marks, undo, todos, resume |
| `<leader>t` | Terminals: float, vertical, horizontal, btop |
| `<leader>T` | Tests |
| `<leader>u` | UI: scratch, zen, zoom, breadcrumbs, markdown render, image float, d2 diagram (`ud` image, `uD` text) |
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
zsh prompt the same key still freezes output unless `.zshrc` has `unsetopt FLOW_CONTROL`. Nushell does not take it.

## Kitty

`shell .` in `kitty.conf` makes kitty follow the login shell too. kitty.conf binds `ctrl+shift+*` and `alt+1`..`alt+9`;
Neovim here uses neither. Its Alt keys (`<M-h>` `<M-l>` `<M-j>` `<M-k>` `<M-w>` `<M-a>` `<M-s>` `<M-d>` `<M-y>` `<M-x>`
`<M-e>` `<M-q>` `<M-m>`, `<M-arrows>`) and `<M-LeftMouse>` reach Neovim because kitty.conf has no mapping or
`mouse_map` for them. `ctrl+t` stays unbound in kitty, so `<C-t>` reaches Neovim and fzf's widget. `<C-,>` needs
kitty's keyboard protocol, which is on by default.

## Themes

tokyonight, catppuccin, kanagawa and monokai-pro, each with its styles. `<leader>ot` cycles themes, `<leader>os` cycles
styles, `<leader>ou` picks one from a list, `<leader>oT` toggles transparency. The choice is saved in
`stdpath("data")/theme_state.json` and restored at startup. Highlight overrides from dap, render-markdown and
multicursor are re-applied after every switch through `utils.on_colorscheme`.

## Conventions

- One plugin per file, named after the plugin. Dependencies with no configuration of their own live in
  `lua/plugins/deps/shared.lua` and are referenced by name.
- Comments: one header per file saying what the plugin does, the keys this config binds for it and the keys the plugin
  brings inside its own windows, then end-of-line comments only where the code does not speak for itself.
- Autocommand groups are `999rpm-<name>`, so `:autocmd 999rpm-*` lists everything this config adds.
- which-key entries carrying only a `desc` are labels, not mappings: which-key calls `vim.keymap.set` only for entries
  that also carry an `rhs`. That is how built-in commands get named in the popup without being taken away from Neovim.
- Helpers in `lua/utils.lua` carry an end-of-line note naming the files that call them.
- Icons come from the Nerd Font nf-md range (U+F0001 and up). Older private-use glyphs (U+E000 to U+F8FF) get dropped
  by some copy and paste paths, so the few with no nf-md equivalent, the slanted statusline separators, are written as
  `\u{...}` escapes.
- `.stylua.toml` pins tabs and 140 columns. conform runs stylua on save, so the file has to be present or the whole
  tree reflows to stylua's own defaults on the first write.
