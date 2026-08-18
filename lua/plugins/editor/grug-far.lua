-- MagicDuck/grug-far.nvim: project-wide find & replace in a real, editable buffer (live preview,
-- undo-able, multi-file) — a different tool than plugins/search/telescope.lua's live_grep or
-- plugins/search/fzf.lua's live_grep: those FIND, this REPLACES. Given its own `<leader>r`
-- namespace rather than nested under `<leader>s`: upstream's commonly-suggested `<leader>sr` is
-- already this config's LSP "Goto References" (plugins/lsp/lspconfig.lua, via telescope.lua's
-- LspAttach block) — reusing it here would shadow that, not extend it.
--
-- Buffer-local keymaps inside the grug-far buffer itself default to <localleader> (its own
-- README flags this as something to have configured) — already set to ";" in options.lua,
-- nothing further needed for those to work.
return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	opts = {
		headerMaxWidth = 80,
	},
	keys = {
		{
			"<leader>rr",
			function()
				require("grug-far").open({})
			end,
			mode = { "n", "x" },
			desc = "Search & Replace",
		},
		{
			"<leader>rw",
			function()
				require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
			end,
			desc = "Replace Word Under Cursor",
		},
		{
			"<leader>rf",
			function()
				local ext = vim.bo.buftype == "" and vim.fn.expand("%:e") or nil
				require("grug-far").open({
					prefills = { filesFilter = ext and ext ~= "" and ("*." .. ext) or nil },
				})
			end,
			desc = "Replace In Current File Type",
		},
	},
}
