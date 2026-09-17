-- danymat/neogen: generates a docstring for the node under the cursor (<leader>cn).
return {
	"danymat/neogen",
	cmd = "Neogen",
	keys = {
		{
			"<leader>cn",
			function()
				require("neogen").generate()
			end,
			desc = "Generate Annotation",
		},
	},
	opts = {
		snippet_engine = "nvim",
	},
}
