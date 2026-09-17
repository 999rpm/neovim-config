-- windwp/nvim-autopairs: closes brackets and quotes, treesitter-aware.
return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		check_ts = true, -- consult the treesitter node before pairing, rather than adjacent characters alone
		ts_config = {
			lua = { "string", "source", "string_content" }, -- node types inside which pairing is skipped
			javascript = { "string", "template_string" },
		},
	},
}
