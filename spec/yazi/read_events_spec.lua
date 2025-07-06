local assert = require("luassert")
local utils = require("yazi.utils")

describe("parsing yazi event file events", function()
  it("can parse rename events", function()
    local data = {
      'rename,1712242143209837,1712242143209837,{"tab":0,"from":"/Users/mikavilpas/git/yazi/file","to":"/Users/mikavilpas/git/yazi/file2"}',
    }

    local events = utils.parse_events(data)

    assert.are.same(events, {
      {
        type = "rename",
        yazi_id = "1712242143209837",
        data = {
          tab = 0,
          from = "/Users/mikavilpas/git/yazi/file",
          to = "/Users/mikavilpas/git/yazi/file2",
        },
      },
    })
  end)

  it("can parse delete events", function()
    local data = {
      'delete,1712766606832135,1712766606832135,{"urls":["/tmp/test-directory/test_2"]}',
    }

    local events = utils.parse_events(data)

    assert.are.same(events, {
      {
        type = "delete",
        yazi_id = "1712766606832135",
        data = {
          urls = { "/tmp/test-directory/test_2" },
        },
      },
    })
  end)
end)
