do
  local repo_root = assert(vim.env.HOME) .. "/../../../../"
  repo_root = vim.fn.fnamemodify(repo_root, ":p")
  assert(vim.uv.fs_stat(repo_root), "repo_root does not exist: " .. repo_root)
  vim.opt.runtimepath:prepend(repo_root)
end
