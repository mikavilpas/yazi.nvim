---@module "plenary.path"

local assert = require("luassert")
local mock = require("luassert.mock")
local config = require("yazi.config")
local plenary_path = require("plenary.path")

describe("the grug-far integration (search and replace)", function()
  local mock_grug_far = { grug_far = function() end }

  before_each(function()
    mock.revert(mock_grug_far)
    package.loaded["grug-far"] = mock(mock_grug_far)
  end)

  it("opens yazi with the current file selected", function()
    local tmp_path = plenary_path:new("/tmp/folder with spaces/")

    config.default().integrations.replace_in_directory(tmp_path)

    assert.spy(mock_grug_far.grug_far).was_called_with({
      prefills = {
        paths = "/tmp/folder\\ with\\ spaces",
      },
    })
  end)
end)
