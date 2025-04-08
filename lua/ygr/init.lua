local M = {}

M.opts = {
	provider_map = {},
	also_open = false,
	preview_link = false,
}

function M.get_opts()
	return M.opts
end

function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
	local link = require("ygr.gitlink")

	vim.keymap.set("n", "ygr", function()
		link.copy_git_link(vim.fn.line("."))
	end, { desc = "Git link: copy" })

	vim.keymap.set("n", "ygR", function()
		link.copy_git_link(vim.fn.line("."), nil, true)
	end, { desc = "Git link: open" })

	vim.keymap.set("v", "ygr", function()
		link.copy_git_link(vim.fn.line("v"), vim.fn.line("."))
	end, { desc = "Git link: copy range" })

	vim.api.nvim_create_user_command("GitLink", function()
		link.copy_git_link(vim.fn.line("."))
	end, {})

	vim.api.nvim_create_user_command("GitLinkOpen", function()
		link.copy_git_link(vim.fn.line("."), nil, true)
	end, {})

	vim.api.nvim_create_user_command("GitLinkToggleOpen", function()
		M.opts.also_open = not M.opts.also_open
		vim.notify("GitLink also_open = " .. tostring(M.opts.also_open))
	end, {})
end

return M
