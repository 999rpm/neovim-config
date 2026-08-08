-- kevinhwang91/nvim-ufo: virtual-text fold previews, LSP/treesitter-aware folding. Needs
-- `foldmethod = "manual"` (Nvim's own default, left unset in options.lua for exactly this
-- reason) plus a high foldlevel/foldlevelstart and a narrow foldcolumn — all set in
-- options.lua; this file owns everything else. provider_selector prefers LSP folding
-- (utils.get_lsp_capabilities() advertises `textDocument.foldingRange` specifically for this),
-- falling back to treesitter, which covers every language in treesitter.lua's ensure_installed
-- list; not using ufo's own "indent" fallback since treesitter is strictly more accurate.
--
-- 2026-08-06: config-wide audit (full scope in init.lua). Fixed a real bug: this file's own
-- header comment has always claimed the fallback order is "lsp, then treesitter" (see above,
-- unchanged from before), but `provider_selector` actually returned `{ "lsp", "indent" }` —
-- skipping treesitter entirely in favor of crude, less-accurate indent-based folding as the
-- fallback for any filetype without LSP folding-range support. Fixed to match what the comment
-- always said was happening: `{ "lsp", "treesitter" }`.
-- Also the likely cause of "two fold arrows on the same line": that was `foldcolumn = "4"` in
-- options.lua stacking one glyph per nesting level on lines that are simultaneously inside an
-- outer fold and the start of an inner one — not a bug in this file. See options.lua's note;
-- nothing to fix here for that specific report.
-- Added this pass, both ideas sourced from rafi/vim-config <https://github.com/rafi/vim-config>
-- (lua/rafi/plugins/extras/editor/ufo.lua) but verified/reimplemented against nvim-ufo's own
-- current docs rather than copied outright:
--   • `open_fold_hl_timeout = 0` — skips the brief highlight flash on opening a fold. Matches
--     rafi's value directly.
--   • Per-filetype `provider_selector` overrides for buffers where computing folds makes no
--     sense (quickfix, help, neo-tree, Trouble, lazy, mason, notify) — the concept is rafi's,
--     the actual filetype list is rewritten against this config's own utility buffers.
--   • `fold_virt_text_handler` — shows how many lines a closed fold is hiding. Rafi's own
--     version pads without truncating the original text, which can under- or over-pad on long
--     lines; rebuilt against nvim-ufo's own README example ("Customize fold text") instead,
--     which reserves the suffix's width up front before truncating — more correct won out.
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

			require("ufo").setup({
				open_fold_hl_timeout = 0,
				provider_selector = function(_, filetype, _)
					return ft_providers[filetype] or { "lsp", "treesitter" }
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
