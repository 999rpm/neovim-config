-- saecki/crates.nvim: Cargo.toml support through an in-process language server: crate versions and features in
-- completion, K shows a crate's details, gra offers upgrade, update and feature actions. Loads with the first Cargo.toml.
return {
	"saecki/crates.nvim",
	event = { "BufRead Cargo.toml" },
	opts = {
		lsp = { enabled = true, actions = true, completion = true, hover = true },
	},
}
