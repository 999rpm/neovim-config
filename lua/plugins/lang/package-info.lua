-- vuki656/package-info.nvim: the newest version beside each outdated dependency of a package.json, as crates.lua does
-- for Cargo.toml. Needs npm, so it stays off without it. Keys in package.json buffers: <localleader>t toggle the
-- versions, u update the dependency under the cursor, d delete it, i install a new one, v pick another version.
return {
	"vuki656/package-info.nvim",
	event = { "BufRead package.json" },
	cond = function()
		return require("utils.core").executable("npm")
	end,
	dependencies = { "MunifTanjim/nui.nvim" },
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
			map("<localleader>t", info.toggle, "Toggle dependency versions")
			map("<localleader>u", info.update, "Update dependency")
			map("<localleader>d", info.delete, "Delete dependency")
			map("<localleader>i", info.install, "Install a dependency")
			map("<localleader>v", info.change_version, "Change dependency version")
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
