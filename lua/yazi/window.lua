local M = {}

---@class (exact) YaziFloatingWindow
---@field new fun(config: YaziConfig): YaziFloatingWindow
---@field win integer floating_window_id
---@field content_buffer integer
---@field config YaziConfig
---@field private cleanup fun(): nil
local YaziFloatingWindow = {}
---@diagnostic disable-next-line: inject-field
YaziFloatingWindow.__index = YaziFloatingWindow

M.YaziFloatingWindow = YaziFloatingWindow

---@param config YaziConfig
function YaziFloatingWindow.new(config)
  local self = setmetatable({}, YaziFloatingWindow)

  self.config = config

  return self
end

function YaziFloatingWindow:close()
  pcall(self.cleanup)

  if
    vim.api.nvim_buf_is_valid(self.content_buffer)
    and vim.api.nvim_buf_is_loaded(self.content_buffer)
  then
    vim.api.nvim_buf_delete(self.content_buffer, { force = true })
  end

  if vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_close(self.win, true)
  end
end

function YaziFloatingWindow:open_and_display()
  local height = math.ceil(
    vim.o.lines * self.config.floating_window_scaling_factor
  ) - 1
  local width =
    math.ceil(vim.o.columns * self.config.floating_window_scaling_factor)

  local row = math.ceil(vim.o.lines - height) / 2
  local col = math.ceil(vim.o.columns - width) / 2

  ---@type vim.api.keyset.win_config
  local opts = {
    style = 'minimal',
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    border = self.config.yazi_floating_window_border,
  }

  local yazi_buffer = vim.api.nvim_create_buf(false, true)
  -- create file window, enter the window, and use the options defined in opts
  local win = vim.api.nvim_open_win(yazi_buffer, true, opts)
  self.win = win
  self.content_buffer = yazi_buffer

  vim.bo[yazi_buffer].filetype = 'yazi'

  vim.cmd('setlocal bufhidden=hide')
  vim.cmd('setlocal nocursorcolumn')
  vim.api.nvim_set_hl(0, 'YaziFloat', { link = 'Normal', default = true })
  vim.cmd('setlocal winhl=NormalFloat:YaziFloat')
  vim.cmd('set winblend=' .. self.config.yazi_floating_window_winblend)

  if self.config.enable_mouse_support == true then
    -- Disable nvim mouse support so that yazi can handle mouse events instead
    local original_mouse_settings = vim.o.mouse
    vim.api.nvim_create_autocmd({ 'TermEnter', 'WinEnter' }, {
      buffer = yazi_buffer,
      callback = function()
        vim.api.nvim_set_option_value('mouse', '', {})
      end,
    })

    self.cleanup = function()
      -- Restore mouse mode on exiting
      vim.api.nvim_set_option_value('mouse', original_mouse_settings, {})
    end
  end

  vim.api.nvim_create_autocmd({ 'WinLeave', 'TermLeave' }, {
    buffer = yazi_buffer,
    callback = function()
      self:close()
    end,
  })

  return self
end

return M
