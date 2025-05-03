local assert = require("luassert")
local match = require("luassert.match")
local spy = require("luassert.spy")

local retry = require("yazi.process.retry")

describe("retry", function()
  it("retries the action if it fails", function()
    local action_call_count = 0
    local action = spy.new(function()
      action_call_count = action_call_count + 1
      error("Action failed, so that it will be retried")
    end)
    local on_failure = spy.new(function() end)
    local on_final_failure = spy.new(function() end)

    retry.retry({
      action = action --[[@as fun(): unknown]],
      retries = 15,
      delay = 1,
      on_failure = on_failure --[[@as fun(fail_result: unknown, retries_remaining: integer)]],
      on_final_failure = on_final_failure --[[@as fun(fail_result: unknown)]],
    })

    vim.wait(2000, function()
      return action_call_count == 15
    end, 50)
    assert.spy(action).was.called(15)
    assert.spy(on_failure).was.called(14)

    assert.spy(on_final_failure).was.called(1)
    assert
      .spy(on_failure).was
      .called_with(match.matches("Action failed, so that it will be retried", 1, true), 1)
  end)

  it("exits as soon as the action succeeds", function()
    local action_call_count = 0
    local action = spy.new(function()
      action_call_count = action_call_count + 1
    end)
    local on_failure = spy.new(function() end)
    local on_final_failure = spy.new(function() end)

    retry.retry({
      action = action --[[@as fun(): unknown]],
      retries = 15,
      delay = 1,
      on_failure = on_failure --[[@as fun(fail_result: unknown, retries_remaining: integer)]],
      on_final_failure = on_final_failure --[[@as fun(fail_result: unknown)]],
    })

    vim.wait(1000, function()
      local success = pcall(function()
        assert.spy(action).was.called(1)
      end)
      return success
    end, 50)

    assert.spy(action).was.called(1)
    assert.spy(on_failure).was.not_called()
    assert.spy(on_final_failure).was.not_called()
  end)
end)
