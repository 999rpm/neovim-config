# 999rpm/nvim

My Neovim config. From scratch, no distro (no LazyVim/NvChad/AstroNvim underneath), because I wanted to actually know what my editor was doing instead of inheriting someone else's defaults and working around them.

Fair warning before you go digging through `lua/`: there are a lot of comments in here. I'm still learning a fair chunk of these motions and plugins myself, so past-me left notes for future-me — what a key does, whether it's shadowing something Neovim already gives you for free, why a plugin is configured the weird way it's configured. If you just want the editor, ignore all of that. If you're the type who reads other people's dotfiles for ideas, the comments are probably more useful to you than this file is.

## Requirements

- **Neovim 0.12+.** Not a suggestion — `nvim-treesitter`'s `main` branch won't load on anything older, and that's not something this config can paper over.
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

Every plugin folder maps to one thing you'd actually describe out loud — "the git stuff," "the debug stuff." If you're looking for where something lives and the name isn't obvious, that's probably why.

## What's actually in here

**LSP is native, not `nvim-lspconfig`'s old `setup()` pattern.** `vim.lsp.config()` + `vim.lsp.enable()`, Mason wired through `mason-lspconfig`'s `automatic_enable = false` so this config decides what gets enabled instead of Mason deciding for it. 18 language servers, one Haskell setup that deliberately lives outside Mason (GHCup manages the whole Haskell toolchain better than Mason does — documented in `lspconfig.lua` if you want the actual argument, not just the conclusion).

**Completion is blink.cmp**, not nvim-cmp. Faster, fewer moving parts, and I didn't need the fifteen nvim-cmp source plugins I'd accumulated over the years.

**Folding is nvim-ufo**, chained lsp → treesitter → indent, so you get real LSP-aware folds where a server supports them and a sane fallback everywhere else.

**The statusline and bufferline use genuinely obscure separator glyphs** (Powerline Extra Symbols, not the common arrow set) — if you open these files in something without a proper Nerd Font, the separator strings will *look* empty. They aren't. This tripped up an AI audit of this very config, which is a decent illustration of exactly the kind of thing that's easy to get confidently wrong when you trust what you can see instead of what's actually there.

**Where a plugin duplicates something Neovim now ships natively** (comment toggling, some diagnostic navigation), it's kept anyway when it does something real the native version doesn't — and it says so in a comment, rather than silently shadowing a keymap you'd otherwise assume still does the built-in thing.

**Dependencies are kept flat on purpose.** No mini.nvim-as-a-monolith for one feature — if I only wanted `mini.ai`, I took `mini.ai`, and single-purpose things (buffer deletion, color highlighting) are standalone plugins instead of pulled in as a side effect of a bundle.

## Keys

Leader is `<Space>`, localleader is `;`. Everything under `<leader>` is grouped in which-key — hit space and wait, or check `plugins/ui/which-key.lua` for the full group layout. I'm not going to reproduce a keybinding table here that'll drift out of sync with the actual config the moment I change something; which-key is the source of truth because it's incapable of lying to you about what's currently mapped.

## Themes

Three, cycled with a keymap (check which-key — `<leader>o` for options): tokyonight, catppuccin, kanagawa. Current theme and style persist across restarts.

## `AUDIT_SUMMARY.md`

A running, dated log of non-obvious changes and why they happened, kept separate from the per-file comments on purpose — file headers describe what a file currently does, this file describes what changed and why someone might have gotten there. Skip it unless you're wondering why something is configured the way it is and the inline comment doesn't say.

## Credit where it's due

This didn't come from nowhere. Structure, LSP handling, and more than a few specific settings were shaped by reading through:

- [jdhao/nvim-config](https://github.com/jdhao/nvim-config) — the closest thing to a spiritual template here; a lot of the LSP attach/keymap logic started as a direct read of his.
- [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public) — `lua_ls` tuning in particular.
- [xero/dotfiles](https://github.com/xero/dotfiles) — schemastore wiring, some diagnostic sign choices.
- [rafi/vim-config](https://github.com/rafi/vim-config) — the right-click context menu in `autocmds.lua` is adapted from here almost directly.

None of these are copy-pasted wholesale — go read them yourselves, they're all better documented than most software you'll pay for.

## License

Do whatever you want with it. If something in here saves you an afternoon, that's the whole point of putting it up publicly.
