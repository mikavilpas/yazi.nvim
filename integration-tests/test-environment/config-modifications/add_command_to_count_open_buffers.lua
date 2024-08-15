vim.api.nvim_create_user_command("CountBuffers", function()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local msg = "Number of open buffers: " .. #buffers
  print(msg)
end, {})
