local M = {}

local function get_relative_path()
	local file = vim.fn.expand("%:p")
	local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("%s+", "")
	if git_root == "" then
		-- Not in a git repository? Return the full file path as fallback.
		return file
	end
	-- Remove the git root prefix (and a possible trailing slash) from the file path.
	local relative_path = file:gsub("^" .. vim.pesc(git_root) .. "/?", "")
	return relative_path
end

local function get_remote_url()
	local handle = io.popen("git remote get-url origin 2>/dev/null")
	local result = handle and handle:read("*a") or ""
	if handle then
		handle:close()
	end
	return vim.trim(result)
end

local function detect_provider(remote)
	local domain = remote:match("@?([^:/]+)")
	local host = require("ygr").get_opts().provider_map[domain]
	if host then
		return host
	end
	if remote:find("github") then
		return "github"
	end
	if remote:find("gitlab") then
		return "gitlab"
	end
	if remote:find("bitbucket") then
		return "bitbucket"
	end
	return nil
end

local function get_remote_ref()
	local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
	if branch == "HEAD" then
		return vim.fn.system("git rev-parse HEAD"):gsub("\n", "")
	end
	return branch
end

local function build_url(remote, provider, ref, file, line1, line2)
	-- Strip .git and extract domain + user/repo
	remote = remote:gsub("%.git$", "")

	-- Normalize to https://<domain>/<user>/<repo>
	local domain, user, repo

	if remote:match("^git@") then
		-- SSH: git@github.com:user/repo
		domain, user, repo = remote:match("^git@([^:]+):([^/]+)/(.+)$")
	elseif remote:match("^https?://") then
		-- HTTPS: https://github.com/user/repo
		domain, user, repo = remote:match("^https?://([^/]+)/([^/]+)/(.+)$")
	end

	if not (domain and user and repo) then
		vim.notify("Failed to parse git remote URL: " .. remote, vim.log.levels.ERROR)
		return nil
	end

	local lines = ""
	if line1 and line2 and line1 ~= line2 then
		lines = "#L" .. line1 .. "-L" .. line2
	elseif line1 then
		lines = "#L" .. line1
	end

	local base = ("https://%s/%s/%s"):format(domain, user, repo)

	if provider == "github" then
		return ("%s/blob/%s/%s%s"):format(base, ref, file, lines)
	elseif provider == "gitlab" then
		return ("%s/-/blob/%s/%s%s"):format(base, ref, file, lines)
	elseif provider == "bitbucket" then
		return ("%s/src/%s/%s%s"):format(base, ref, file, lines)
	else
		vim.notify("Unsupported provider: " .. tostring(provider), vim.log.levels.ERROR)
		return nil
	end
end

function M.copy_git_link(line1, line2, only_open)
	local file = get_relative_path()
	local remote = get_remote_url()
	local provider = detect_provider(remote)
	local ref = get_remote_ref()
	local url = build_url(remote, provider, ref, file, line1, line2)
	if not url then
		vim.notify("ygr: Failed to build URL", vim.log.levels.ERROR)
		return
	end

	if require("ygr").get_opts().preview_link then
		vim.notify("Generated link:\n" .. url)
	end

	if only_open or require("ygr").get_opts().also_open then
		local open_cmd = vim.fn.has("mac") == 1 and "open"
		    or vim.fn.has("unix") == 1 and "xdg-open"
		    or vim.fn.has("win32") == 1 and "start"
		if open_cmd then
			vim.fn.jobstart({ open_cmd, url }, { detach = true })
		end
	end

	if not only_open then
		vim.fn.setreg("+", url)
		vim.notify("Copied Git link to clipboard")
	end
end

return M
