# 999rpm/nvim

## Requirements

- **Neovim 0.12+.** Required by `nvim-treesitter`'s `main` branch.
- `git`, `curl`, `tar` — lazy.nvim and treesitter both shell out to these.
- A C compiler on `$PATH` (`cc`/`gcc`/`clang`) — needed to build treesitter parsers.
- A [Nerd Font](https://www.nerdfonts.com/), set as your terminal's font. Icons and statusline separators are Private Use Area glyphs; without one they render as blank boxes or invisible glyphs.
- `ripgrep` and `fd` for Telescope/fzf-lua. Optional — search falls back to slower built-ins without them.
- Node.js, if you want Copilot, mcphub.nvim, or the JS/TS/CSS/HTML/Tailwind language servers.
- The `tree-sitter` CLI installs automatically via Mason on first launch — see `plugins/treesitter/treesitter.lua` for details.
- A terminal that supports the Kitty graphics protocol (kitty itself, and most modern terminals) for `snacks.nvim`'s inline image/LaTeX-math rendering. Everything else in this config still works without one.
- Optional, only needed for specific plugins/git/lang-tools additions: `make` (avante.nvim's build step), the `gh` CLI, authenticated (octo.nvim), the `yazi` binary (yazi.nvim), `cargo`/`clippy` (rustaceanvim, for Rust projects), an `ANTHROPIC_API_KEY` environment variable (avante.nvim) — each one warns once at startup instead of failing silently if missing; see that plugin's own file.

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
│   └── lazy.lua             -- bootstraps lazy.nvim, hands off to plugins/loader.lua
└── plugins/
    ├── loader.lua            -- explicitly imports every folder below (lazy.nvim won't do this on its own — see the file's own comment for why; named loader.lua rather than init.lua so it can never collide with the basename of the root init.lua above)
    ├── lsp/                  -- native vim.lsp.config()/vim.lsp.enable(), Mason, lazydev, inc-rename, symbol-usage, rustaceanvim (Rust's own LSP client — kept separate from the rest, see its own file header)
    ├── completion/           -- blink.cmp, copilot, autopairs
    ├── treesitter/           -- parsers, sticky context, rainbow delimiters, hlargs (parameter highlighting)
    ├── editor/                -- flash, harpoon, mini.ai/mini.icons, surround, comment, todo-comments, persistence, hardtime, grug-far, treesj, text-case, nvim-scissors, dial, multicursor, guess-indent, neogen, etc.
    ├── ui/                    -- statusline, bufferline, dashboard, theming, folding, noice, window-picker, stickybuf, satellite, nvim-bqf, modicator, colorful-winsep
    ├── git/                   -- gitsigns, diffview, gitlinker, octo, git-conflict
    ├── explorer/              -- neo-tree, oil, yazi
    ├── search/                -- telescope, fzf-lua
    ├── debug/                 -- nvim-dap and friends
    ├── test/                  -- neotest
    ├── lang-tools/            -- conform (format), nvim-lint
    ├── terminal/              -- toggleterm
    ├── ai/                    -- avante, opencode, mcphub (agentic AI tools — copilot is separate, in completion/)
    ├── frontend/              -- boundary, template-string, tw-values (React/Tailwind-specific, ft-gated)
    └── deps/                  -- shared library plugins (plenary, nui) with nothing of their own to configure — centralized so "what does this run on" is one file, not a grep. nvim-web-devicons is not one of these anymore: plugins/editor/mini.lua's mini.icons replaced it outright.
```

## License

No license restrictions. Use, modify, or copy any part of it.
