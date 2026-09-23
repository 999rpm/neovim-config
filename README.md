# Neovim config

Neovim 0.12+, managed by lazy.nvim. One plugin per file under `lua/plugins/<category>/`, editor
settings under `lua/config/`, shared helpers in `lua/utils.lua`.

## Install

```sh
# back up anything already there
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

# extract this archive so the folder lands at ~/.config/nvim
unzip nvim-config.zip -d ~/.config
nvim
```

First launch clones the plugins, then Mason installs the language servers, formatters, linters and
debug adapters listed in `lua/plugins/lsp/mason.lua`. Parsers install once the tree-sitter CLI is
present. `:Lazy` manages plugins, `:Mason` manages tools, `:checkhealth` reports what is missing.

### External binaries

| Tool | Needed for |
| --- | --- |
| git, a C compiler, `make` | plugin installs, treesitter parsers, telescope-fzf-native |
| ripgrep, fd | grep pickers, file pickers, grug-far |
| Node.js 22+ | Copilot, mcp-hub, the JS/TS servers and js-debug-adapter |
| python3 | debugpy, ruff, basedpyright |
| lazygit | `<leader>gl` |
| yazi | `<leader>ey` |
| gh (authenticated) | Octo |
| xxd | `<leader>oX` hex view |
| btop | `<leader>tm` |
| cargo | avante's build step |
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
  core/                     snacks, mini, which-key, themes (load first, used by everything else)
  lsp/                      lspconfig, mason, lazydev, inc-rename, symbol-usage, rustaceanvim
  completion/               blink.cmp, copilot, autopairs
  treesitter/               treesitter, textobjects, context, rainbow-delimiters, hlargs, treesj, autotag
  editor/                   motions, text objects, search and replace, snippets, todo comments
  ui/                       barbar, lualine, noice, trouble, folds, scrollbar, breadcrumbs, window picker
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

Leader is `Space`, local leader is `\`. Press the leader and wait for which-key to list what follows,
or `<leader>sk` to search every mapping. Lowercase and uppercase prefixes pair up: the lowercase one
is the common action, the uppercase twin is its wider or rarer form.

### Leader groups

| Prefix | Group |
| --- | --- |
| `<leader>b` | Buffers: pick, pin, move, close left/right/others, reopen |
| `<leader>c` | Code: format, annotate, split/join, snippets (`cs`), paste image, Tailwind values |
| `<leader>d` | Diagnostic lists through Trouble |
| `<leader>D` | Debug: breakpoints, stepping, REPL, UI |
| `<leader>e` | Explorers: neo-tree, oil, yazi, window picker, files in the buffer's directory |
| `<leader>f` | Find files: files, git files, buffers, recent, config, plugins, projects |
| `<leader>g` | Git: hunks, blame, lazygit, browse, commits, status, branches |
| `<leader>go` | GitHub through Octo |
| `<leader>G` | Review workspace (codediff) |
| `<leader>h` | Harpoon |
| `<leader>i` | AI: avante, opencode |
| `<leader>l` | LSP pickers: definitions, references, symbols, calls |
| `<leader>m` | Multicursor |
| `<leader>n` | No-yank edits, path yanks, register pastes, `na` select whole buffer |
| `<leader>o` | Options and toggles: numbers, wrap, spell, theme, format on save, inlay hints |
| `<leader>q` | Sessions |
| `<leader>r` | Search and replace (grug-far) |
| `<leader>s` | Search contents: grep, help, keymaps, commands, diagnostics, marks, undo, todos, resume |
| `<leader>t` | Terminals: float, vertical, horizontal, btop |
| `<leader>T` | Tests |
| `<leader>u` | UI: scratch, zen, zoom, breadcrumb pick, markdown render, dismiss notifications |
| `<leader>w` | LSP workspace folders |
| `<leader>x` | Diagnostics: line float, buffer and workspace quickfix |
| `<leader>a` / `<leader>A` | Swap the parameter under the cursor with the next / previous one |
| `<leader><Tab>` | Tabs |
| `<localleader>` | Review-buffer actions (codediff) |

### Non-leader keys

| Key | Action |
| --- | --- |
| `;` | Command line (native repeat of `f`/`t` is given up) |
| `H` / `L` | Previous / next buffer |
| `f` / `F` | Flash jump / flash treesitter select |
| `<M-w>` `<M-a>` `<M-s>` `<M-d>` | Move between windows, terminal mode included |
| `<M-y>` / `<M-x>` / `<M-e>` / `<M-q>` | Split vertical / horizontal / equalize / close |
| Arrow keys | Resize the current window |
| `<M-j>` / `<M-k>` | Move the line or selection |
| `<C-s>` / `<C-q>` | Write / quit |
| `<C-,>` | Toggle the floating terminal, from normal and terminal mode |
| `<C-a>` / `<C-x>` | Increment / decrement, widened to dates, booleans and semver by dial.nvim |
| `gA` + letter | Case conversion, `gA.` picks from a list |
| `ys` `ds` `cs` | Add, delete, change a surrounding pair; `S` in visual mode |
| `]c` `[c` | Git hunks |
| `]d` `[d` | Diagnostics |
| `]f` `[f` `]k` `[k` `],` `[,` `]j` `[j` | Function, class, parameter, JSX element |
| `]n` `[n` | Todo comments (normal mode; the visual-mode pair is Neovim's node selection) |
| `gd` / `gD` | Definition / declaration, where a server answers them |
| `K`, `grn`, `gra`, `grx`, `grr`, `gri`, `grt`, `gO` | Neovim's own LSP keys |
| `zR` / `zM` / `zr` | Folds through nvim-ufo |

### Neovim 0.12 keys this config leaves alone

0.12 maps far more by default than earlier versions did. None of these are re-bound here, and `which-key.lua`
labels the `g`-prefixed ones because built-in *commands* — as opposed to keymaps — appear in no keymap table
and so cannot be discovered by anything:

| Key | Action |
| --- | --- |
| `]d` `[d` / `]D` `[D` | Next, previous / last, first diagnostic |
| `<C-w>d` | Diagnostic float for the line |
| `]q` `[q` / `]l` `[l` | Quickfix / location list |
| `]b` `[b` / `]a` `[a` / `]t` `[t` | Buffers / argument list / tags |
| `]<Space>` `[<Space>` | Blank line below / above |
| `an` / `in` | Select the parent / child treesitter node (visual and operator-pending) |
| `]n` `[n` (visual) | Grow the selection by node |
| `grx` | Run the code lens under the cursor |
| `gd` `gD` | Local / file-global declaration search, where no server answers |

### Built-ins this config replaces

Every one of these is a deliberate trade, listed with what covers the lost behaviour:

| Taken | Was | Covered instead by |
| --- | --- | --- |
| `;` | Repeat `f`/`F`/`t`/`T` | Nothing; `f` is a flash jump, so a repeat has little to repeat |
| `q` | Record a macro | `@` still replays; recording is off on purpose |
| `x` / `X` | Delete into the unnamed register | Same delete, black-hole register; `d` still yanks |
| `<C-q>` | Blockwise visual | `<C-v>` |
| `H` / `L` | Top / bottom of the window | `M`, `zt`, `zb` |
| `f` / `F` | Char search forward / back | flash jump, which lands anywhere visible |
| `s` | Substitute char | `cl` |
| `R` (visual) | Replace-mode change | flash treesitter search |
| `g]` | `:tselect` on the tag under the cursor | `<C-]>`, `g<C-]>` and `]t`/`[t` still jump through tags |

Kept deliberately after earlier passes moved things off them: `<C-a>`/`<C-x>` increment, `>`/`<`
indent, `<C-e>`/`<C-y>` insert the character below/above, `ga` character info, `]m`/`[m` method
motions, `]]`/`[[` sections, `as`/`is` sentences, `]a`/`[a` argument list, `]p`/`[p` indented paste,
and `an`/`in`, which mini.ai gave back once 0.12 claimed them for node selection — its next-object
pair is `aN`/`iN`, its last-object pair `al`/`il`.

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

Live sources (grep, git grep, workspace symbols) open with the prompt focused, since they need a
query before there is anything to list.

## Terminals

`<leader>tf`, `<leader>tv` and `<leader>th` open a floating, vertical and horizontal terminal. Each
layout is a separate terminal, so toggling one never moves another. A count prefix opens more of
them: `2<leader>tv` is a second vertical terminal. `<C-,>` toggles the float from anywhere, terminal
mode included. `<Esc><Esc>` switches a terminal to normal mode, `q` hides it.

## Shells

`'shell'` follows the login shell recorded in the passwd database, so `chsh` applies to the next
Neovim start rather than the next login. Nushell gets the shell flags from nushell's own Neovim
integration; POSIX shells get Vim's. Changing `'shell'` inside a session re-applies the matching
flags.

`<C-s>` writes the buffer. Under a POSIX shell that still has legacy flow control on, the terminal
swallows `<C-s>` as XOFF before Neovim sees it; `stty -ixon` in `.zshrc` or `.bashrc` frees it.
Nushell does not take `<C-s>`.

Kitty keeps its own setting: `shell .` in `kitty.conf` makes kitty follow the login shell too,
instead of pinning one shell. Nothing here binds `ctrl+shift+*`, which is where kitty's own defaults
live, so the two sets do not overlap. `<C-,>` needs kitty's keyboard protocol, which is on by
default.

## Themes

tokyonight, catppuccin, kanagawa and monokai-pro, each with its styles. `<leader>ot` cycles themes,
`<leader>os` cycles styles, `<leader>ou` picks one from a list, `<leader>oT` toggles transparency.
The choice is saved in `stdpath("data")/theme_state.json` and restored at startup.

## Conventions

- One plugin per file, named after the plugin. Dependencies with no configuration of their own live
  in `lua/plugins/deps/shared.lua` and are referenced by name.
- Comments: one header per file saying what the plugin does and which keys it owns, then end-of-line
  comments only where the code does not speak for itself.
- Autocommand groups are `999rpm-<n>`, so `:autocmd 999rpm-*` lists everything this config adds.
- which-key entries carrying only a `desc` are labels, not mappings: which-key calls `vim.keymap.set`
  only for entries that also carry an `rhs`. That is how built-in commands get named in the popup
  without being taken away from Neovim.
- Helpers in `lua/utils.lua` carry an end-of-line note naming the files that call them.
- `.stylua.toml` pins tabs and 140 columns. conform runs stylua on save, so the file has to be
  present or the whole tree reflows to stylua's own defaults on the first write.
