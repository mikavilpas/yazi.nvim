local M = {}

--- open floating window with nice borders
---@return number | nil, number | nil
function M.open_floating_window()
  local floating_window_scaling_factor =
    vim.g.yazi_floating_window_scaling_factor

  -- Why is this required?
  -- vim.g.yazi_floating_window_scaling_factor returns different types if the value is an integer or float
  if type(floating_window_scaling_factor) == 'table' then
    floating_window_scaling_factor = floating_window_scaling_factor[false]
  end

  local status, plenary = pcall(require, 'plenary.window.float')
  if
    status
    and vim.g.yazi_floating_window_use_plenary
    and vim.g.yazi_floating_window_use_plenary ~= 0
  then
    plenary.percentage_range_window(
      floating_window_scaling_factor,
      floating_window_scaling_factor
    )
    return
  end

  local height = math.ceil(vim.o.lines * floating_window_scaling_factor) - 1
  local width = math.ceil(vim.o.columns * floating_window_scaling_factor)

  local row = math.ceil(vim.o.lines - height) / 2
  local col = math.ceil(vim.o.columns - width) / 2

  local border_opts = {
    style = 'minimal',
    relative = 'editor',
    row = row - 1,
    col = col - 1,
    width = width + 2,
    height = height + 2,
  }

  local opts = {
    style = 'minimal',
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
  }

  local topleft, top, topright, right, botright, bot, botleft, left
  local window_chars = vim.g.yazi_floating_window_border_chars
  if type(window_chars) == 'table' and #window_chars == 8 then
    topleft, top, topright, right, botright, bot, botleft, left =
      unpack(window_chars)
  else
    topleft, top, topright, right, botright, bot, botleft, left =
      '╭', '─', '╮', '│', '╯', '─', '╰', '│'
  end

  local border_lines = { topleft .. string.rep(top, width) .. topright }
  local middle_line = left .. string.rep(' ', width) .. right
  for _ = 1, height do
    table.insert(border_lines, middle_line)
  end
  table.insert(border_lines, botleft .. string.rep(bot, width) .. botright)

  -- create a unlisted scratch buffer for the border
  local border_buffer = vim.api.nvim_create_buf(false, true)

  -- set border_lines in the border buffer from start 0 to end -1 and strict_indexing false
  vim.api.nvim_buf_set_lines(border_buffer, 0, -1, true, border_lines)
  -- create border window
  local border_window = vim.api.nvim_open_win(border_buffer, true, border_opts)
  vim.api.nvim_set_hl(0, 'YaziBorder', { link = 'Normal', default = true })
  vim.cmd('set winhl=NormalFloat:YaziBorder')

  local yazi_buffer = vim.api.nvim_create_buf(false, true)
  -- create file window, enter the window, and use the options defined in opts
  local win = vim.api.nvim_open_win(yazi_buffer, true, opts)

  vim.bo[yazi_buffer].filetype = 'yazi'

  vim.cmd('setlocal bufhidden=hide')
  vim.cmd('setlocal nocursorcolumn')
  vim.api.nvim_set_hl(0, 'YaziFloat', { link = 'Normal', default = true })
  vim.cmd('setlocal winhl=NormalFloat:YaziFloat')
  vim.cmd('set winblend=' .. vim.g.yazi_floating_window_winblend)

  -- use autocommand to ensure that the border_buffer closes at the same time as the main buffer
  vim.cmd("autocmd WinLeave <buffer> silent! execute 'hide'")
  local cmd = [[autocmd WinLeave <buffer> silent! execute 'silent bdelete! %s']]
  vim.cmd(cmd:format(border_buffer))

  return win, border_window
end

return M
