-- zbirenbaum/copilot.lua: GitHub Copilot inline (ghost-text) suggestions — a different kind of
-- AI assistance than blink.cmp's completion menu (accept/cycle keymaps below are entirely
-- separate from blink.lua's `<Tab>`/`<CR>`, so the two don't compete for the same keys).
--
-- `filetypes` below is NOT why suggestions might not appear: traced copilot.lua's own
-- `is_ft_disabled()` (lua/copilot/client/filetypes.lua) directly — it checks this table, then
-- an internal disabled-by-default list (yaml/markdown/help/gitcommit/gitrebase/hgcommit/svn/
-- cvs), and falls through to ENABLED for anything neither one mentions. So lua/python/js/etc.
-- are already on by default; `markdown`/`help` here just opt back IN to two of the internally-
-- disabled ones. If suggestions aren't showing up anywhere, it's almost never this table —
-- check (in order): `:Copilot status` (authenticated at all?), the Node check below, and
-- finally `:Copilot attach` on the current buffer to see its own reason for not attaching.
return {
	"zbirenbaum/copilot.lua",
	config = function()
		-- copilot.lua's own README states Node.js v22+ specifically (not just "any Node") —
		-- confirmed by reading it directly, not assumed. An older LTS (18/20, both still common
		-- default installs) will not work, and does so silently: no error dialog, just no
		-- suggestions ever, which is indistinguishable from an auth problem without this check.
		-- `type = "binary"` under `server` below is the alternative if you'd rather not manage
		-- a Node version at all — it downloads a standalone binary instead of shelling out to
		-- system `node`; commented out rather than switched to by default, since it's a real
		-- trade-off (a second binary for copilot.lua to keep updated) rather than a strict
		-- improvement over the Node-based path.
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
					"Copilot needs Node.js v22+ and none was found on $PATH — suggestions will never "
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
					dismiss = "<C-]>",
				},
			},
			filetypes = {
				markdown = true,
				help = true,
			},
			-- server = { type = "binary" }, -- uncomment to sidestep the Node.js requirement above entirely
		})
	end,
}
