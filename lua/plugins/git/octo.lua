-- pwntester/octo.nvim: browse/review/comment on GitHub issues and pull requests as regular
-- Nvim buffers. Needs the `gh` CLI authenticated (`gh auth login`) — checked once below, same
-- "warn clearly instead of a raw failure mid-session" shape as utils.warn_if_missing_mason_bin()
-- and copilot.lua's Node-version check.
--
-- `<leader>go*` rather than a bare `<leader>o` prefix: `<leader>o` is this config's Options
-- group (mappings.lua/lspconfig.lua/themes.lua) — nesting under the existing Git group instead
-- (`<leader>g` + "o" for Octo) avoids that collision entirely and keeps every GitHub-hosting
-- integration (gitsigns, diffview, gitlinker, this) under one prefix.
return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"echasnovski/mini.nvim",
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{ "<leader>goi", "<cmd>Octo issue list<cr>", desc = "Issue List" },
		{ "<leader>gop", "<cmd>Octo pr list<cr>", desc = "PR List" },
		{ "<leader>goc", "<cmd>Octo pr create<cr>", desc = "PR Create" },
		{ "<leader>gos", "<cmd>Octo search<cr>", desc = "Search" },
	},
	opts = {
		use_local_fs = true, -- read comments/files from local disk when available instead of always fetching, faster for a checked-out PR branch
		picker = "telescope", -- matches this config's own primary picker (plugins/search/telescope.lua)
	},
	config = function(_, opts)
		if not require("utils").executable("gh") then
			vim.schedule(function()
				vim.notify(
					"octo.nvim needs the 'gh' CLI, authenticated ('gh auth login') — install it "
						.. "first (Octo commands will error without it).",
					vim.log.levels.WARN,
					{ title = "Octo" }
				)
			end)
		end
		require("octo").setup(opts)
	end,
}
