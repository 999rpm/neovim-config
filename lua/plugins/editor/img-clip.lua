-- HakonHarnes/img-clip.nvim: pastes an image from the clipboard into the buffer's assets folder and links it (<leader>cp).
return {
	"HakonHarnes/img-clip.nvim",
	cmd = { "PasteImage", "ImgClipConfig", "ImgClipDebug" },
	keys = {
		{ "<leader>cp", "<cmd>PasteImage<cr>", desc = "Paste Image From Clipboard" },
	},
	opts = {
		default = {
			dir_path = "assets", -- written relative to the CWD, not the buffer, until relative_to_current_file flips
			file_name = "%Y-%m-%d-%H-%M-%S", -- strftime; timestamped so two pastes can't collide
			prompt_for_file_name = true, -- upstream default: ask, with the timestamp above pre-filled
			drag_and_drop = { enabled = true }, -- dropping a file onto the terminal window inserts it too
		},
		filetypes = {
			markdown = {
				url_encode_path = true, -- a path with spaces stays a valid markdown link
				template = "![$CURSOR]($FILE_PATH)", -- cursor lands in the alt-text slot, ready to type
			},
		},
	},
}
