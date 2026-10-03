# 999rpm's Neovim config

Personal Neovim configuration for Neovim 0.12 and later, managed by [lazy.nvim](https://github.com/folke/lazy.nvim).
One plugin per file, almost all of them lazy-loaded. Besides code editing it covers three extra jobs: a Logseq-style
notes graph on plain markdown, Jupyter notebooks that run against real kernels, and Visual Studio-style projects that are
created from templates, opened from a list and built as tasks.

Written for Neovim 0.12.5 on Linux, with kitty as the terminal, zsh or nushell as the shell, and tmux optional.

## Features

- Language servers through Neovim's own `vim.lsp`, installed by [mason.nvim](https://github.com/mason-org/mason.nvim);
  Rust through [rustaceanvim](https://github.com/mrcjkb/rustaceanvim)
- Completion with [blink.cmp](https://github.com/saghen/blink.cmp), inline suggestions from
  [copilot.lua](https://github.com/zbirenbaum/copilot.lua)
- Formatting with [conform.nvim](https://github.com/stevearc/conform.nvim), linting with
  [nvim-lint](https://github.com/mfussenegger/nvim-lint)
- Pickers, terminals, notifications, dashboard and images from [snacks.nvim](https://github.com/folke/snacks.nvim)
- Treesitter highlighting, text objects and context through
  [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (main branch)
- Git: [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [codediff.nvim](https://github.com/esmuellert/codediff.nvim),
  [octo.nvim](https://github.com/pwntester/octo.nvim), lazygit
- Debugging with [nvim-dap](https://github.com/mfussenegger/nvim-dap), tests with
  [neotest](https://github.com/nvim-neotest/neotest) (jest, pytest, cargo)
- File explorers: [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim), [oil.nvim](https://github.com/stevearc/oil.nvim),
  [yazi.nvim](https://github.com/mikavilpas/yazi.nvim)
- Dependency versions inline for `Cargo.toml` ([crates.nvim](https://github.com/saecki/crates.nvim)) and `package.json`
  ([package-info.nvim](https://github.com/vuki656/package-info.nvim)); root-owned files written with `:SudaWrite`
  ([vim-suda](https://github.com/lambdalisue/vim-suda))
- [d2](https://d2lang.com) diagrams in `.d2` files and in markdown blocks, highlighted through nvim-treesitter and drawn
  by the d2 binary as an image (`<leader>ud`) or as text (`<leader>uD`)
- Notes graph: journals, pages, `[[links]]`, backlinks, tasks, agenda and templates on top of
  [markdown-oxide](https://github.com/Feel-ix-343/markdown-oxide), drawn by
  [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
- Jupyter notebooks through [molten-nvim](https://github.com/benlubas/molten-nvim) and
  [otter.nvim](https://github.com/jmbuhr/otter.nvim); `.ipynb` files open as markdown, and cells are added, cut, split
  and joined with JupyterLab's letters
- Projects: a new-project wizard (C and C++ with a Makefile, Rust, Python through uv, JavaScript through npm), a project
  list from [snacks.nvim](https://github.com/folke/snacks.nvim), builds and tasks through
  [overseer.nvim](https://github.com/stevearc/overseer.nvim) (make, cargo, npm scripts, `.vscode/tasks.json`), and
  `<leader>cr` to build and run the current file
- AI: [avante.nvim](https://github.com/avante-corp/avante.nvim), [opencode.nvim](https://github.com/NickvanDyke/opencode.nvim),
  [mcphub.nvim](https://github.com/ravitemer/mcphub.nvim)
- Themes: tokyonight, catppuccin, kanagawa and monokai-pro, switched and remembered across restarts

## Requirements

- Neovim 0.12+, git, a C compiler, `make`, curl, ripgrep, fd and a [Nerd Font](https://www.nerdfonts.com)
- The tree-sitter CLI for parser builds (Mason installs it)
- Node.js 22+ for Copilot and the JavaScript tooling; python3 or [uv](https://github.com/astral-sh/uv) for the Jupyter setup
- Optional: lazygit, yazi, `gh`, [d2](https://d2lang.com), ImageMagick, xxd, btop, npm
- kitty, or another terminal with the kitty graphics protocol, for images, math and notebook plots

## Install

The archive mirrors the home folder: `.config/nvim`, `.config/kitty/kitty.conf`, `.config/tmux/tmux.conf`,
`.config/nushell`, `.config/moxide`, `.zshrc` and `.zshenv`.

```sh
mv ~/.config/nvim ~/.config/nvim.bak
unzip -o 999rpm-dotfiles.zip -d ~
nvim
```

`unzip -o 999rpm-dotfiles.zip '.config/nvim/*' -d ~` installs the Neovim part alone. The first start clones the plugins
and Mason installs the servers, formatters and linters. `:checkhealth` reports anything missing. `:JupyterSetup` builds
the Python environment the notebooks use, and `:NotesInit` creates the notes folders.

## Layout

```
init.lua              entry point
lua/config/           options, autocommands, keymaps, lazy.nvim bootstrap
lua/plugins/<group>/  one file per plugin: core, lsp, completion, treesitter, editor, ui, git,
                      explorer, debug, test, projects, lang, notes, notebook, ai, deps
lua/utils/            shared helpers by subject: core, shell, statusline, debugger, fences,
                      d2, notes, jupyter, notebook, run, project, themes
after/queries/        markdown folds that keep a bullet with its children
snippets/             markdown snippets for the notes graph
```

## Keys

Leader is `Space`, local leader is `\`. Press the leader and wait for which-key to list what follows, or `<leader>sk`
to search every mapping. Built-in keys keep their jobs.

| Prefix | Group | Prefix | Group |
| --- | --- | --- | --- |
| `<leader>f` | Find files | `<leader>s` | Search contents |
| `<leader>e` | Explorers | `<leader>b` | Buffers |
| `<leader>c` | Code | `<leader>l` | LSP lists |
| `<leader>d` | Diagnostics | `<leader>D` | Debug |
| `<leader>g` | Git | `<leader>G` | Review (codediff) |
| `<leader>t` | Terminals | `<leader>T` | Tests |
| `<leader>n` | Notes graph | `<leader>k` | Jupyter kernel and cells |
| `<leader>o` | Toggles | `<leader>u` | UI and themes |
| `<leader>h` | Harpoon | `<leader>m` | Multicursor |
| `<leader>r` | Replace across files | `<leader>y` | Yank and registers |
| `<leader>i` | AI | `<leader>q` | Sessions and quit |
| `<leader>p` | Plugins and tools | `<leader><Tab>` | Tabs |
| `<leader>w` | Projects and tasks | | |

Outside the leader: `<M-h>`/`<M-l>` previous/next buffer, `<M-w/a/s/d>` move between windows (normal mode), `<M-j>`/`<M-k>` move a
line (and scroll documentation and previews in completion menus and pickers), `<C-s>` write, `<C-,>` floating terminal,
`]e`/`[e` and `]w`/`[w` errors and warnings, `]r`/`[r` references. The header of `lua/config/mappings.lua` lists the
built-in keys worth knowing, and each plugin file lists its own.

## Notes and notebooks

The notes graph lives in `~/notes` (or `$NOTES_DIR`) and keeps Logseq's layout: `journals/`, `pages/`, `assets/`, so
the Logseq app can open the same folder. `<leader>nn` opens today's journal, `<leader>nb` lists backlinks,
`<leader>nt` open tasks, `<leader>na` the agenda.

`nvim file.ipynb` opens a notebook as markdown, starts its kernel and shows the saved outputs. `<S-CR>` runs a cell
and moves to the next one, `<C-CR>` runs it in place, and `:w` writes a normal notebook back, outputs included.
`<leader>ka`/`<leader>kb` add an empty cell above/below, `<leader>kd` cuts the cell (`p` pastes it elsewhere),
`<leader>ks` splits it at the cursor and `<leader>kj` joins it with the next one; the same keys work in quarto
documents and `# %%` scripts.

## Projects

`<leader>wn` asks for a template and a folder (under `~/Coding`, or `$PROJECTS_DIR`), creates the project, puts it under
git and opens it. C and C++ projects get a Makefile with `build`, `release`, `run` and `clean` targets and a
`compile_flags.txt`, so clangd checks the same warnings the build uses. `<leader>wp` lists projects and restores a
project's session on opening it. `<leader>wb` runs the project's build task and opens the quickfix list on errors,
`<leader>wr` picks any task (make targets, cargo, npm scripts, `.vscode/tasks.json`), `<leader>wt` shows the task list.
A lone C or C++ file builds with clang through `:make` or `<leader>wb`, and `<leader>cr` builds and runs it in a split.
A `.nvim.lua` at a project's root holds its own settings once `:trust` approves it.

## Shell and terminal

`'shell'` follows the login shell, so zsh and nushell both work; nushell gets its own `shell*` flags. Key conflicts
resolve kitty first, then the shell, then tmux, then Neovim: `kitty.conf` binds only `ctrl+shift` combinations and
`alt+1` to `alt+9`, none of which Neovim uses here; tmux keeps its default prefix `C-b` (`C-b C-b` sends it on), so no
Neovim mapping sits on `<C-b>`; and a terminal buffer maps no Alt keys, which zsh's vi mode and nushell both use.

Under nushell a `:%!` filter runs nushell's own command of that name: `:%!sort` is nu's `sort`, which rejects plain
text, while `:%!^sort` runs the external program and `:sort` needs no shell at all.

`tmux.conf` turns on extended keys, so `<C-CR>`, `<S-CR>` and `<C-,>` reach Neovim inside tmux, and passthrough, so
images and plots still draw.
