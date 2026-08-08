-- sindrets/diffview.nvim: full-repo diff/history views (as opposed to plugins/git/gitsigns.lua's
-- inline per-hunk staging/preview), with Telescope bridges for jumping into a diff from a
-- commit or branch picker. Its file panels render through Nvim's native diff mode, which is
-- why gitsigns.lua's own hunk-nav keymaps (`]c`/`[c`) fall back to native diff-jump commands
-- when `vim.wo.diff` is true — see that file's note.
return {
	"sindrets/diffview.nvim",

	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewFileHistory",
	},

	keys = {
		{ "<leader>Gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview: Open" },
		{ "<leader>Gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: File History" },
		{ "<leader>GH", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview: Repo History" },
		{ "<leader>Gx", "<cmd>DiffviewClose<CR>", desc = "Diffview: Close" },
	},

	opts = {
		enhanced_diff_hl = true,
		use_icons = true,

		view = {
			default = {
				disable_diagnostics = true,
			},
			merge_tool = {
				disable_diagnostics = true,
			},
		},

		keymaps = {
			view = {
				{ "n", "<Tab>", ":DiffviewToggleFiles<CR>", { desc = "Toggle file panel" } },
			},
		},
	},

	config = function(_, opts)
		local diffview = require("diffview")
		diffview.setup(opts)

		local review_group = require("utils").augroup("diffview-review-mode")

		vim.api.nvim_create_autocmd("FileType", {
			group = review_group,
			pattern = { "DiffviewFiles", "DiffviewFileHistory" },
			callback = function()
				vim.opt_local.cursorline = true
				vim.opt_local.scrolloff = 8
				vim.opt_local.signcolumn = "yes"
			end,
		})

		local function telescope_commit_diffview()
			local ok, telescope = pcall(require, "telescope.builtin")
			if not ok then
				return
			end

			telescope.git_commits({
				attach_mappings = function(_, map)
					map("i", "<CR>", function(prompt_bufnr)
						local actions = require("telescope.actions")
						local state = require("telescope.actions.state")
						local entry = state.get_selected_entry()
						actions.close(prompt_bufnr)

						if entry and entry.value then
							vim.cmd("DiffviewOpen " .. entry.value .. "^!")
						end
					end)
					return true
				end,
			})
		end

		local function telescope_branch_diffview()
			local ok, telescope = pcall(require, "telescope.builtin")
			if not ok then
				return
			end

			telescope.git_branches({
				attach_mappings = function(_, map)
					map("i", "<CR>", function(prompt_bufnr)
						local actions = require("telescope.actions")
						local state = require("telescope.actions.state")
						local entry = state.get_selected_entry()
						actions.close(prompt_bufnr)

						if entry and entry.value then
							-- Compare selected branch against HEAD
							vim.cmd("DiffviewOpen HEAD.." .. entry.value)
						end
					end)
					return true
				end,
			})
		end

		vim.keymap.set("n", "<leader>Gb", telescope_branch_diffview, { desc = "Diffview: Compare Branch (Telescope)" })
		vim.keymap.set("n", "<leader>Gc", telescope_commit_diffview, { desc = "Diffview: Pick Commit (Telescope)" })
	end,
}
