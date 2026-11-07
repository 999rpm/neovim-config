-- vuki656/package-info.nvim: the newest version beside each outdated dependency of a package.json, as crates.lua does
-- for Cargo.toml. Needs npm, so it stays off without it. Owns <localleader>t, u, d, i and v in package.json buffers;
-- package-info maps no keys itself.
return {
	"vuki656/package-info.nvim",
	event = { "BufRead package.json" },
	cond = function()
		return require("utils.core").executable("npm")
	end,
	opts = {
		hide_up_to_date = true, -- current dependencies stay unmarked
	},
	config = function(_, opts)
		local info = require("package-info")
		info.setup(opts)
		local function attach(buf)
			if not vim.api.nvim_buf_get_name(buf):match("package%.json$") then
				return
			end
			local function map(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { buf = buf, desc = desc })
			end
			map("<localleader>t", info.toggle, "Toggle dependency versions") -- n: show or hide the newest versions beside the lines
			map("<localleader>u", info.update, "Update dependency") -- n: the dependency under the cursor to its newest version
			map("<localleader>d", info.delete, "Delete dependency") -- n: npm uninstall for the dependency under the cursor
			map("<localleader>i", info.install, "Install a dependency") -- n: asks for a package name, then npm install
			map("<localleader>v", info.change_version, "Change dependency version") -- n: pick any published version
		end
		vim.api.nvim_create_autocmd("BufRead", {
			group = require("utils.core").augroup("package-info-keys"),
			pattern = "package.json",
			desc = "999rpm: package-info keys in package.json buffers",
			callback = function(ev)
				attach(ev.buf)
			end,
		})
		attach(vim.api.nvim_get_current_buf()) -- the package.json whose BufRead loaded the plugin
	end,
}
