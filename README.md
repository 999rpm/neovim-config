# 999rpm/nvim

## Requirements

- **Neovim 0.12+.** Required by `nvim-treesitter`'s `main` branch.
- `git`, `curl`, `tar` — lazy.nvim and treesitter both shell out to these.
- A C compiler on `$PATH` (`cc`/`gcc`/`clang`) — needed to build treesitter parsers.
- A [Nerd Font](https://www.nerdfonts.com/), set as your terminal's font. Icons and statusline separators are Private Use Area glyphs; without one they render as blank boxes or invisible glyphs.
- `ripgrep` and `fd` for Telescope/fzf-lua. Optional — search falls back to slower built-ins without them.
- Node.js, if you want Copilot or the JS/TS/CSS/HTML/Tailwind language servers.
- The `tree-sitter` CLI installs automatically via Mason on first launch — see `plugins/treesitter/treesitter.lua` for details.

## Install

```sh
git clone <this-repo> ~/.config/nvim
nvim
```

First launch bootstraps lazy.nvim, installs the plugins under `lua/plugins/`, and Mason installs LSP servers, formatters, linters, and debug adapters in the background. The first launch is slower and prints installation logs; later launches are not.

Run `:checkhealth` afterward if anything looks off.

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

## License

No license restrictions. Use, modify, or copy any part of it.
