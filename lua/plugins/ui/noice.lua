-- folke/noice.nvim: command line, messages and LSP progress as floating UI. noice maps no keys itself; :Noice dismiss
-- clears the views. noice reads the attached UIs once, at setup, and leaves the command line and messages to a GUI
-- that draws them itself, with an error for each. Neovide 0.17.1 draws them until its first frame
-- (startup-message-capture), so inside such a GUI the setup waits until both are handed back to Neovim. Owns
-- <leader>sm under snacks.lua's search group.
return {
	"folke/noice.nvim",
	lazy = false, -- keys alone would defer it, and the command line UI is needed from the first :
	keys = {
		{ "<leader>sm", "<cmd>Noice history<cr>", desc = "Message history" }, -- n: :messages output and command-line messages in a split; popups from vim.notify are in <leader>sn
	},
	opts = {
		lsp = {
			signature = { enabled = false },
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},

		notify = { enabled = false }, -- snacks.notifier owns vim.notify
		messages = {
			view = "mini",
			view_error = "mini",
			view_warn = "mini",
		},

		presets = {
			bottom_search = true,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = true,
			lsp_doc_border = true,
		},

		routes = {
			{
				filter = { event = "msg_show", kind = "written" },
				opts = { skip = true },
			},
			{
				filter = {
					event = "lsp",
					kind = "progress",
					cond = function(message)
						local client = vim.tbl_get(message.opts, "progress", "client")
						return client == "basedpyright"
					end,
				},
				opts = { skip = true },
			},
		},
	},
	config = function(_, opts)
		local function gui_owns_cmdline() -- noice/ui/init.lua drops each widget an attached UI externalizes
			for _, ui in ipairs(vim.api.nvim_list_uis()) do
				if ui.ext_cmdline or ui.ext_messages then
					return true
				end
			end
			return false
		end
		if not gui_owns_cmdline() then
			require("noice").setup(opts)
			return
		end
		vim.api.nvim_create_autocmd("OptionSet", {
			group = require("utils.core").augroup("noice-gui"),
			pattern = "cmdheight", -- Neovide sets it once ext_messages and ext_cmdline are off (src/bridge/ui_commands.rs)
			desc = "999rpm: set noice up once the GUI hands back the command line and messages",
			callback = function()
				if gui_owns_cmdline() then
					return
				end
				require("noice").setup(opts)
				return true -- removes this autocmd after the one setup
			end,
		})
	end,
}
