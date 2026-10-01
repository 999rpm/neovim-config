-- MeanderingProgrammer/render-markdown.nvim: draws headings, bullets, checkboxes, callouts, tables, ==highlights== and
-- [[wiki links]] in place and shows the raw text on the cursor line. <leader>um toggles it. Its in-process completion
-- source offers checkbox states and callout names through blink. It owns markdown's 'conceallevel': 3 while rendered,
-- 0 in insert mode, so links and markup read as typed while editing.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	dependencies = { "nvim-treesitter/nvim-treesitter" }, -- mini.icons is already loaded at priority 1000
	keys = {
		{ "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown rendering" },
	},
	opts = {
		completions = { lsp = { enabled = true } },
		latex = { enabled = false }, -- snacks.image draws math; this would need latex2text or utftex and draw it a second time
		win_options = {
			conceallevel = { default = 0 }, -- used while not rendered (insert mode); rendered stays the plugin's 3
		},
		heading = {
			icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
			signs = {},
			backgrounds = {
				"RenderMarkdownH1Bg",
				"RenderMarkdownH2Bg",
				"RenderMarkdownH3Bg",
				"RenderMarkdownH4Bg",
				"RenderMarkdownH5Bg",
				"RenderMarkdownH6Bg",
			},
		},
		code = {
			sign = false,
			width = "block",
			right_pad = 1,
			style = "language",
			border = "thin", -- lower visual + render cost
		},
		bullet = {
			icons = { "● ", "○ ", "◆ ", "◇ " },
		},
		checkbox = {
			unchecked = { icon = "󰄱 " },
			checked = { icon = "󰱒 " },
			custom = {
				todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownWarn" },
				progress = { raw = "[~]", rendered = "󰏫 ", highlight = "RenderMarkdownInfo" },
			},
		},
		callout = {
			note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
			tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
			important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownError" },
			warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
		},
		anti_conceal = { enabled = true },
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)
		require("utils").on_colorscheme("render-markdown-highlights", function()
			vim.api.nvim_set_hl(0, "RenderMarkdownInfo", { link = "DiagnosticInfo" })
			vim.api.nvim_set_hl(0, "RenderMarkdownSuccess", { link = "DiagnosticOk" })
			vim.api.nvim_set_hl(0, "RenderMarkdownWarn", { link = "DiagnosticWarn" })
			vim.api.nvim_set_hl(0, "RenderMarkdownError", { link = "DiagnosticError" })
		end)
	end,
}
