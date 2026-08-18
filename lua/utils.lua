-- Shared helpers used by more than one file under config/ or plugins/. Anything used by only
-- one file lives in that file instead — this module is for genuine cross-file reuse only.
-- Every function below is tagged with an EOL comment naming which file(s) actually call it, so
-- an unused one is easy to spot and remove.
--
-- Base (may_create_dir, executable, has, is_compatible_version, rand_int, rand_element,
-- get_titlestr, get_virtual_env) and get_lsp_capabilities are adapted from jdhao/nvim-config's
-- lua/utils.lua and lua/lsp_utils.lua <https://github.com/jdhao/nvim-config>. get_git_repo(),
-- get_current_branch_name(), get_repo_info(), and augroup() are this config's own additions.
-- cowboy() is borrowed from LazyVim's lua/lazyvim/config/keymaps.lua.

local fn = vim.fn
local api = vim.api
local version = vim.version

local M = {}

-- ============================================================================
-- General helpers
-- ============================================================================

--- Create a directory if it does not exist.
--- @param dir string
function M.may_create_dir(dir) -- General helper, not currently called anywhere in this config
	if fn.isdirectory(dir) == 0 then
		fn.mkdir(dir, "p")
	end
end

--- Check if an executable exists on $PATH.
--- @param name string An executable name or path
--- @return boolean
function M.executable(name) -- This util is used by options.lua, lspconfig.lua, and treesitter.lua
	return fn.executable(name) > 0
end

--- Warn (once, at plugin-load time — not mid-debug-session) if a Mason-installed binary a DAP
--- adapter depends on isn't actually at its expected path yet. Mason's own install can still be
--- running in the background on a fresh machine, or can have failed outright (e.g. debugpy's
--- venv creation needs a system python3/python on $PATH to build from — if that's missing,
--- Mason never gets to create the venv at all); either way, the *first* sign of that today is a
--- raw ENOENT the moment you actually try to debug, which names the missing file but not why
--- it's missing or what to do about it. Same "check once at startup, one clear message" shape as
--- utils.executable()'s own callers (options.lua's nu/rg, treesitter.lua's tree-sitter-cli) —
--- this is the equivalent for a Mason-managed *absolute path* rather than a $PATH lookup, since
--- executable() alone can't check those.
--- @param path string Absolute path to the expected binary/script
--- @param label string Human-readable name for the notify message, e.g. "debugpy"
function M.warn_if_missing_mason_bin(path, label) -- This util is used by dap.lua and dap-python.lua
	if vim.uv.fs_stat(path) == nil then
		vim.schedule(function()
			vim.notify(
				string.format(
					"%s not found at:\n%s\n\nMason may still be installing it, or the install failed "
						.. "(debugpy/codelldb/js-debug-adapter/haskell-debug-adapter all need Mason to have "
						.. "finished successfully — a missing system python3 is the most common reason a "
						.. "pyvenv-based install like debugpy's never completes). Check `:Mason` (press 'i' "
						.. "on the entry if it's not installed) or `:MasonLog` for the actual error, then "
						.. "`:MasonInstall %s` to retry.",
					label,
					path,
					label
				),
				vim.log.levels.WARN,
				{ title = "DAP" }
			)
		end)
	end
end

--- Warn (once, at plugin-load time) if an environment variable a plugin needs isn't set —
--- e.g. an API key. Same "check once at startup, one clear message instead of a mid-session
--- failure" shape as warn_if_missing_mason_bin() above, for the API-key case that one can't
--- cover (an API key isn't a file on disk to fs_stat()).
--- @param var_name string e.g. "ANTHROPIC_API_KEY"
--- @param label string Human-readable name for the notify message, e.g. "avante.nvim"
function M.warn_if_missing_env(var_name, label) -- This util is used by avante.lua
	if not vim.env[var_name] or vim.env[var_name] == "" then
		vim.schedule(function()
			vim.notify(
				string.format("%s not set — %s will prompt for it or fail on first use.", var_name, label),
				vim.log.levels.WARN,
				{ title = label }
			)
		end)
	end
end

--- Create (or re-create) a "999rpm-"-namespaced augroup, so every custom augroup in this
--- config shows up together under `:autocmd`/`:augroup` output and never collides with a
--- plugin's own internal group names.
--- @param name string e.g. "no-paste" or "lsp-attach" (hyphens or underscores, either works)
--- @param clear boolean|nil Passed straight through to `nvim_create_augroup`'s `clear` field.
---   Defaults to `true`. Pass `false` for a group that's deliberately re-entered without
---   wiping previously-registered autocmds (e.g. an LSP-attach group adding one per buffer).
--- @return integer
function M.augroup(name, clear) -- Used by autocmds.lua and most plugin files that register their own autocmds
	if clear == nil then
		clear = true
	end
	return api.nvim_create_augroup("999rpm-" .. name:gsub("_", "-"), { clear = clear })
end

--- Check whether a Nvim feature flag is set.
--- @param feat string e.g. `"nvim-0.11"` or `"unix"`
--- @return boolean
function M.has(feat) -- General helper, not currently called anywhere in this config
	return fn.has(feat) == 1
end

--- Check if the running Nvim matches an expected version string. Emits a warning (not an
--- error) when versions differ so the config still loads either way.
--- @param expected_version string e.g. `"0.11.0"`
--- @return boolean
function M.is_compatible_version(expected_version) -- General helper, not currently called anywhere in this config
	local expect_ver = version.parse(expected_version)
	if expect_ver == nil then
		api.nvim_echo({ { string.format("Unsupported version string: %s", expected_version) } }, true, { err = true })
		return false
	end

	local actual_ver = vim.version()
	if version.cmp(expect_ver, actual_ver) ~= 0 then
		local msg = string.format(
			"Expect nvim version %s, but your current nvim version is %s.%s.%s. Use at your own risk!",
			expected_version,
			actual_ver.major,
			actual_ver.minor,
			actual_ver.patch
		)
		api.nvim_echo({ { msg } }, true, { err = true })
	end
	return true
end

-- ============================================================================
-- Git helpers
-- ============================================================================

--- Run a git command and return its stdout, or nil on failure.
--- @param cmd string[]
--- @return string|nil
function M.run_git_cmd(cmd) -- Internal helper for get_repo_info()/_process_abbrev_head() below
	local result = fn.system(cmd)
	if result == nil or vim.startswith(result, "fatal:") then
		return nil
	end
	return result
end

--- Return true when cwd is inside a git work-tree. Also fires `User InGitRepo` for
--- lazy-loading triggers.
--- @return boolean
function M.inside_git_repo() -- General helper, not currently called anywhere in this config
	local result = vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, { text = true }):wait()
	if result.code ~= 0 then
		return false
	end
	vim.cmd([[doautocmd User InGitRepo]])
	return true
end

--- Return the git root for the current buffer. Prefers gitsigns' cached
--- `vim.b.gitsigns_status_dict.root`; falls back to `git rev-parse` via get_repo_info() below.
--- @return string|nil
function M.get_git_repo() -- General helper, kept alongside get_current_branch_name() below, which IS used
	local gsd = vim.b.gitsigns_status_dict
	if gsd and gsd.root and #gsd.root > 0 then
		return gsd.root
	end
	local git_root, _ = M.get_repo_info()
	return git_root
end

--- Return the current branch name. Prefers gitsigns' cached `vim.b.gitsigns_status_dict.head`;
--- same fallback as get_git_repo() above.
--- @return string|nil
function M.get_current_branch_name() -- This util is used by options.lua (titlestring)
	local gsd = vim.b.gitsigns_status_dict
	if gsd and gsd.head and #gsd.head > 0 then
		return gsd.head
	end
	local _, abbrev_head = M.get_repo_info()
	return abbrev_head
end

--- Return `(git_root, abbrev_head)` via `git rev-parse` — the fallback get_git_repo()/
--- get_current_branch_name() use when gitsigns has no cached data yet (e.g. buffer just
--- opened, gitsigns hasn't attached).
--- @return string|nil, string|nil
function M.get_repo_info() -- Internal helper: fallback used by get_git_repo()/get_current_branch_name() above
	local cwd = fn.expand("%:p:h")
	local raw = M.run_git_cmd({
		"git",
		"-C",
		cwd,
		"--no-pager",
		"rev-parse",
		"--show-toplevel",
		"--absolute-git-dir",
		"--abbrev-ref",
		"HEAD",
	})
	if not raw then
		return nil, nil
	end
	local results = vim.split(fn.trim(raw), "\n")
	return results[1], M._process_abbrev_head(results[2], results[3], cwd)
end

--- Internal helper: resolve "HEAD" to its short SHA when in detached-HEAD state. (Independent
--- of, but functionally mirrors, gitsigns.nvim's own internal function of the same purpose.)
--- @param gitdir string|nil
--- @param head_str string
--- @param path string
--- @return string
function M._process_abbrev_head(gitdir, head_str, path)
	if not gitdir then
		return head_str
	end
	if head_str == "HEAD" then
		local result = M.run_git_cmd({ "git", "-C", path, "--no-pager", "rev-parse", "--short", "HEAD" })
		return result and fn.trim(result) or head_str
	end
	return head_str
end

-- ============================================================================
-- LSP helpers
-- ============================================================================

--- Build the default LSP client capabilities table: adds nvim-ufo's folding-range support and
--- merges in blink.cmp's completion capabilities when available.
--- @return lsp.ClientCapabilities
function M.get_lsp_capabilities() -- This util is used by lspconfig.lua
	local caps = vim.lsp.protocol.make_client_capabilities()

	caps.textDocument.foldingRange = { -- consumed by nvim-ufo (plugins/ui/ufo.lua) for LSP-based folding
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	local has_blink, blink = pcall(require, "blink.cmp")
	if has_blink then
		-- Hand OUR capabilities in as blink.cmp's override argument so IT merges them in
		-- (the pattern blink.cmp's own docs show), rather than merging both tables ourselves.
		caps = blink.get_lsp_capabilities(caps)
	end

	return caps
end

-- ============================================================================
-- Theming
-- ============================================================================

--- The 7 highlight-group names rainbow-delimiters.nvim defines for its own nesting colors
--- (RainbowDelimiterRed/Yellow/Blue/Orange/Green/Violet/Cyan, in that order — deliberately
--- non-ROYGBIV so adjacent levels contrast more; verified against the plugin's own
--- lua/rainbow-delimiters/default.lua rather than assumed). plugins/treesitter/
--- rainbow-delimiters.lua points at this same list rather than a hand-typed copy, and it
--- follow the active colorscheme: tokyonight/catppuccin/kanagawa (themes.lua) all ship their
--- own overrides for these exact group names, so no hex codes need to be hand-maintained here.
--- Second consumer as of this pass: plugins/ui/snacks.lua points its per-level indent-guide
--- highlights (`indent.indent.hl`) at this exact list too, so bracket nesting and indent depth
--- share one color source instead of two independently-cycling rainbows.
--- @type string[]
M.rainbow_delimiter_groups = { -- This util is used by rainbow-delimiters.lua and snacks.lua
	"RainbowDelimiterRed",
	"RainbowDelimiterYellow",
	"RainbowDelimiterBlue",
	"RainbowDelimiterOrange",
	"RainbowDelimiterGreen",
	"RainbowDelimiterViolet",
	"RainbowDelimiterCyan",
}

-- ============================================================================
-- Randomness
-- ============================================================================

--- Return a random integer in [low, high] inclusive.
--- @param low integer
--- @param high integer
--- @return integer
function M.rand_int(low, high) -- Internal helper for rand_element() below, and used directly by cowboy()
	math.randomseed(os.time())
	return math.random(low, high)
end

--- Return a random element from a sequence.
--- @param seq any[]
--- @return any
function M.rand_element(seq) -- General helper, not currently called anywhere in this config
	return seq[M.rand_int(1, #seq)]
end

-- ============================================================================
-- UI / misc
-- ============================================================================

--- Build a window-title string: hostname (Linux only), buffer path, last-modified time.
--- @return string
function M.get_titlestr() -- General helper, not currently called anywhere in this config (options.lua's titlestring uses get_current_branch_name() instead)
	local title_str = vim.g.is_linux and (fn.hostname() .. "  ") or ""
	local buf_path = fn.expand("%:p:~")
	title_str = title_str .. buf_path .. "  "

	if vim.bo.buflisted and buf_path ~= "" then
		title_str = title_str .. fn.strftime("%Y-%m-%d %H:%M:%S%z", fn.getftime(fn.expand("%")))
	end
	return title_str
end

--- Return the active Python virtual-env name (venv checked before conda), or "".
--- @return string
function M.get_virtual_env() -- This util is used by lualine.lua
	local venv_path = os.getenv("VIRTUAL_ENV")
	if venv_path then
		return fn.fnamemodify(venv_path, ":t")
	end
	return os.getenv("CONDA_DEFAULT_ENV") or ""
end

--- Throttle repeated h/j/k/l/+/- and nag after 10 consecutive presses.
--- From LazyVim's lua/lazyvim/config/keymaps.lua, not from jdhao's config.
function M.cowboy() -- This util is used by mappings.lua
	for _, key in ipairs({ "h", "j", "k", "l", "+", "-" }) do
		local count = 0
		local timer = assert(vim.uv.new_timer())
		vim.keymap.set("n", key, function()
			if vim.v.count > 0 then
				count = 0
			end
			if count >= 10 and vim.bo.buftype ~= "nofile" then
				local ok = pcall(vim.notify, "Hold it Cowboy!", vim.log.levels.WARN, {
					icon = "🤠",
					id = "cowboy",
					keep = function()
						return count >= 10
					end,
				})
				if not ok then
					return key
				end
			else
				count = count + 1
				timer:start(2000, 0, function()
					count = 0
				end)
				return key
			end
		end, { expr = true, silent = true })
	end
end

return M
