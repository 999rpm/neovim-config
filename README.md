# Neovim config

Neovim 0.12+ (tested on 0.12.5, the current stable), managed by lazy.nvim. One plugin per file under `lua/plugins/<category>/`, editor
settings under `lua/config/`, shared helpers in `lua/utils.lua`. The change log with the reason for every change is in
`AUDIT_SUMMARY.md`.

Markdown doubles as a Logseq-style knowledge base: journals, pages, `[[links]]` with linked and unlinked references,
tags, block references, tasks with an agenda, templates, an outliner that moves and folds bullets together with their
children, and a link graph. The files keep Logseq's layout, so the Logseq app still opens the same folder.

Jupyter notebooks (`.ipynb`) open as markdown and run against real Jupyter kernels: outputs and plots appear under each
cell, the language servers work inside the code cells, and `:w` writes a normal notebook back, outputs included.

97 plugin specs, three of them local (`999rpm-themer`, `999rpm-notes`, `999rpm-ipynb`). A bare `nvim` loads the dozen listed under "What
loads when". Startup time moves with disk cache, terminal and plugin versions; `nvim --startuptime` measures it.

## Install

```sh
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
unzip nvim-config.zip -d ~/.config   # writes ~/.config/nvim, ~/.config/kitty/kitty.conf and ~/.config/moxide/settings.toml
nvim
```

`unzip nvim-config.zip 'nvim/*' -d ~/.config` leaves kitty and markdown-oxide alone.

First launch clones the plugins, then Mason installs the language servers (markdown-oxide among them), formatters,
linters and debug adapters listed in `lua/plugins/lsp/mason.lua`. Parsers build once the tree-sitter CLI is present
(Mason installs it too). `:NotesInit` creates `journals/`, `pages/` and `assets/` in the notes graph. `<leader>pl`
manages plugins, `<leader>pm` manages tools, `<leader>ph` reports what is missing. molten's build step runs
`:JupyterSetup` once: it creates `stdpath("data")/999rpm-jupyter`, installs pynvim, jupyter_client, jupytext,
ipykernel, nbformat, cairosvg and pillow into it, and registers molten's commands. uv does the work when it is on `$PATH`
(it downloads a Python itself if none is installed); otherwise python3's `venv` module and pip do. Running `:JupyterSetup`
again upgrades those packages. An environment built by uv has no pip inside, so after uv is removed, delete the folder
and run `:JupyterSetup` again.

### External binaries

| Tool | Needed for |
| --- | --- |
| git, a C compiler, `make` | plugin installs, treesitter parsers, telescope-fzf-native, `<leader>nc` |
| tree-sitter CLI | parser builds (Mason installs `tree-sitter-cli`) |
| ripgrep, fd | grep pickers, file pickers, grug-far, every notes picker |
| markdown-oxide | links, completion, references and renames in the notes graph (Mason installs it) |
| d2 | d2 diagrams, `d2 fmt` and the notes link graph; one static binary, from `curl -fsSL https://d2lang.com/install.sh \| sh -s --` or the release archive at github.com/terrastruct/d2 |
| Node.js 22+ | Copilot, mcp-hub, the JS/TS servers, js-debug-adapter |
| python3 | debugpy, ruff, basedpyright |
| uv, or python3 with the `venv` module | `:JupyterSetup`, which prefers uv; `<leader>kv` registers a uv project as a kernel |
| ipykernel in other environments (optional) | a micromamba or venv environment becomes a kernel after `python -m ipykernel install --user --name <env>` inside it |
| cairo (optional) | SVG outputs in notebooks, through cairosvg |
| ImageMagick (`magick`) | image conversion for snacks.image (markdown images, math, d2 PNGs) |
| kitty, or another terminal with the kitty graphics protocol | inline images, math and the graph image |
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
after/queries/markdown/     folds.scm: a bullet folds together with its children
snippets/                   markdown snippets (Logseq-style commands), read by blink, edited through nvim-scissors
lua/utils.lua               helpers shared by config and plugin files, the notes_* and notebook_* helpers included
lua/config/
  options.lua               editor options, the notes graph folder, shell detection, filetype rules
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
  ui/                       barbar, lualine, noice, trouble, folds, scrollbar, breadcrumbs
  notes/                    the Logseq layer, markdown-plus, auto-save, render-markdown, img-clip
  notebook/                 Jupyter: molten, otter, the .ipynb handler
  git/                      gitsigns, codediff, gitlinker, octo
  explorer/                 neo-tree, oil, yazi
  debug/                    nvim-dap and its panels
  test/                     neotest
  lang/                     conform, nvim-lint, and the per-language helpers
  ai/                       avante, opencode, mcphub
  deps/shared.lua           library plugins other files reference by name
../kitty/kitty.conf         terminal settings, kept free of the keys Neovim uses
../moxide/settings.toml     markdown-oxide defaults for a Logseq-style graph
```

Everything markdown lives in `notes/`, so the knowledge-base setup reads as one folder. `utils.lua` stays one file: the
helpers are grouped by the file that calls them, and each carries a "used by" note, so a helper with no caller shows up
as dead code.

## Every plugin

| File | Plugin | Loads on |
| --- | --- | --- |
| `core/snacks.lua` | folke/snacks.nvim | startup |
| `core/mini.lua` | nvim-mini/mini.nvim (icons, ai, align, extra, hipatterns) | startup |
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
| `editor/hex.lua` | RaafatTurki/hex.nvim | `<leader>ox` |
| `editor/hardtime.lua` | m4xshen/hardtime.nvim | startup |
| `editor/better-escape.lua` | max397574/better-escape.nvim | insert |
| `editor/guess-indent.lua` | nmac427/guess-indent.nvim | first buffer |
| `editor/numb.lua` | nacro90/numb.nvim | `CmdlineEnter` |
| `editor/matchup.lua` | andymass/vim-matchup | startup (replaces matchit and matchparen) |
| `editor/ts-comments.lua` | folke/ts-comments.nvim | `VeryLazy` |
| `ui/barbar.lua` | romgrk/barbar.nvim | startup |
| `ui/lualine.lua` | nvim-lualine/lualine.nvim | `VeryLazy` |
| `ui/noice.lua` | folke/noice.nvim | startup |
| `ui/trouble.lua` | folke/trouble.nvim | `:Trouble` |
| `ui/ufo.lua` | kevinhwang91/nvim-ufo | first buffer |
| `ui/statuscol.lua` | luukvbaal/statuscol.nvim | first buffer |
| `ui/satellite.lua` | lewis6991/satellite.nvim | first buffer |
| `ui/dropbar.lua` | Bekaboo/dropbar.nvim | first buffer |
| `ui/nvim-bqf.lua` | kevinhwang91/nvim-bqf | `ft=qf` |
| `ui/colorizer.lua` | catgoose/nvim-colorizer.lua | first buffer |
| `ui/modicator.lua` | mawkler/modicator.nvim | `VeryLazy` |
| `ui/stickybuf.lua` | stevearc/stickybuf.nvim | first buffer |
| `ui/colorful-winsep.lua` | nvim-zh/colorful-winsep.nvim | `WinLeave` |
| `ui/tiny-inline-diagnostic.lua` | rachartier/tiny-inline-diagnostic.nvim | `VeryLazy` |
| `notes/logseq.lua` | 999rpm-notes (local spec: the `notes_*` helpers in utils.lua) | `ft=markdown`, `<leader>n*`, `:Journal`, `:NotesInit` |
| `notes/markdown-plus.lua` | YousefHadder/markdown-plus.nvim | `ft=markdown` |
| `notes/auto-save.lua` | okuuva/auto-save.nvim | `ft=markdown` |
| `notes/render-markdown.lua` | MeanderingProgrammer/render-markdown.nvim | `ft=markdown,quarto` |
| `notes/img-clip.lua` | HakonHarnes/img-clip.nvim | `<leader>cp` |
| `notebook/molten.lua` | benlubas/molten-nvim (main branch) | `VeryLazy`, `<leader>k*` |
| `notebook/otter.lua` | jmbuhr/otter.nvim | the first notebook or quarto buffer |
| `notebook/ipynb.lua` | 999rpm-ipynb (local spec: the `notebook_*` helpers in utils.lua) | startup (autocommands only) |
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
| `lang/crates.lua` | saecki/crates.nvim | the first `Cargo.toml` |
| `ai/avante.lua` | avante-corp/avante.nvim | its keys and commands |
| `ai/opencode.lua` | NickvanDyke/opencode.nvim | `<leader>io/ic/iS` |
| `ai/mcphub.lua` | ravitemer/mcphub.nvim | `:MCPHub` |
| `deps/shared.lua` | plenary, nui, nio, coop, promise-async, schemastore, friendly-snippets, neotest-jest, telescope-fzf-native | on demand |

## Notes: a Logseq alternative

The graph is the folder in `vim.g.notes_dir` (`options.lua`), `~/notes` unless `$NOTES_DIR` says otherwise. It keeps
Logseq's layout: `journals/2026_09_30.md`, `pages/`, `assets/`, and the `logseq/` folder the app maintains, which every
search skips. Pages use Logseq's own syntax: bullets indented with tabs, `TODO`/`DOING`/`DONE` markers, `key:: value`
properties, `((uuid))` block references with `id::`, `SCHEDULED: <2026-10-01 Thu>` dates. An existing Logseq graph
works as it is.

Four pieces do the work. markdown-oxide is the language server: completion after `[[` and `#`, `gd` on a link,
references, renames across the graph, "create file" on a missing link. `notes/logseq.lua` adds the Logseq-specific
parts on top, through the `notes_*` helpers in `utils.lua`. markdown-plus makes lists behave like an outliner.
render-markdown and mini.hipatterns draw it. `moxide/settings.toml` tells markdown-oxide about the layout (journal file
names, `pages/` for new pages, case-insensitive names); a `.moxide.toml` at the root of a graph overrides it there.

Inside the graph folder the buffer indents with tabs (a page already indented with spaces keeps them), saves itself a
second after a change, and skips prettier and markdownlint, which would rewrite or flag the outline format.

### Keys

| Key | Action |
| --- | --- |
| `<leader>nn` | Today's journal |
| `<leader>nd` | Journal for a date: `today`, `-1`, `+2`, `fri`, `next mon`, `last tue`, `2026-10-01` |
| `<leader>nj` | Journals, newest first |
| `<leader>np` / `<leader>nN` | Pages / new page |
| `<leader>ns` | Search the text of every page |
| `<leader>nb` / `<leader>nu` | Linked / unlinked references of the current page (its `alias::` names count too) |
| `<leader>nT` | Tags with their counts; picking one lists its references |
| `<leader>nt` | Open tasks: `DOING`/`NOW` first, then `TODO`/`LATER` and unchecked boxes, then `WAITING` |
| `<leader>na` | Agenda: `SCHEDULED` and `DEADLINE` dates, soonest first, overdue in red |
| `<leader>nx` / `<C-CR>` | Cycle the task marker: none, `TODO`, `DOING`, `DONE` (`LATER`, `NOW`, `DONE` on the second workflow); visual mode does every line |
| `<leader>nX` | Mark `CANCELED` (again: back to `TODO`) |
| `<leader>nS` / `<leader>nD` | Set the block's `SCHEDULED` / `DEADLINE` date |
| `<leader>ni` | Insert a template: any block with `template:: name`, `<% today %>`, `<% time %>` and `<% current page %>` filled in |
| `<leader>nz` / `<leader>nZ` | Focus the block under the cursor (everything else folds away) / unfold all |
| `<leader>ng` / `<leader>nG` | Link graph of the current page, as an image / as text |
| `<leader>nc` | Commit the graph folder with git |
| `gf` | Follow the `[[page]]`, `#tag` or `((block ref))` under the cursor; a missing page is created in `pages/` |
| `<C-w>f` | The same in a vertical split, like Logseq's sidebar |
| `<M-j>` / `<M-k>` | Move the bullet together with its children |
| `<CR>` `<Tab>` `<S-Tab>` `<BS>` (insert, in a list) | Next bullet, indent, outdent, remove an empty bullet |
| `<A-CR>` (insert) | New line inside the same bullet |
| `o` / `O` | Open a bullet below / above |
| `\mx`, `\lt` + key, `\t` + key, `\h+` / `\h-` | Checkbox, list type, table commands, heading level (markdown-plus) |
| `:Journal [date]`, `:NotesInit` | Open a journal / create the folders |

Built-in keys that matter here: `gd` or `<C-]>` jump to a link target and `<C-o>` comes back, `grr` lists references,
`grn` renames a page or heading across the graph, `gra` offers "create file" on a missing link, `K` previews a link,
`gO` lists the headings, `]]` / `[[` jump between headings, `za` `zc` `zo` toggle, close and open a block, `zM` / `zR`
every block, `>>` `<<` and insert-mode `<C-t>` / `<C-d>` indent and dedent a line.

### Logseq feature by feature

| Logseq | Here |
| --- | --- |
| Journals, today's page | `<leader>nn`, `<leader>nd`, `<leader>nj`, `:Journal` |
| All pages, new page | `<leader>np`, `<leader>nN` |
| `[[links]]`, autocomplete | markdown-oxide completion in blink; `gf` / `gd` follow a link |
| Tags, `tags::` | highlighted, completed, listed by `<leader>nT` |
| Linked / unlinked references | `<leader>nb` / `<leader>nu`, `grr` for markdown-oxide's list |
| Block references and `id::` | highlighted; `gf` jumps to the block |
| Embeds, `{{query}}` and other macros | highlighted and written by snippets; the Logseq app evaluates them |
| Outliner editing, Shift+Enter | markdown-plus: `<CR>`, `<Tab>`, `<S-Tab>`, `<BS>`, `<A-CR>` |
| Move block (Alt+Shift+Up/Down) | `<M-k>` / `<M-j>` |
| Collapse / expand | `za` `zc` `zo`, `zM` `zR` |
| Zoom into a block | `<leader>nz`, `<leader>nZ` |
| TODO / DOING / DONE, Ctrl+Enter | `<C-CR>`, `<leader>nx`, `<leader>nX` |
| Priorities `[#A]` | highlighted; `priority` snippet |
| Scheduled, deadline, agenda | `<leader>nS`, `<leader>nD`, `<leader>na` |
| Task queries | `<leader>nt` |
| Properties, `alias::`, `title::` | highlighted; aliases and titles count for links and references |
| Templates | `<leader>ni` |
| Search | `<leader>ns`, `<leader>np` |
| Right sidebar | `<C-w>f` |
| Graph view | `<leader>ng` (local graph drawn by d2, shown by kitty), `<leader>nG` as text |
| Assets, image paste | `<leader>cp` into `assets/`, linked as `../assets/...`; snacks.image draws images inline |
| Math, code, `==highlight==` | snacks.image (math), render-markdown |
| Diagrams | ` ```d2 ` blocks, `<leader>ud` / `<leader>uD` |
| Auto save | auto-save.nvim, inside the graph folder only |
| Git auto commit | `<leader>nc`, on demand |
| Favourites, recent pages | harpoon (`<leader>ha`, `<leader>hh`), `<leader>fr` |
| Page outline | `gO` |
| Slash commands | snippets in `snippets/markdown.json`: `scheduled`, `deadline`, `date`, `time`, `query`, `embedpage`, `embedblock`, `blockref`, `template`, `property`, `priority`, `callout`, `code`, `math`, `d2`, `table` |
| Page history | `<leader>gC` (commits of the file), lazygit |

Not covered: whiteboards (d2 files serve diagram-style boards), PDF highlights, flashcards with spaced repetition and
Datalog queries have no terminal counterpart worth the weight. `{{query}}` blocks stay readable text in Neovim and keep
working in the Logseq app.

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
| `<leader>d` | Diagnostics: `dd`/`dD` all / buffer in Trouble, `df` line float, `db`/`dw` buffer / all to quickfix, `ds` symbols, `dl` LSP locations, `dq` quickfix in Trouble |
| `<leader>D` | Debug: breakpoints, stepping, REPL, UI, virtual text |
| `<leader>e` | Explorers: neo-tree, oil, yazi, pick a window (`ew`), files in the buffer's directory |
| `<leader>f` | Find files: files, git files, buffers, recent, config, plugin sources, projects |
| `<leader>g` | Git: hunks, blame, lazygit, browse, commits, status, branches, permalinks |
| `<leader>go` | GitHub through Octo |
| `<leader>G` | Review workspace (codediff) |
| `<leader>h` | Harpoon |
| `<leader>i` | AI: avante, opencode |
| `<leader>j` / `<leader>J` | Flash: jump anywhere visible / select a treesitter node |
| `<leader>k` | Kernel and notebook (Jupyter): start, restart, interrupt, run the cell / line / a motion / everything, outputs, export, new notebook, register a uv project (`kv`) |
| `<leader>l` | LSP: definitions, references, symbols, calls; `lwa` `lwr` `lwl` add, remove, list workspace folders |
| `<leader>m` | Multicursor |
| `<leader>n` | Notes graph: journals, pages, references, tasks, agenda, tags, templates, focus, graph, commit |
| `<leader>o` | Toggles, and only toggles: numbers, wrap, spell, diagnostics, inlay hints, indent guides, dimming, reference highlights, treesitter context, format on save, git blame, hex view, hardtime |
| `<leader>p` | Plugins and tools: `pl` Lazy, `pm` Mason, `pc` Conform info, `ph` checkhealth |
| `<leader>q` | Sessions, `qq` quit window, `qa` quit all |
| `<leader>r` | Search and replace across files (grug-far) |
| `<leader>s` | Search contents: grep, help, keymaps, commands, diagnostics, marks, undo, todos, resume |
| `<leader>t` | Terminals: float, vertical, horizontal, btop |
| `<leader>T` | Tests |
| `<leader>u` | UI and theme: `ut`/`uT` theme and transparency, `uc`/`uC` style, `uu` undo tree, scratch, zen, zoom, breadcrumbs, markdown, image float, d2 (`ud` image, `uD` text) |
| `<leader>y` | Yank and registers: `yp`/`yP` paste the last yank, `yd`/`yD` and `yc`/`yC` delete and change without yanking, `yf`/`yF` copy the file path |
| `<leader>a` / `<leader>A` | Swap the parameter under the cursor with the next / previous one |
| `<leader><Tab>` | Tabs |
| `<localleader>` | Buffer-local keys: markdown-plus in markdown (`\m` format and links, `\l` lists, `\t` tables, `\h` headings), codediff reviews, grug-far and Octo |

### Non-leader keys

| Key | Action |
| --- | --- |
| `<M-h>` / `<M-l>` | Previous / next buffer, in tabline order (`]b`/`[b` also cycle) |
| `<M-w>` `<M-a>` `<M-s>` `<M-d>` | Move between windows, terminal mode included |
| `<M-y>` / `<M-x>` / `<M-e>` / `<M-q>` | Split vertical / horizontal / equalize / close |
| `<M-Up>` `<M-Down>` `<M-Left>` `<M-Right>` | Resize the current window |
| `<M-j>` / `<M-k>` | Move the line or selection; in the notes graph, the bullet with its children |
| `<C-s>` | Write |
| `<C-,>` | Toggle the floating terminal, from normal and terminal mode |
| `<C-a>` / `<C-x>` | Increment / decrement, widened to dates, booleans and semver by dial.nvim |
| `gA` + case key | Change the case of the word, or of the selection in visual mode |
| `gl` / `gL` + motion, then a character | Align on that character (`glip=`); `gL` previews first |
| `%` `g%` `[%` `]%` `z%`, `a%` `i%` | Matching pair or word, previous, enclosing open / close, into the next pair; the pair as a text object |
| `dm` + mark, `dm!` | Delete that mark / every lowercase mark |
| `ys` `ds` `cs`, visual `gs` / `gS` | Add, delete, change a surrounding pair |
| `gco` / `gcO` / `gcA` | Comment on a new line below / above / at the end of the line |
| `vag` / `yag` / `=ig` | Select / yank / reindent the whole buffer (mini.ai's `g` object) |
| `]c` `[c` | Git hunks (Neovim's own change jumps in diff mode) |
| `]r` `[r` | Next / previous occurrence of the symbol under the cursor |
| `]m` `[m` / `]M` `[M` | Function start / end, from treesitter, in every language |
| `]k` `[k` `],` `[,` `]j` `[j` | Class, parameter, JSX element (in notebooks, quarto and `# %%` scripts `]j` `[j` move by cell) |
| `]e` `[e` / `]w` `[w` | Next / previous error / warning (`]d` `[d` stay every severity) |
| `ij` / `aj` | A cell's code without / with its fence or `# %%` line |
| `<S-CR>` / `<C-CR>` | In notebooks: run the cell and go to the next / run it in place, insert mode included |
| insert `,` `.` `;` | Insert the character and start a new undo step |
| `]n` `[n` | Todo comments (normal mode; the visual-mode pair is Neovim's node selection) |
| `[u` | Jump to the enclosing context line |
| `gd` / `gD` | Definition / declaration, where a server answers them |
| `gf` / `<C-w>f`, `<C-CR>` | In the notes graph: follow a link / in a split, cycle a task |
| `<C-Up>` / `<C-Down>`, `<M-LeftMouse>` | Add a cursor above / below, at the click |
| `zR` / `zM` | Open / close all folds through nvim-ufo |

Case keys after `gA`: `c` camelCase, `p` PascalCase, `s` snake_case, `u` UPPER_CASE, `k` kebab-case, `d` dot.case,
`/` path/case, `n` numeronym, `Space` space case.

### Built-in keys stay built-in

No personal key takes a built-in command away. A personal key sits on a built-in only when it does the same job
better: `<C-a>`/`<C-x>` through dial, `n`/`N` centred, `gd`/`gD` and `grn` through the language server, `]m`/`[m`/`]M`/`[M`
through treesitter, `zR`/`zM` through ufo, `a`/`i` text objects through mini.ai, `%` through matchup (which also pairs
`function`/`end` and HTML tags), and in
the notes graph `gf`/`<C-w>f`, which still hand a plain file path to the built-in. `K` is Neovim's own LSP hover
(rustaceanvim's hover actions in Rust buffers). hardtime wraps `h` `j` `k` `l` `J` `x` `X` and a few more to count
repeats; each still does its built-in job. hardtime turns the arrow keys off, which is why resizing sits on
`<M-arrows>`.

Earlier versions of this config, and two of markdown-plus's defaults, took these built-ins; all of them are back:

| Key | Built-in job | The personal action now |
| --- | --- | --- |
| `;` `,` | Repeat `f`/`t` forward / back | `:` opens the command line |
| `q` | Record a macro | `<leader>qq` quits the window |
| `x` `X` | Delete a char, yanking it | `<leader>yd` deletes without yanking |
| visual `p` | Paste, yanking the replaced text | visual `P` pastes without yanking (built-in) |
| `<C-q>` | Blockwise visual | `<leader>qq` |
| `H` `L` | Window top / bottom | `<M-h>` `<M-l>` for buffers |
| `f` `F` | Character search | `<leader>j` `<leader>J` for flash |
| `s`, visual `S` | Substitute | visual `gs` / `gS` for surround |
| visual `R` | Replace lines | flash's `R` only after an operator |
| `g]` | `:tselect` for the word | mini.ai's edge jumps are off |
| `<C-LeftMouse>` | Jump to tag | `<M-LeftMouse>` for multicursor |
| `]f` `[f` | Open the file under the cursor | functions moved to `]m` `[m` |
| `]]` `[[` | Section motions (next heading in markdown) | references moved to `]r` `[r` |
| `zr` | Fold one level less | ufo's variant dropped |
| `<Left>` `<Right>` `<End>` on the command line | Move the cursor | blink's command-line preset trimmed |
| insert `<C-t>` | Indent the line | markdown-plus's checkbox toggle dropped; `\mx` toggles a checkbox |
| `]b` `[b` | Next / previous buffer | markdown-plus's code-block jumps dropped |

Built-ins worth knowing are listed at the top of `lua/config/mappings.lua`.

### Neovim 0.12 keys this config leaves alone

`which-key.lua` labels the `g`-prefixed ones, because built-in *commands*, unlike keymaps, appear in no keymap table and
so cannot be discovered by anything:

| Key | Action |
| --- | --- |
| `K` | Hover documentation (LSP) |
| `grn` `gra` `grr` `gri` `grt` `grx` `gO` | Rename, code action, references, implementation, type definition, code lens, symbols |
| `<C-s>` (insert) | Signature help |
| `<C-t>` / `<C-d>` (insert) | Indent / dedent the line |
| `]d` `[d` / `]D` `[D` | Next, previous / last, first diagnostic |
| `<C-w>d` | Diagnostic float for the line |
| `]q` `[q` / `]l` `[l` | Quickfix / location list |
| `]b` `[b` / `]a` `[a` / `]t` `[t` | Buffers / argument list / tags |
| `]<Space>` `[<Space>` | Blank line below / above |
| `an` / `in` | Select the parent / child treesitter node (visual and operator-pending) |
| `]n` `[n` (visual) | Grow the selection by node |
| `gq` / `gw` | Format lines; `gw` keeps the cursor where it was |
| `ZZ` / `ZQ` / `ZR` | Write and close / close without writing / restart Neovim with the session kept |
| `:Undotree` | The undo tree as a window (`<leader>uu` loads the package that ships it) |

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

Live sources (grep, git grep, workspace symbols, notes search) open with the prompt focused, since they need a query
before there is anything to list.

## What loads when

A bare `nvim` loads snacks, mini, barbar, noice, hardtime, rustaceanvim, matchup, the theme switcher and its current
colorscheme, mason, lazy and nui, then which-key on `VimEnter`. The dashboard draws from snacks, and nothing else has
run. The notes layer waits for a markdown buffer or a `<leader>n` key.

Opening a file adds the language servers, treesitter, completion, git signs and the rest. A markdown file adds the notes
layer, markdown-plus, auto-save and render-markdown; a page of the notes graph brings the count to 40. The installers
behind Mason wait for `VeryLazy`, so a tool download is never on the path of opening a file, and the debug stack waits
for a `<leader>D` key. molten waits for `VeryLazy` too; its commands exist from startup through Neovim's remote-plugin
manifest, which is why `rplugin` is no longer among the disabled runtime plugins. The `.ipynb` handler is three
autocommands registered at startup, and otter loads with the first notebook.

mason-lspconfig does not name nvim-lspconfig, because version 2 carries its own package mappings and the entry would
force lspconfig to load at startup. barbar does not name gitsigns, because it reads `b:gitsigns_status_dict` through a
`pcall` and its git-count icons are off by default. No file names mini.icons: mini loads at priority 1000, before
anything that draws an icon.

## Diagnostics

tiny-inline-diagnostic draws the cursor line's diagnostics inline, long messages wrapped below; every other line keeps
only its sign, so the text stays readable. `<leader>df` opens the full float with related locations, `<leader>db` and
`<leader>dw` fill the quickfix list, `<leader>dd` opens Trouble, `<leader>od` hides everything. The source shows only when
several tools report on one line. A missing debug adapter is reported when its session starts, not when nvim-dap loads.

## Markdown and d2

render-markdown draws headings, bullets, checkboxes, callouts, tables, `==highlights==` and wiki links in place
(`<leader>um` toggles it) and owns markdown's conceal level: hidden markup while rendered, all of it visible in insert
mode. snacks.image draws images and ` ```math ` blocks inline, straight into the kitty window; `<leader>ui` opens the one
under the cursor in a float. render-markdown's own LaTeX output is off, so formulas are not drawn twice.

d2 replaces mermaid. mermaid's CLI renders through a headless Chromium; d2 is one static binary that writes SVG, PNG and
text itself. `.d2` files and ` ```d2 ` blocks in markdown get treesitter highlighting from tree-sitter-d2. `<leader>ud`
renders the diagram under the cursor to PNG and opens it beside the source, reusing the same split on the next press;
kitty draws it through snacks.image. `<leader>uD` renders the same diagram as box-drawing text in a split, which works in
any terminal; `q` closes it. In a `.d2` file the whole file is the diagram; in markdown it is the ` ```d2 ` block holding
the cursor. A dark background renders with d2's Dark Mauve theme, a light one with its default. conform runs `d2 fmt`
on save. The notes link graph (`<leader>ng`, `<leader>nG`) goes through the same renderer.

## Notebooks (Jupyter)

`nvim analysis.ipynb` converts the notebook with jupytext into markdown: text cells stay markdown, code cells become
` ```python ` fences, and the jupytext header keeps the kernelspec. The kernel named there starts on open and the saved
outputs reappear under their cells. `<S-CR>` runs the cell and moves to the next one, as Shift+Enter does in JupyterLab;
`<C-CR>` runs it in place; `<leader>ka` runs everything up to the cursor, `<leader>kA` the whole notebook. Output shows as
virtual lines under the closing fence; images go through snacks.image into kitty. `<leader>ke` enters the output window
for long output, `<leader>kp` opens an image in a viewer, `<leader>kb` sends HTML output to the browser.

`:w` converts back with `jupytext --update`, which replaces the inputs and keeps the outputs and metadata already in the
file, then exports the outputs run in this session. A notebook jupytext cannot read opens as JSON and is written back
unchanged. `:NotebookNew name` or `<leader>kN` starts a new notebook with one empty Python cell; `nvim new.ipynb` does too.

Inside code cells otter gives the usual language-server keys: `K`, `gd`, `grr`, `grn`, `gra`, completion and
diagnostics. `]j` `[j` move by cell, `ij` `aj` select one (so `<leader>ko` then `ij` runs it). The same motions, text
objects and `<leader>k` keys work in any file split into cells by `# %%` lines, the percent format jupytext writes for
scripts, and in quarto documents.

The kernel picker (`<leader>ki` on a buffer with no kernel) lists every installed kernelspec. In a uv project,
`<leader>kv` (`:JupyterKernelAdd [name]`) adds one: it runs `uv add --dev ipykernel` and writes a kernelspec that starts
the project's `.venv`, with `VIRTUAL_ENV` set so `!uv pip install` in a cell installs into the project. A micromamba or
venv environment appears there once `python -m ipykernel install --user --name <env>` has been run inside it. A cell run
while its kernel is still starting waits for it, so its output is not lost. The statusline names the buffer's kernel. `:checkhealth molten` reports missing Python packages; `:JupyterSetup` reinstalls them. Not
available compared with JupyterLab: widgets and in-editor HTML.

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
command. The d2 renders, the git calls behind the statusline and `<leader>nc`, the format checks, every notes search
(ripgrep), `:JupyterSetup`, `:JupyterKernelAdd` and the jupytext conversions pass an argument list to `vim.system`,
with no shell in between, so they behave the same under zsh and nushell. Kernels are started by jupyter_client from their kernelspec, not by the
shell.

`<C-s>` always reaches Neovim: its terminal UI switches the tty to raw mode, which turns off XON/XOFF flow control. At the
zsh prompt the same key still freezes output unless `.zshrc` has `unsetopt FLOW_CONTROL`; the current `.zshrc` does not
set it. Nushell does not take the key at all.

## Kitty

`shell .` in `kitty.conf` makes kitty follow the login shell too. kitty.conf binds `ctrl+shift+*` and `alt+1`..`alt+9`;
Neovim here uses neither, which a dump of every keymap confirms. Its Alt keys (`<M-h>` `<M-l>` `<M-j>` `<M-k>` `<M-w>`
`<M-a>` `<M-s>` `<M-d>` `<M-y>` `<M-x>` `<M-e>` `<M-q>` `<M-m>`, `<M-arrows>`, insert-mode `<A-h/j/k/l>` and `<A-CR>`)
and `<M-LeftMouse>` reach Neovim because kitty.conf has no mapping or `mouse_map` for them. `ctrl+t` stays unbound in
kitty, so `<C-t>` reaches Neovim and fzf's widget. `<C-,>`, `<C-CR>` and `<S-CR>` need kitty's keyboard protocol, which is on
by default and which Neovim switches on; `ctrl+enter` and `shift+enter` stay unbound in kitty.conf for that reason.

## Themes

tokyonight, catppuccin, kanagawa and monokai-pro, each with its styles; a first run opens tokyonight's moon style. `<leader>ut` cycles themes, `<leader>uc` cycles
styles, `<leader>uC` picks one from a list, `<leader>uT` toggles transparency. The choice is saved in
`stdpath("data")/999rpm-theme.json` and restored at startup. Highlight overrides from dap, render-markdown, multicursor,
the notes layer and barbar's slanted separators are re-applied after every switch through `utils.on_colorscheme`.

barbar draws every buffer between U+E0BC and U+E0BA, so both tab edges lean the same way. The separator colours come
from the theme: the corner takes the tabline fill and the glyph background the tab's own colour, the way lualine colours
its section edges. With a transparent background there is no fill colour to take, and the theme's separator colours stay.

kanagawa (lotus, wave, dragon) brings no barbar colours of its own, so its current tab is also underlined from edge to
edge in the tab's text colour; tokyonight, catppuccin and monokai-pro mark the current tab with their own colours.
`underline_themes` at the top of `ui/barbar.lua` lists the themes that get the underline.

## Conventions

- One plugin per file, named after the plugin. Dependencies with no configuration of their own live in
  `lua/plugins/deps/shared.lua` and are referenced by name. A `dependencies` entry is kept only where it changes load
  order in a way the plugin needs; a plugin that is already loaded at startup is never listed.
- Comments: one header per file saying what the plugin does, the keys this config binds for it and the keys the plugin
  brings inside its own windows, then end-of-line comments only. No full-line comment appears below a file's header.
- Names that belong to this config carry `999rpm`: autocommand groups are `999rpm-<n>` (`:autocmd 999rpm-*` lists them),
  buffer-local variables `b:_999rpm_*`, highlight groups `999rpmNotes*`, the local specs `999rpm-themer`,
  `999rpm-notes` and `999rpm-ipynb` (all `virtual = true`: no repository, no runtimepath entry), the Jupyter
  environment `999rpm-jupyter/`, the terminal env var `NVIM_999RPM_TERM`, the theme state file `999rpm-theme.json`, the d2 cache
  `999rpm-d2/`, the d2 text buffer `999rpm://d2-text`, picker sources `999rpm_*`, and notes commits start with
  `999rpm: notes`.
- which-key entries carrying only a `desc` are labels, not mappings: which-key calls `vim.keymap.set` only for entries
  that also carry an `rhs`. That is how built-in commands get named in the popup without being taken away from Neovim.
- Keymap descriptions are sentence case, with no trailing period and no repetition of the group name.
- Helpers in `lua/utils.lua` carry an end-of-line note naming the files that call them, so a helper with no caller
  shows up as dead code.
- Icons come from the Nerd Font nf-md range (U+F0001 and up). Older private-use glyphs (U+E000 to U+F8FF) get dropped
  by some copy and paste paths, so the few with no nf-md equivalent, the slanted separators in barbar and lualine, are
  written as `\u{...}` escapes.
- Local specs are `virtual = true` with a slash-less name. Two local specs sharing one `dir` are merged by lazy.nvim
  into one plugin, which is how the theme switcher once stopped running.
- `.stylua.toml` pins tabs and 140 columns. conform runs stylua on save, so the file has to be present or the whole
  tree reflows to stylua's own defaults on the first write.

## Structure notes

The layout holds up: one category folder per concern, one plugin per file, shared code in one place. Two changes are
worth making only if the config keeps growing. `utils.lua` is over 1,500 lines, most of them the notes and notebook
helpers; moving those into `lua/notes.lua` and `lua/notebook.lua` (with the same "used by" notes) would leave `utils.lua`
for the helpers several files share.
The modules `config`, `plugins` and `utils` are generic names; no installed plugin ships a module with those names today,
and a `lua/999rpm/` prefix would rule the clash out for good.
