-- HakonHarnes/img-clip.nvim: pastes an image from the clipboard (or a dropped file) into an assets folder and links it.
-- Inside the notes graph the image goes to the graph's own assets/ and the link is relative to the page
-- (../assets/image_....png), which is where Logseq keeps and looks for them. Owns <leader>cp.
return {
	"HakonHarnes/img-clip.nvim",
	cmd = { "PasteImage", "ImgClipConfig", "ImgClipDebug" },
	keys = {
		{ "<leader>cp", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" }, -- n: the clipboard image saved as a file and linked at the cursor (p for paste)
	},
	opts = { -- elsewhere upstream's defaults: assets/ under the working directory, a timestamped name to confirm
		custom = {
			{
				trigger = function()
					return require("utils.notes").is_page(0)
				end,
				dir_path = function()
					return require("utils.notes").root() .. "/assets"
				end,
				file_name = "image_%Y%m%d%H%M%S", -- Logseq's own prefix for pasted images
				prompt_for_file_name = false,
			},
		},
	},
}
