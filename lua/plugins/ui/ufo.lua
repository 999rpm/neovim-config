-- kevinhwang91/nvim-ufo: folds from LSP, with treesitter and indent as fallbacks.
-- Keys: zR open all, zM close all, zr open except kinds; native za/zc/zo/zj/zk still apply.
return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local ft_providers = {
				qf = "",
				help = "",
				lazy = "",
				mason = "",
				notify = "",
				Trouble = "",
				["neo-tree"] = "",
			}

			---@param bufnr integer
			---@return Promise
			local function customize_selector(bufnr)
				local ufo = require("ufo")
				local function handle_fallback(err, provider_name)
					if type(err) == "string" and err:match("UfoFallbackException") then
						return ufo.getFolds(bufnr, provider_name)
					end
					return require("promise").reject(err)
				end

				return ufo
					.getFolds(bufnr, "lsp")
					:catch(function(err)
						return handle_fallback(err, "treesitter")
					end)
					:catch(function(err)
						return handle_fallback(err, "indent")
					end)
			end

			require("ufo").setup({
				open_fold_hl_timeout = 0,
				provider_selector = function(_, filetype, _)
					return ft_providers[filetype] or customize_selector
				end,
				fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
					local new_virt_text = {}
					local suffix = (" 󰁂 %d lines "):format(end_lnum - lnum)
					local suffix_width = vim.fn.strdisplaywidth(suffix)
					local target_width = width - suffix_width
					local cur_width = 0
					for _, chunk in ipairs(virt_text) do
						local chunk_text = chunk[1]
						local chunk_width = vim.fn.strdisplaywidth(chunk_text)
						if target_width > cur_width + chunk_width then
							table.insert(new_virt_text, chunk)
						else
							chunk_text = truncate(chunk_text, target_width - cur_width)
							table.insert(new_virt_text, { chunk_text, chunk[2] })
							chunk_width = vim.fn.strdisplaywidth(chunk_text)
							if cur_width + chunk_width < target_width then
								suffix = suffix .. (" "):rep(target_width - cur_width - chunk_width)
							end
							break
						end
						cur_width = cur_width + chunk_width
					end
					table.insert(new_virt_text, { suffix, "Comment" })
					return new_virt_text
				end,
			})

			vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
		end,
	},
}
