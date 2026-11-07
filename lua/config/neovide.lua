-- Neovide, the GUI: init.lua loads this file only when vim.g.neovide is set, so a terminal session never reads it. The
-- font is kitty.conf's, the left Option key sends Meta on macOS (the Alt keys of the pickers, barbar and Copilot need
-- it) and the window frame takes the theme's background instead of the system's light or dark mode. Neovide draws no
-- kitty graphics, so snacks.lua, molten.lua and utils/d2.lua show images another way here (neovim/neovim#41287 proposes
-- image events for GUIs), and colorful-winsep.lua stays off, since Neovide shadows its separator floats. Before 0.17.2
-- Neovide paints the strip below the last row, left when the window height is not a whole number of rows, with that
-- row's colours, and lualine's sections ran down into it, so there one empty command-line row stays at the bottom:
-- noice's ui_attach sets 'cmdheight' to 0 whenever it starts, which inside Neovide 0.17.1 is after the first frame, so
-- the row comes back after it. 0.17.2 leaves the strip plain (neovide_fill_bottom_background, off by default;
-- neovide/neovide#3631) and keeps noice's hidden command line. Owns <C-=>, <C--> and <C-0> (text size) and the
-- clipboard keys: <D-c>/<D-v> on macOS, <C-S-c>/<C-S-v> elsewhere, which kitty and Windows Terminal copy and paste
-- with. Insert and command-line mode keep the built-in CTRL-SHIFT-V (the next key literally), so <C-r>+ pastes there
-- off macOS. Neovide itself maps no key.
local g = vim.g
local map = vim.keymap.set

vim.o.guifont = "Lilex Nerd Font:h11" -- kitty.conf's font_family and font_size: the same glyphs at the same size
g.neovide_input_macos_option_key_is_meta = "only_left" -- the right Option key still types accented letters
g.neovide_theme = "bg_color" -- title bar and frame follow the theme

local version = vim.version.parse(g.neovide_version or "", { strict = false }) -- Neovide's lua/init.lua sets it
if not version or vim.version.lt(version, { 0, 17, 2 }) then
	local cmdline = require("utils.core").augroup("neovide-cmdline")
	vim.api.nvim_create_autocmd("UIEnter", {
		group = cmdline,
		desc = "999rpm: keep one command-line row, so the strip below the statusline takes the plain background",
		callback = function()
			vim.o.cmdheight = 1 -- options.lua sets 0 for noice
		end,
	})
	vim.api.nvim_create_autocmd("OptionSet", {
		group = cmdline,
		pattern = "cmdheight",
		desc = "999rpm: bring the command-line row back after noice's ui_attach sets 'cmdheight' to 0",
		callback = function()
			if vim.o.cmdheight == 0 then
				vim.schedule(function()
					vim.o.cmdheight = 1 -- once ui_refresh() has returned (:help ui-messages)
				end)
			end
		end,
	})
end

---@param factor? number nil resets
local function scale(factor)
	return function()
		g.neovide_scale_factor = factor and (g.neovide_scale_factor or 1) * factor or 1
	end
end

local mac = vim.fn.has("mac") == 1
local copy, paste = mac and "<D-c>" or "<C-S-c>", mac and "<D-v>" or "<C-S-v>"
local paste_modes = mac and { "n", "i", "v", "c", "t" } or { "n", "v", "t" } -- i_CTRL-SHIFT-V and c_CTRL-SHIFT-V stay built-in

map("n", "<C-=>", scale(1.25), { desc = "Larger text" }) -- n: the whole window a step larger, as a terminal's font-size key does
map("n", "<C-->", scale(1 / 1.25), { desc = "Smaller text" }) -- n: a step smaller
map("n", "<C-0>", scale(), { desc = "Reset text size" }) -- n: back to the size guifont sets
map("v", copy, '"+y', { desc = "Copy" }) -- v: the selection to the system clipboard
map(paste_modes, paste, function()
	vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, { desc = "Paste" }) -- n/v/t, plus i/c on macOS: the system clipboard at the cursor, as a terminal pastes; . repeats it
