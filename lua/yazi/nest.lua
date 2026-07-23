local M = {}

M.config = nil
M.context = nil

local PATTERN = "*/yazi-*/bulk-*"

local function chan_request(chan, cmd, args)
  vim.rpcrequest(chan, "nvim_exec_lua", string.dump(cmd), args)
end

--- Register autocmds for nested nvim session handling.
---@param augroup integer
---@param keymaps table
function M.setup(augroup, keymaps)
  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    pattern = PATTERN,
    callback = function()
      if vim.env.NVIM == nil then
        return
      end
      local chan = vim.fn.sockconnect("pipe", vim.env.NVIM, { rpc = true })
      local cmd = function(cfg)
        for _, key in pairs(cfg) do
          if type(key) == "string" then
            pcall(vim.keymap.del, "t", key, { buffer = YaziBuffer })
          end
        end
      end
      chan_request(chan, cmd, { keymaps.keymaps })
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = augroup,
    pattern = PATTERN,
    callback = function()
      if vim.env.NVIM == nil then
        return
      end
      local chan = vim.fn.sockconnect("pipe", vim.env.NVIM, { rpc = true })
      local cmd = function()
        vim.api.nvim_exec_autocmds("User", { pattern = "YaziNestedClosed" })
      end
      chan_request(chan, cmd, {})
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "YaziNestedClosed",
    callback = function()
      require("yazi.config").set_keymappings(YaziBuffer, M.config, M.context)
    end,
  })
end

return M
