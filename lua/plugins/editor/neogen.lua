-- danymat/neogen: generates a docstring for the node under the cursor. Owns <leader>cn.
return {
	"danymat/neogen",
	cmd = "Neogen",
	keys = {
		{
			"<leader>cn",
			function()
				require("neogen").generate()
			end,
			desc = "Generate annotation",
		}, -- n: a doc comment for the function or class under the cursor, its fields ready to fill (n for neogen)
	},
	opts = {
		snippet_engine = "nvim",
	},
}
