-- jmbuhr/otter.nvim: language servers inside the code cells of a markdown notebook. Each cell language gets a hidden
-- buffer that basedpyright, ruff and the rest attach to, and otter's in-process server forwards completion, K, gd, grr
-- and grn between the two; diagnostics come back as each server reports them. ipynb.lua activates it in notebook and
-- quarto buffers. The hidden buffer follows every edit, normal-mode ones included, so the servers' lines stay the
-- notebook's. Two gaps are closed here: servers that answer diagnostics only on request (ruff) are asked after every
-- change, since Neovim asks only for buffers shown in a window and the hidden buffers never are; otter copies the
-- diagnostics of the one server that just reported, which would drop the other servers', so every change is handed
-- to otter again with the hidden buffer's full set. basedpyright serves the cells from the notebook's folder
-- (lspconfig.lua). The hidden buffers stay out of the diagnostic lists (trouble.lua, snacks.lua, mappings.lua).
local function is_cell_buffer(buf)
	return require("utils.notebook").is_cell_buffer(buf)
end

return {
	"jmbuhr/otter.nvim",
	lazy = true, -- loaded by the first require from utils/notebook.lua's attach
	opts = {
		lsp = { diagnostic_update_events = { "BufWritePost", "InsertLeave", "TextChanged" } }, -- the README's set for instant updates: a normal-mode edit that moves cells also reaches the servers, so no diagnostic keeps an old line
	},
	config = function(_, opts)
		require("otter").setup(opts)
		local group = require("utils.core").augroup("otter-diagnostics")
		vim.api.nvim_create_autocmd("LspNotify", {
			group = group,
			desc = "999rpm: request diagnostics for otter's hidden cell buffers after each change",
			callback = function(ev)
				local method = ev.data.method
				if
					(method ~= "textDocument/didOpen" and method ~= "textDocument/didChange")
					or not is_cell_buffer(ev.buf)
				then
					return
				end
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				local provider = client and client.server_capabilities.diagnosticProvider
				if provider then -- the default handler stores the answer, and otter copies it into the notebook
					client:request("textDocument/diagnostic", {
						identifier = type(provider) == "table" and provider.identifier or nil,
						textDocument = vim.lsp.util.make_text_document_params(ev.buf),
					}, nil, ev.buf)
				end
			end,
		})
		vim.api.nvim_create_autocmd("DiagnosticChanged", {
			group = group,
			desc = "999rpm: hand otter the full diagnostics of a hidden cell buffer",
			callback = function(ev)
				if vim.tbl_get(ev, "data", "_999rpm_all") or not is_cell_buffer(ev.buf) then
					return
				end
				vim.schedule(function() -- after otter's own handler, which has just copied one server's diagnostics
					if vim.api.nvim_buf_is_valid(ev.buf) then
						vim.api.nvim_exec_autocmds("DiagnosticChanged", {
							buf = ev.buf,
							modeline = false,
							data = { diagnostics = vim.diagnostic.get(ev.buf), _999rpm_all = true },
						})
					end
				end)
			end,
		})
	end,
}
