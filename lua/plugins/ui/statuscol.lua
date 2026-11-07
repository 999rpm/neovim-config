-- luukvbaal/statuscol.nvim: line numbers, signs and the fold column in a fixed order, each clickable.
return {
	{
		"luukvbaal/statuscol.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local builtin = require("statuscol.builtin")

			require("statuscol").setup({
				relculright = true, -- matches this config's hybrid number setup (options.lua)
				segments = {
					{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" }, -- line numbers
					{ text = { "%s" }, click = "v:lua.ScSa" }, -- sign column (diagnostics/git)
					{ text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" }, -- fold column
				},
			})
		end,
	},
}
