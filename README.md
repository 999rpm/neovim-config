# 999rpm/nvim

## Requirements

- **Neovim 0.12+.** `nvim-treesitter`'s `main` branch won't load on anything older, and that's not something this config can paper over.
- `git`, `curl`, `tar` — lazy.nvim and treesitter both shell out to these.
- A C compiler on `$PATH` (`cc`/`gcc`/`clang`) — needed to build treesitter parsers.
- A [Nerd Font](https://www.nerdfonts.com/), set as your terminal's font. Icons and statusline separators are Private Use Area glyphs — without a Nerd Font they render as blank boxes or nothing at all, not an error, just nothing to look at.
- `ripgrep` and `fd` for Telescope/fzf-lua. Config runs without them but search gets a lot worse.
- Node.js, if you want Copilot or the JS/TS/CSS/HTML/Tailwind language servers.
- The `tree-sitter` CLI gets installed automatically via Mason on first launch — see `plugins/treesitter/treesitter.lua` if you're curious why that's needed at all now.

## Install

```sh
git clone <this-repo> ~/.config/nvim
nvim
```

First launch bootstraps lazy.nvim, installs everything in `lua/plugins/`, and Mason grabs LSP servers, formatters, linters, and debug adapters in the background. It'll be a little slow the first time and take over your terminal with download logs. That's expected — subsequent launches are fast.

`:checkhealth` afterward if anything looks off.

## Layout

```
init.lua                   -- entry point, bootstraps everything, has the full feature list
lua/
├── utils.lua               -- shared helpers, each one tagged with which file(s) actually use it
├── config/
│   ├── options.lua          -- vim.opt, not plugin opts
│   ├── autocmds.lua         -- ditto for autocommands
│   ├── mappings.lua         -- core keymaps that aren't owned by a specific plugin
│   └── lazy.lua             -- bootstraps lazy.nvim, hands off to plugins/init.lua
└── plugins/
    ├── init.lua              -- explicitly imports every folder below (lazy.nvim won't do this on its own — see the file's own comment for why)
    ├── lsp/                  -- native vim.lsp.config()/vim.lsp.enable(), Mason, lazydev
    ├── completion/           -- blink.cmp, copilot, autopairs
    ├── treesitter/           -- parsers, sticky context, rainbow delimiters
    ├── editor/                -- flash, harpoon, mini.ai, surround, comment, todo-comments, etc.
    ├── ui/                    -- statusline, bufferline, dashboard, theming, folding, noice
    ├── git/                   -- gitsigns, diffview
    ├── explorer/              -- neo-tree, oil
    ├── search/                -- telescope, fzf-lua
    ├── debug/                 -- nvim-dap and friends
    ├── test/                  -- neotest
    ├── lang-tools/            -- conform (format), nvim-lint
    ├── terminal/              -- toggleterm
    └── deps/                  -- shared library plugins (plenary, nui, web-devicons) with nothing of their own to configure — centralized so "what does this run on" is one file, not a grep
```

## Credit where it's due

- [jdhao/nvim-config](https://github.com/jdhao/nvim-config) — the closest thing to a spiritual template here; a lot of the LSP attach/keymap logic started as a direct read of his.
- [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public) — `lua_ls` tuning in particular.
- [xero/dotfiles](https://github.com/xero/dotfiles) — schemastore wiring, some diagnostic sign choices.
- [rafi/vim-config](https://github.com/rafi/vim-config) — the right-click context menu in `autocmds.lua` is adapted from here almost directly.

None of these are copy-pasted wholesale — go read them yourselves, they're all better documented than most software you'll pay for.

## License

Do whatever you want with it. If something in here saves you an afternoon, that's the whole point of putting it up publicly.
