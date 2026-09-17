-- ravitemer/mcphub.nvim: MCP server manager (:MCPHub). Needs Node and installs the mcp-hub binary on build.
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
					"mcphub.nvim needs Node/npm to install its 'mcp-hub' binary. See this "
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
