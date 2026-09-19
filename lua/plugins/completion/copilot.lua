-- zbirenbaum/copilot.lua: inline suggestions. Needs Node 22+ and :Copilot auth once.
-- Keys (insert): <C-l> accept, <M-l> accept word, <M-S-l> accept line, <M-]>/<M-[> next/previous, <M-e> dismiss.
return {
	"zbirenbaum/copilot.lua",
	event = "InsertEnter", -- every key it binds is insert-mode, so nothing is needed before the first insert
	config = function()
		if require("utils").executable("node") then
			local ok, version_str = pcall(function()
				return vim.fn.system("node --version"):match("v(%d+)")
			end)
			local major = ok and tonumber(version_str) or nil
			if major and major < 22 then
				vim.schedule(function()
					vim.notify(
						string.format(
							"Copilot needs Node.js v22+; found v%d. Suggestions will silently never "
								.. "appear until this is fixed. Either upgrade Node, or set `server = "
								.. "{ type = 'binary' }` below to skip the Node requirement entirely.",
							major
						),
						vim.log.levels.WARN,
						{ title = "Copilot" }
					)
				end)
			end
		else
			vim.schedule(function()
				vim.notify(
					"Copilot needs Node.js v22+ and none was found on $PATH, so suggestions will never "
						.. "appear until Node is installed (or `server = { type = 'binary' }` is set below "
						.. "to skip the Node requirement).",
					vim.log.levels.WARN,
					{ title = "Copilot" }
				)
			end)
		end

		require("copilot").setup({
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = "<C-l>",
					accept_word = "<M-l>",
					accept_line = "<M-S-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<M-e>", -- <C-]> stays the native insert-mode abbreviation trigger
				},
			},
			filetypes = {
				markdown = true,
				help = true,
			},
		})
	end,
}
