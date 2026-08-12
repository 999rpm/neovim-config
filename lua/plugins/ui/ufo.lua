-- kevinhwang91/nvim-ufo: virtual-text fold previews, LSP/treesitter-aware folding. Needs
-- `foldmethod = "manual"` (Nvim's own default, left unset in options.lua for exactly this
-- reason) plus a high foldlevel/foldlevelstart and a narrow foldcolumn — all set in
-- options.lua; this file owns everything else.
--
-- provider_selector chains lsp -> treesitter -> indent per buffer (see customize_selector
-- below) instead of the 2-element `{main, fallback}` table form. This matters: per nvim-ufo's
-- own README ("'lsp' and 'treesitter' as main provider, 'indent' as fallback provider") and
-- doc/example.lua, only 'indent' is a safe unconditional fallback — it cannot itself throw.
-- Putting 'treesitter' in that slot means that when treesitter *also* can't produce folds for
-- a buffer (missing parser, parse error, or a filetype whose folds.scm doesn't cover the
-- construct on screen), there's nothing left to catch it — that's the 'UfoFallbackException'/
-- UnhandledPromiseRejection spam in :Noice history. customize_selector below is nvim-ufo's own
-- documented `selectProviderWithChainByDefault` pattern (doc/example.lua), which explicitly
-- catches 'UfoFallbackException' at each stage and retries with the next provider, so indent —
-- which can't fail — always has the last word. Verified against a fresh clone of nvim-ufo
-- before writing this; matches the pattern rafi/vim-config uses for the same reason.
return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- Buffers where computing folds makes no sense at all — skip every provider.
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
				-- Right-aligned "N lines" suffix instead of the default ellipsis, following the
				-- width-budgeting algorithm from nvim-ufo's own README ("Customize fold text")
				-- exactly — reserving the suffix's width up front, before truncating the
				-- original virt text, so the suffix always fits instead of overflowing `width`.
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
							-- truncate() can return text narrower than asked for; pad the gap
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
