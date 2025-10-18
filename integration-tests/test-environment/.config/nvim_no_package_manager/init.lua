do
  local repo_root = assert(vim.env.HOME) .. "/../../../../"
  repo_root = vim.fn.fnamemodify(repo_root, ":p")
  assert(vim.uv.fs_stat(repo_root), "repo_root does not exist: " .. repo_root)
  vim.opt.runtimepath:prepend(repo_root)
end

do
  -- HACK: use the plenary that's already installed in the main test nvim
  -- environment. We can change this to use vim.pack.add once that is stable
  local plenary = assert(vim.env.HOME)
    .. "/../../.repro/data/nvim/lazy/plenary.nvim"
  plenary = vim.fn.fnamemodify(plenary, ":p")
  assert(vim.uv.fs_stat(plenary), "repo_root does not exist: " .. plenary)
  vim.opt.runtimepath:prepend(plenary)
end
