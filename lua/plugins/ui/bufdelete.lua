-- famiu/bufdelete.nvim: delete a buffer without disturbing window layout — the one function
-- plugins/ui/bufferline.lua needs from mini.bufremove, now standalone instead of pulling in
-- the rest of the mini.nvim bundle for it. No setup() call: used directly via
-- `require("bufdelete").bufdelete(bufnr, force)`.
return {
	"famiu/bufdelete.nvim",
	lazy = true, -- only ever invoked programmatically by bufferline.lua's smart_close()
}
