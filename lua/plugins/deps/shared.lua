-- Plugins with more than one consumer and nothing of their own to configure — no `opts`, no
-- `config()`, just a Lua library other plugins `require()` internally. Kept here rather than
-- left as inline `dependencies` entries scattered across every consumer, so "what shared
-- infrastructure does this config actually run on" is answerable by reading one file instead of
-- grepping for a string across a dozen. Same `lazy = true`, no independent trigger pattern as
-- plugins/deps/web-devicons.lua (see that file's own note for exactly how the merge works) —
-- each plugin below still needs every one of its consumers to list it in their own
-- `dependencies` table; that's what actually triggers the load, not this file existing.
--
-- nvim-lua/plenary.nvim: async/job-control/path/test utilities. Consumers (grepped, not
-- eyeballed -- 9 total, 4 more than this list previously named): plugins/explorer/neo-tree.lua,
-- plugins/editor/harpoon.lua, plugins/editor/todo-comments.lua, plugins/search/telescope.lua,
-- plugins/test/neotest.lua, plugins/git/octo.lua, plugins/ai/avante.lua, plugins/ai/mcphub.lua,
-- plugins/explorer/yazi.lua.
--
-- MunifTanjim/nui.nvim: UI component primitives (popup/menu/input/layout). Consumers (grepped --
-- 4 total, 1 more than this list previously named): plugins/explorer/neo-tree.lua, plugins/ui/
-- noice.lua, plugins/editor/hardtime.lua, plugins/ai/avante.lua.
--
-- Deliberately NOT here: kevinhwang91/promise-async (plugins/ui/ufo.lua's only consumer — a
-- single-consumer dependency doesn't need centralizing, there's nothing to deduplicate).
return {
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "MunifTanjim/nui.nvim", lazy = true },
}
