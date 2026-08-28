-- MeanderingProgrammer/render-markdown.nvim: rendered headings/icons, styled code blocks,
-- bullet/checkbox icons, callouts (NOTE/TIP/WARNING/IMPORTANT), anti-conceal for editing
-- clarity. Toggle with <leader>um.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },

	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"echasnovski/mini.nvim",
	},

	keys = {
		{
			"<leader>um",
			"<cmd>RenderMarkdown toggle<cr>",
			desc = "Toggle Markdown Rendering",
		},
	},

	opts = {
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

		-- The 4-level bullet cycle below is render-markdown's own verified upstream default
		-- (plain Unicode geometric shapes, not Nerd Font glyphs - renders correctly even without
		-- one installed, unlike most other icons in this config).
		bullet = {
			icons = { "● ", "○ ", "◆ ", "◇ " },
		},

		checkbox = {
			unchecked = { icon = "󰄱 " },
			checked = { icon = "󰱒 " },
			custom = {
				todo = {
					raw = "[-]",
					rendered = "󰥔 ",
					highlight = "RenderMarkdownWarn",
				},
				progress = {
					raw = "[~]",
					rendered = "󰏫 ",
					highlight = "RenderMarkdownInfo",
				},
			},
		},

		callout = {
			note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
			tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
			important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownError" },
			warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
		},

		anti_conceal = {
			enabled = true,
		},
	},

	config = function(_, opts)
		require("render-markdown").setup(opts)

		pcall(function()
			vim.api.nvim_set_hl(0, "RenderMarkdownInfo", { link = "DiagnosticInfo" })
			vim.api.nvim_set_hl(0, "RenderMarkdownSuccess", { link = "DiagnosticOk" })
			vim.api.nvim_set_hl(0, "RenderMarkdownWarn", { link = "DiagnosticWarn" })
			vim.api.nvim_set_hl(0, "RenderMarkdownError", { link = "DiagnosticError" })
		end)
	end,
}
