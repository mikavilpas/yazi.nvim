local Log = require("yazi.log")

local M = {}

---@class (exact) YaziFloatingWindow
---@field new fun(config: YaziConfig): YaziFloatingWindow
---@field win integer floating_window_id
---@field content_buffer integer
---@field config YaziConfig
---@field on_resized fun(event: yazi.FloatingWindowResizedEvent): nil # allows resizing the contents (the yazi terminal) inside of the floating window
---@field private cleanup fun(): nil
local YaziFloatingWindow = {}
---@diagnostic disable-next-line: inject-field
YaziFloatingWindow.__index = YaziFloatingWindow

---@class (exact) yazi.FloatingWindowResizedEvent
---@field win_height integer
---@field win_width integer

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
    Log:debug(
      string.format(
        "YaziFloatingWindow closing (content_buffer: %s, win: %s)",
        self.content_buffer,
        self.win
      )
    )
  end
end

---@param config YaziConfig
local function get_window_dimensions(config)
  -- some of the sizing logic is borrowed from lazy.nvim
  -- https://github.com/folke/lazy.nvim/blob/077102c5bfc578693f12377846d427f49bc50076/lua/lazy/view/float.lua?plain=1#L87-L89
  local function size(max, value)
    return value > 1 and math.min(value, max) or math.floor(max * value)
  end

  local height
  local width

  if type(config.floating_window_scaling_factor) == "number" then
    height = size(vim.o.lines, config.floating_window_scaling_factor)
    width = size(vim.o.columns, config.floating_window_scaling_factor)
  else
    assert(
      type(config.floating_window_scaling_factor) == "table",
      "floating_window_scaling_factor must be a number or a table"
    )
    height = size(vim.o.lines, config.floating_window_scaling_factor.height)
    width = size(vim.o.columns, config.floating_window_scaling_factor.width)
  end

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  return {
    height = height,
    width = width,
    row = row,
    col = col,
  }
end

function YaziFloatingWindow:open_and_display()
  local dimensions = get_window_dimensions(self.config)

  ---@type vim.api.keyset.win_config
  local opts = {
    style = "minimal",
    relative = "editor",
    row = dimensions.row,
    col = dimensions.col,
    width = dimensions.width,
    height = dimensions.height,
    border = self.config.yazi_floating_window_border,
  }

  local yazi_buffer = vim.api.nvim_create_buf(false, true)
  -- create file window, enter the window, and use the options defined in opts
  local win = vim.api.nvim_open_win(yazi_buffer, true, opts)
  self.win = win
  self.content_buffer = yazi_buffer
  Log:debug(
    string.format(
      "YaziFloatingWindow opening (content_buffer: %s, win: %s)",
      self.content_buffer,
      self.win
    )
  )

  vim.bo[yazi_buffer].filetype = "yazi"

  vim.cmd("setlocal bufhidden=hide")
  vim.cmd("setlocal nocursorcolumn")
  vim.api.nvim_set_hl(0, "YaziFloat", { link = "Normal", default = true })
  vim.cmd("setlocal winhl=NormalFloat:YaziFloat")
  vim.cmd("set winblend=" .. self.config.yazi_floating_window_winblend)

  vim.api.nvim_create_autocmd({ "WinLeave" }, {
    buffer = yazi_buffer,
    callback = function()
      self:close()
    end,
  })

  if self.config.enable_mouse_support == true then
    self:add_hacky_mouse_support(yazi_buffer)
  end

  vim.api.nvim_create_autocmd({ "VimResized" }, {
    buffer = yazi_buffer,
    callback = function()
      local dims = get_window_dimensions(self.config)

      vim.api.nvim_win_set_config(win, {
        width = dims.width,
        height = dims.height,
        row = dims.row,
        col = dims.col,
        relative = "editor",
        style = "minimal",
      })

      self.on_resized({
        win_height = dims.height,
        win_width = dims.width,
      })
    end,
  })

  -- Prevents a bug with lazyvim involving which-key.nvim: pressing <esc> in
  -- the terminal window opens which-key and ignores the keypress.
  vim.keymap.set("t", "<esc>", "<esc>", { buffer = yazi_buffer })

  return self
end

--- Compatibility with tmux and neovim mouse support
--- https://github.com/mikavilpas/yazi.nvim/issues/176
--- https://github.com/mikavilpas/yazi.nvim/issues/49
---@param yazi_buffer integer
function YaziFloatingWindow:add_hacky_mouse_support(yazi_buffer)
  -- Disable nvim mouse support so that yazi can handle mouse events instead
  local original_mouse_settings = vim.o.mouse
  vim.api.nvim_create_autocmd({ "TermEnter", "WinEnter" }, {
    buffer = yazi_buffer,
    callback = function()
      vim.api.nvim_set_option_value("mouse", "", {})
    end,
  })

  -- Extra mouse fix for tmux
  -- If tmux mouse mode is enabled
  if os.getenv("TMUX") then
    local output = vim.fn.system('tmux display -p "#{mouse}"')
    if output:sub(1, 1) == "1" then
      vim.api.nvim_create_autocmd({ "TermEnter", "WinEnter" }, {
        buffer = yazi_buffer,
        callback = function()
          vim.fn.system("tmux set mouse off")
        end,
      })
    end
  end

  self.cleanup = function()
    -- Restore mouse mode on exiting
    vim.api.nvim_set_option_value("mouse", original_mouse_settings, {})
    if os.getenv("TMUX") then
      vim.fn.system("tmux set mouse on")
    end
  end
end

return M
