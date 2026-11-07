-- MeanderingProgrammer/render-markdown.nvim: draws headings, bullets, checkboxes, callouts, tables, ==highlights== and
-- [[wiki links]] in place and shows the raw text on the cursor line. Its in-process completion source offers checkbox
-- states and callout names through blink. It owns markdown's 'conceallevel': 3 while rendered, 0 in insert mode, so
-- links and markup read as typed while editing. avante.lua's chat sidebar (filetype Avante) renders too, as avante's
-- README asks, tables included, since markdown-pipetable.lua serves markdown buffers only. Owns <leader>om.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "quarto", "Avante" },
	keys = {
		{ "<leader>om", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown rendering" }, -- n: drawn or raw markdown in every markdown buffer
	},
	opts = {
		file_types = { "markdown", "quarto", "Avante" }, -- notebooks open as markdown; quarto documents and avante's answers render too
		completions = { lsp = { enabled = true } },
		latex = { enabled = false }, -- snacks.image draws math; this would need latex2text or utftex and draw it a second time
		pipe_table = { enabled = false }, -- markdown-pipetable.lua draws tables; with both on, the borders double up
		overrides = {
			filetype = {
				Avante = { pipe_table = { enabled = true } }, -- no markdown-pipetable there
			},
		},
		win_options = {
			conceallevel = { default = 0 }, -- used while not rendered (insert mode); rendered stays the plugin's 3
		},
		heading = {
			icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
			signs = {},
		},
		code = {
			sign = false,
			right_pad = 1,
			style = "language",
			border = "thin",
		},
		bullet = {
			icons = { "● ", "○ ", "◆ ", "◇ " },
		},
		checkbox = {
			custom = {
				todo = { highlight = "RenderMarkdownWarn" }, -- upstream's [-], in the warning colour
				progress = { raw = "[~]", rendered = "󰏫 ", highlight = "RenderMarkdownInfo" },
			},
		},
		callout = {
			important = { highlight = "RenderMarkdownError" }, -- the other callouts keep upstream's colours
		},
	},
}
