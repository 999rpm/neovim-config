-- ravitemer/mcphub.nvim: MCP server manager, opened with :MCPHub. The build step installs the mcp-hub binary through
-- npm. Every MCP tool call asks before it runs (upstream's auto_approve stays off). Owns no keys; the :MCPHub window
-- lists its own.
return {
	"ravitemer/mcphub.nvim",
	build = "npm install -g mcp-hub@latest",
	cmd = "MCPHub",
	opts = {},
}
