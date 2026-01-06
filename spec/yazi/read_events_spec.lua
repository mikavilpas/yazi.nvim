local assert = require("luassert")
local utils = require("yazi.utils")

describe("parsing yazi event file events", function()
  it("can parse nvim-cycle-buffer events", function()
    local data = {
      "nvim-cycle-buffer,1712242143209837,1712242143209837",
    }

    local events = utils.parse_events(data)

    assert.are.same(events, {
      { type = "cycle-buffer" },
    } --[[@as YaziNvimCycleBufferEvent[] ]])
  end)

  it("can parse rename events", function()
    local data = {
      'rename,1712242143209837,1712242143209837,{"tab":0,"from":"/Users/mikavilpas/git/yazi/file","to":"/Users/mikavilpas/git/yazi/file2"}',
      'rename,1,2,{"tab":0,"from":"search://.md:1:1//Users/mikavilpas/git/yazi/file3","to":"/Users/mikavilpas/git/yazi/file4"}',
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

      {
        type = "rename",
        yazi_id = "2",
        data = {
          tab = 0,
          from = "/Users/mikavilpas/git/yazi/file3",
          to = "/Users/mikavilpas/git/yazi/file4",
        },
      },
    } --[[@as YaziRenameEvent[] ]])
  end)

  it("can parse move events", function()
    local data = {
      'move,1,2,{"items":[{"from":"/tmp/test/test","to":"/tmp/test"}]}',
      'move,1,2,{"items":[{"from":"search://.md:1:1//tmp/test2/test","to":"search://.md:1:1//tmp/test2"}]}',
    }

    local events = utils.parse_events(data)

    assert.are_equal(#events, 2)
    assert.same(events[1].data.items, {
      {
        from = "/tmp/test/test",
        to = "/tmp/test",
      },
    })
    assert.same(events[2].data.items, {
      {
        from = "/tmp/test2/test",
        to = "/tmp/test2",
      },
    })
  end)

  it("can parse bulk events", function()
    local data = {
      'bulk,0,1720800121065599,{"changes":{"/tmp/test-directory/test":"/tmp/test-directory/test2"}}',
    }

    local events = utils.parse_events(data)

    assert.are.equal(#events, 1)
    assert.same(events[1].changes, {
      ["/tmp/test-directory/test"] = "/tmp/test-directory/test2",
    })
  end)

  it("can parse delete events", function()
    local data = {
      'delete,1,2,{"urls":["/tmp/test-directory/test_2"]}',
      'delete,1,2,{"urls":["search://.md:1:1//tmp/test-directory/test_3"]}',
    }

    local events = utils.parse_events(data)

    assert.are.same(events, {
      {
        type = "delete",
        yazi_id = "2",
        data = {
          urls = { "/tmp/test-directory/test_2" },
        },
      },
      {
        type = "delete",
        yazi_id = "2",
        data = {
          urls = { "/tmp/test-directory/test_3" },
        },
      },
    } --[[@as YaziDeleteEvent[] ]])
  end)

  it("can parse trash events", function()
    local data = {
      'trash,1,2,{"urls":["/tmp/test-directory/test_2"]}',
    }

    local events = utils.parse_events(data)

    assert.are.same(events, {
      {
        type = "trash",
        yazi_id = "2",
        data = {
          urls = { "/tmp/test-directory/test_2" },
        },
      },
    } --[[@as YaziTrashEvent[] ]])
  end)

  it("can parse cd events", function()
    local data = {
      'cd,1,2,{"tab":0,"url":"/tmp/test-directory"}',
    }

    local events = utils.parse_events(data)

    assert.are.same(events, {
      {
        type = "cd",
        yazi_id = "2",
        url = "/tmp/test-directory",
      },
    } --[[@as YaziChangeDirectoryEvent[] ]])
  end)

  it("can parse hover events", function()
    local data = {
      'hover,1,2,{"tab":0,"url":"/tmp/test-directory/test"}',
      'hover,1,2,{"tab":0,"url":"search://.md:1:1//tmp/test-directory/test"}',
    }

    local events = utils.parse_events(data)

    assert.are.same(events, {
      {
        type = "hover",
        yazi_id = "2",
        url = "/tmp/test-directory/test",
      },
      {
        type = "hover",
        yazi_id = "2",
        url = "/tmp/test-directory/test",
      },
    } --[[@as YaziHoverEvent[] ]])
  end)
end)
