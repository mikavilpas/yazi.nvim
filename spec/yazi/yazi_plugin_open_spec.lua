local keymaps = dofile("yazi-plugin/nvim.yazi/keymaps.lua")

describe("the bundled yazi plugin's guarded open action", function()
  it("registers Enter to run the guarded open action", function()
    local inserted_rule
    local rules = {
      insert = function(_, _, rule)
        inserted_rule = rule
      end,
    }

    assert.is_function(keymaps.register_guarded_open)
    keymaps.register_guarded_open(rules)

    assert.same({
      on = "<Enter>",
      run = "plugin nvim -- guarded_open",
      desc = "yazi.nvim: open selected files",
    }, inserted_rule)
  end)

  it("does not open when a directory is selected", function()
    local selected = {
      { cha = { is_dir = true } },
    }

    assert.is_false(
      keymaps.should_open(selected),
      "expected a selected directory to keep yazi open"
    )
  end)

  it("does not open a mixed selection containing a directory", function()
    local selected = {
      { cha = { is_dir = false } },
      { cha = { is_dir = true } },
    }

    assert.is_false(
      keymaps.should_open(selected),
      "expected a mixed selection to keep yazi open"
    )
  end)

  it("opens when only files are selected", function()
    local selected = {
      { cha = { is_dir = false } },
      { cha = { is_dir = false } },
    }

    assert.is_true(keymaps.should_open(selected))
  end)

  it("delegates to yazi when nothing is selected", function()
    assert.is_true(keymaps.should_open({}))
  end)
end)
