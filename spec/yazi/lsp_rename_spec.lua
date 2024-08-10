local luassert = require("luassert")
local lsp_rename = require("yazi.lsp.rename")

describe("renaming files with LSP support", function()
  -- It's pretty hard to test this as it would require a running LSP server.
  -- There are some examples of this, e.g.
  -- https://github.com/pmizio/typescript-tools.nvim/blob/master/tests/editor_spec.lua
  --
  -- Maybe more testing could be added later.
  it("does nothing if no LSP is running", function()
    local result = lsp_rename.file_renamed("test-file.txt", "test-file2.txt")
    luassert.is_nil(result)
  end)
end)
