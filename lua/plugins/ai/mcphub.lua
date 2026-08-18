-- ravitemer/mcphub.nvim: install/manage/browse Model Context Protocol servers from inside
-- Nvim, and expose them as tools to plugins/ai/avante.lua's agent (its own docs: "integrate MCP
-- functionality for Avante through mcphub.nvim"). Needs Node/npm — already a documented
-- requirement of this config (README.md, for Copilot/JS-TS-ecosystem LSP servers), not a new
-- one; the `build` step below installs its one additional global npm package.
return {
	"ravitemer/mcphub.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	build = "npm install -g mcp-hub@latest",
	cmd = "MCPHub",
	opts = {
		auto_approve = false, -- always prompt before an MCP tool call runs, not silently
	},
	config = function(_, opts)
		if not require("utils").executable("npm") then
			vim.schedule(function()
				vim.notify(
					"mcphub.nvim needs Node/npm to install its 'mcp-hub' binary — see this "
						.. "config's README.md for the Node requirement already documented "
						.. "there (shared with Copilot/JS-TS language servers).",
					vim.log.levels.WARN,
					{ title = "MCPHub" }
				)
			end)
		end
		require("mcphub").setup(opts)
	end,
}
