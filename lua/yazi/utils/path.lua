-- NOTE: This file contains code that was copied from
-- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/lua/neo-tree/utils/init.lua#L1033-L1066
-- as it seems neovim doesn't provide a built-in function for this.
--
local M = {}

---Escapes a path primarily relying on `vim.fn.fnameescape`. This function should
---only be used when preparing a path to be used in a vim command, such as `:e`.
---
---For Windows systems, this function handles punctuation characters that will
---be escaped, but may appear at the beginning of a path segment. For example,
---the path `C:\foo\(bar)\baz.txt` (where foo, (bar), and baz.txt are segments)
---will remain unchanged when escaped by `fnaemescape` on a Windows system.
---However, if that string is used to edit a file with `:e`, `:b`, etc., the open
---parenthesis will be treated as an escaped character and the path separator will
---be lost.
---
---For more details, see issue #889 when this function was introduced, and further
---discussions in #1264 and #1352.
---@param path string
---@return string
M.escape_path_for_cmd = function(path)
  local escaped_path = vim.fn.shellescape(path)
  if M.is_windows then
    -- Replace forward slash spaces with just spaces.
    escaped_path = escaped_path:gsub('\\ ', ' ')

    -- on windows, some punctuation preceeded by a `\` needs to have a second
    -- `\` added to preserve the path separator. this is a naive replacement and
    -- definitely not bullet proof. if we start finding issues with opening files
    -- or changing directories, look here first. #1382 was the first regression
    -- from the implementation that used lua's %p to match punctuation, which
    -- did not quite work. the following characters were tested on windows to
    -- be known to require an extra escape character.
    for _, c in ipairs({ '&', '(', ')', ';', '^', '`' }) do
      -- lua doesn't seem to have a problem with an unnecessary `%` escape
      -- (e.g., `%;`), so we can use it to ensure we match the punctuation
      -- for the ones that do (e.g., `%(` and `%^`)
      escaped_path = escaped_path:gsub('\\%' .. c, '\\%1')
    end

    escaped_path = string.format('"%s"', escaped_path)
  end
  return escaped_path
end

---The file system path separator for the current platform.
M.path_separator = '/'
M.is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win32unix') == 1
if M.is_windows == true then
  M.path_separator = '\\'
end

return M
