-- kylechui/nvim-surround: add/change/delete surrounding pairs (quotes, brackets, tags).
--
-- `g:nvim_surround_no_normal_mappings` disables Normal-mode defaults (`ys`/`yss`/`yS` add,
-- `cs` change, `ds` delete) while leaving Visual-mode `S`/`gS` untouched (a separate switch,
-- `g:nvim_surround_no_visual_mappings`, left at its own default/off). The `s` -> <Nop> line
-- just above `setup()` frees native Normal/Visual/Operator-pending "substitute" — none of
-- nvim-surround's default keys start with a bare `s`, so the two were never actually in
-- conflict either way. With the flag on, the only way to add a surround is Visual-mode
-- `S{char}` (select text first, press S) or `gS` (same, puts the surround on its own line);
-- there's no Visual-mode equivalent for change/delete, since those are Normal-mode-only
-- operations in nvim-surround's own design. `setup({ keymaps = {...} })` lets you cherry-pick
-- ys/cs/ds back individually without re-enabling all Normal-mode defaults.
return {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
	config = function()
		vim.keymap.set({ "n", "v", "o" }, "s", "<Nop>") -- free native substitute; doesn't conflict with S/gS below
		vim.g.nvim_surround_no_normal_mappings = true -- see header note: only Visual S/gS remain
		require("nvim-surround").setup({})
	end,
}
