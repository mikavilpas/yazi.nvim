local assert = require('luassert')
local utils = require('yazi.utils')

describe('parsing yazi event file events', function()
  it('can parse rename events', function()
    local data = {
      'rename,1712242143209837,1712242143209837,{"tab":0,"from":"/Users/mikavilpas/git/yazi/file","to":"/Users/mikavilpas/git/yazi/file2"}',
    }

    local events = utils.parse_events(data)

    assert.are.same(events, {
      {
        type = 'rename',
        timestamp = '1712242143209837',
        id = '1712242143209837',
        data = {
          tab = 0,
          from = '/Users/mikavilpas/git/yazi/file',
          to = '/Users/mikavilpas/git/yazi/file2',
        },
      },
    })
  end)
end)
