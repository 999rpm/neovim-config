-- HakonHarnes/img-clip.nvim: pastes an image from the clipboard (or a dropped file) into an assets folder and links it
-- (<leader>cp). Inside the notes graph the image goes to the graph's own assets/ and the link is relative to the page
-- (../assets/image_....png), which is where Logseq keeps and looks for them.
return {
	"HakonHarnes/img-clip.nvim",
	cmd = { "PasteImage", "ImgClipConfig", "ImgClipDebug" },
	keys = {
		{ "<leader>cp", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
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
		custom = {
			{
				trigger = function()
					return require("utils").notes_in_vault(0)
				end,
				dir_path = function()
					return require("utils").notes_root() .. "/assets"
				end,
				file_name = "image_%Y%m%d%H%M%S", -- Logseq's own prefix for pasted images
				prompt_for_file_name = false,
				relative_template_path = true, -- the link is relative to the page's folder: ../assets/...
			},
		},
	},
}
