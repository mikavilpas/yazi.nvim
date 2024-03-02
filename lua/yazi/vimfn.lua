-- This file exists so that I can mock vim.fn functions in tests
-- https://github.com/nvim-lua/plenary.nvim/issues/166

local M = {}

function M.termopen(cmd, opts)
  return vim.fn.termopen(cmd, opts)
end

return M
