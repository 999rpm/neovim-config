-- ravitemer/mcphub.nvim: MCP server manager, opened with :MCPHub. The build step installs the mcp-hub binary through npm.
return {
	"ravitemer/mcphub.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	build = "npm install -g mcp-hub@latest",
	cmd = "MCPHub",
	opts = {
		auto_approve = false, -- every MCP tool call asks first
	},
}
