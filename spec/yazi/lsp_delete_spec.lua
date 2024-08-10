local luassert = require("luassert")
local lsp_delete = require("yazi.lsp.delete")

describe("renaming files with LSP support", function()
  -- It's pretty hard to test this as it would require a running LSP server.
  -- There are some examples of this, e.g.
  -- https://github.com/pmizio/typescript-tools.nvim/blob/master/tests/editor_spec.lua
  --
  -- Maybe more testing could be added later.
  it("does nothing if no LSP is running", function()
    local result = lsp_delete.file_deleted("test-file.txt")
    luassert.is_nil(result)
  end)
end)
