local assert = require("luassert")
local ActiveContexts = require("yazi.active_contexts")

---A stand-in for a real context. Only identity matters to ActiveContexts, but
---the eviction logging reads `ya_process:id()`, so provide that much.
---@param name string
---@return YaziActiveContext
local function context(name)
  ---@diagnostic disable-next-line: missing-fields, return-type-mismatch
  return {
    ya_process = {
      id = function()
        return name
      end,
    },
  }
end

describe("ActiveContexts", function()
  it("has no current context when nothing has been pushed", function()
    local contexts = ActiveContexts.new(2)

    assert.is_nil(contexts:current())
    assert.same({}, contexts:all())
  end)

  it("reports the most recently pushed context as the current one", function()
    local contexts = ActiveContexts.new(2)
    local first, second = context("first"), context("second")

    contexts:push(first)
    assert.equal(first, contexts:current())

    contexts:push(second)
    assert.equal(second, contexts:current())
  end)

  it("returns all known contexts, newest first", function()
    local contexts = ActiveContexts.new(3)
    local first, second, third =
      context("first"), context("second"), context("third")

    contexts:push(first)
    contexts:push(second)
    contexts:push(third)

    assert.same({ third, second, first }, contexts:all())
  end)

  it("drops the oldest context when the capacity is exceeded", function()
    local contexts = ActiveContexts.new(2)
    local first, second, third =
      context("first"), context("second"), context("third")

    contexts:push(first)
    contexts:push(second)
    contexts:push(third)

    assert.same({ third, second }, contexts:all())
    assert.equal(third, contexts:current())
  end)

  it("does not let mutating the result of all() affect it", function()
    local contexts = ActiveContexts.new(2)
    local only = context("only")
    contexts:push(only)

    local items = contexts:all()
    table.remove(items)

    assert.same({ only }, contexts:all())
  end)

  describe("remove()", function()
    it("removes the context, keeping the rest in order", function()
      local contexts = ActiveContexts.new(3)
      local first, second, third =
        context("first"), context("second"), context("third")
      contexts:push(first)
      contexts:push(second)
      contexts:push(third)

      assert.is_true(contexts:remove(second))

      assert.same({ third, first }, contexts:all())
    end)

    it("makes the previous context current again", function()
      local contexts = ActiveContexts.new(2)
      local first, second = context("first"), context("second")
      contexts:push(first)
      contexts:push(second)

      assert.is_true(contexts:remove(second))

      assert.equal(first, contexts:current())
    end)

    it("reports removing an unknown context as a no-op", function()
      local contexts = ActiveContexts.new(2)
      local only = context("only")
      contexts:push(only)

      assert.is_false(contexts:remove(context("never pushed")))
      assert.same({ only }, contexts:all())
    end)

    it("is safe to remove the same context twice", function()
      local contexts = ActiveContexts.new(2)
      local only = context("only")
      contexts:push(only)

      assert.is_true(contexts:remove(only))
      assert.is_false(contexts:remove(only))

      assert.same({}, contexts:all())
    end)
  end)
end)
