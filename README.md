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
| btop | `<leader>tm` |
| cargo | avante's build step |
| A Nerd Font | icons in the tabline, statusline, pickers and trees |

## Layout

```
init.lua                    entry point: options, autocmds, mappings, lazy
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
  treesitter/               treesitter, context, rainbow-delimiters, hlargs
  editor/                   motions, text objects, search and replace, snippets, todo comments
  ui/                       barbar, lualine, noice, trouble, folds, scrollbar, breadcrumbs
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
or `<leader>sk` to search every mapping.

### Leader groups

| Prefix | Group |
| --- | --- |
| `<leader>b` | Buffers: pick, pin, move, close left/right/others, reopen |
| `<leader>c` | Code: format, annotate, split/join, snippets (`cs`), paste image, Tailwind values |
| `<leader>d` | Trouble lists |
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
| `<leader>n` | No-yank edits, path yanks, register pastes |
| `<leader>o` | Options and toggles: numbers, wrap, spell, theme, format on save, inlay hints |
| `<leader>q` | Sessions |
| `<leader>r` | Search and replace (grug-far) |
| `<leader>s` | Search: grep, help, keymaps, commands, diagnostics, marks, undo, todos, resume |
| `<leader>t` | Terminals: float, vertical, horizontal, btop |
| `<leader>T` | Tests |
| `<leader>u` | UI: scratch, zen, zoom, breadcrumb pick, markdown render, dismiss notifications |
| `<leader>w` | LSP workspace folders |
| `<leader>x` | Diagnostics under the cursor |
| `<leader><Tab>` | Tabs |
| `<localleader>` | Review-buffer actions (codediff) |

### Non-leader keys

| Key | Action |
| --- | --- |
| `;` | Command line (native repeat of `f`/`t` is given up) |
| `H` / `L` | Previous / next buffer |
| `<M-w>` `<M-a>` `<M-s>` `<M-d>` | Move between windows, terminal mode included |
| `<M-y>` / `<M-x>` / `<M-e>` / `<M-q>` | Split vertical / horizontal / equalize / close |
| Arrow keys | Resize the current window |
| `<M-j>` / `<M-k>` | Move the line or selection |
| `<C-s>` / `<C-q>` | Write / quit |
| `<C-a>` | Select the whole buffer |
| `<C-,>` | Toggle the floating terminal, from normal and terminal mode |
| `>` / `<` | Increment / decrement numbers, dates, booleans (dial.nvim) |
| `s` / `S` | Flash jump / treesitter select |
| `gA` + letter | Case conversion, `gA.` picks from a list |
| `]c` `[c` | Git hunks |
| `]d` `[d` | Diagnostics |
| `]f` `[f` `]k` `[k` `],` `[,` `]j` `[j` | Function, class, parameter, JSX element |
| `]n` `[n` | Todo comments |
| `K`, `grn`, `gra`, `grr`, `gri`, `grt`, `gO` | Neovim's own LSP keys |
| `zR` / `zM` / `zr` | Folds through nvim-ufo |

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

Kitty keeps its own setting: `shell .` in `kitty.conf` makes kitty follow the login shell too,
instead of pinning one shell.

## Themes

tokyonight, catppuccin, kanagawa and monokai-pro, each with its styles. `<leader>ot` cycles themes,
`<leader>os` cycles styles, `<leader>ou` picks one from a list, `<leader>oT` toggles transparency.
The choice is saved in `stdpath("data")/theme_state.json` and restored at startup.

## Conventions

- One plugin per file, named after the plugin. Dependencies with no configuration of their own live
  in `lua/plugins/deps/shared.lua` and are referenced by name.
- Comments: one header per file saying what the plugin does and which keys it owns, then end-of-line
  comments only where the code does not speak for itself.
- Autocommand groups are `999rpm-<name>`, so `:autocmd 999rpm-*` lists everything this config adds.
- Helpers in `lua/utils.lua` carry an end-of-line note naming the files that call them.
