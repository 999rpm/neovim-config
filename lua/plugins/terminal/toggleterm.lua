-- akinsho/toggleterm.nvim: floating/split terminal, plus a dedicated btop monitor terminal.
-- `close_on_exit = true` (toggleterm's own default, not overridden below) means a terminal job
-- that fails to spawn closes its window immediately — if a terminal opens and vanishes
-- instantly, check `shell` in config/options.lua before suspecting this file.
return {
	"akinsho/toggleterm.nvim",
	version = "*",
	cmd = { "ToggleTerm", "TermExec" },
	keys = {
		{
			"<C-\\>",
			"<cmd>ToggleTerm direction=float<cr>",
			mode = { "n", "t" },
			desc = "Toggle Terminal",
		},
		{ "<leader>tv", "<cmd>ToggleTerm size=60 direction=vertical<cr>", desc = "Vertical Split" },
		{ "<leader>th", "<cmd>ToggleTerm size=15 direction=horizontal<cr>", desc = "Horizontal Split" },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float" },
		{ "<leader>tm", "<cmd>lua _G.toggle_btop()<CR>", desc = "BTOP Monitor" },
	},
	opts = {
		size = 20,
		hide_numbers = true,
		shade_terminals = true,
		start_in_insert = true,
		direction = "float",
		float_opts = {
			border = "curved",
		},
	},
	config = function(_, opts)
		require("toggleterm").setup(opts)

		local Terminal = require("toggleterm.terminal").Terminal
		local btop = Terminal:new({ cmd = "btop", hidden = true })

		-- Global on purpose: the `keys` table above is evaluated before this function runs, so
		-- it can't close over a local `btop` — this global is the bridge between the two.
		function _G.toggle_btop()
			btop:toggle()
		end

		vim.api.nvim_create_autocmd("TermOpen", {
			group = require("utils").augroup("toggleterm-keymaps"),
			pattern = "term://*",
			callback = function(event)
				local opts_local = { buffer = event.buf }
				vim.keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", opts_local)
				vim.keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", opts_local)
				vim.keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", opts_local)
				vim.keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", opts_local)
			end,
		})
	end,
}
