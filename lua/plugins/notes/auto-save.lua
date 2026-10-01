-- okuuva/auto-save.nvim: writes pages inside the notes graph (vim.g.notes_dir) a second after they change and on leaving
-- them, the way Logseq saves; every other file still waits for :w or <C-s>. :ASToggle pauses it for the session.
return {
	"okuuva/auto-save.nvim",
	ft = "markdown",
	cmd = "ASToggle",
	opts = {
		condition = function(buf)
			return vim.bo[buf].buftype == "" and vim.bo[buf].modifiable and require("utils").notes_in_vault(buf)
		end,
		debounce_delay = 1000,
	},
}
