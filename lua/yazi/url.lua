--- Working with the urls that yazi uses to address files.
---
--- This is a stable entry point for plugin users: the implementation may move
--- within yazi.nvim, but this module stays where it is.
local M = {}

-- yazi may include additional information in urls
-- https://github.com/sxyazi/yazi/issues/3510#issuecomment-3710915309
--
-- A url addressing a file inside a "view" (yazi's virtual file system used for
-- search results) carries the parameters of that view as an extra path
-- segment, so that yazi can reconstruct the view from the url alone:
--
--     fd://default:1:1/@d312s3lua1aA1h1//Users/mikavilpas/git/mikavilpas/yazi.nvim/yazi-plugin/nvim.yazi/keymaps.lua
--     ^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--     |                |                      |
--     scheme + domain  |                      |
--                      the view's parameters  |
--                                             the physical path
--     fd://default:2:2/@d312safile_3.txt1aA1h0//home/user/file_3.txt
--
-- The parameters are url encoded, so they never contain a `/` of their own.
-- Views were introduced in https://github.com/sxyazi/yazi/pull/4335; older
-- yazi versions use a `search://keyword:3:3//path` url, which has no such
-- segment.
---@param input string a url as given by yazi
---@return string # the path of the file the url points to
function M.to_path(input)
  local url = input:gsub("^.-://.-/", "")
  url = url:gsub("^@[^/]*/", "")
  return url
end

return M
