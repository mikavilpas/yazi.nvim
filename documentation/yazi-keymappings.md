# Recipes for defining yazi.nvim keymaps in yazi's config

> [!TIP]
>
> 🧙🏻 Advanced setup
>
> These features are for advanced users and might require some development
> depending on what you want to accomplish.

## yazi keymaps

**Problem:** As a yazi.nvim user, when I have yazi open and I press a common key
such as `<backspace>`, I want to make something happen in yazi.nvim (neovim).

**Solution:** We will define a yazi keymap that sends a message to yazi.nvim.
Yazi.nvim can react to this element _when yazi is open_ and execute something
that you define.

This also lets you use the key for other tasks in yazi - for example, when
typing text. A regular yazi.nvim keymap would not work in this case, as it would
always override any use of the key.

### Define a keymap in yazi's config

Define the key you want to use in yazi's keymap.toml config:

```toml
# keymap.toml
#
# send an event with no data
[[manager.prepend_keymap]]
on = "<C-p>"
run = """shell 'ya pub-to 0 MyMessageNoData'"""

# send an event that also has json data
[[manager.prepend_keymap]]
on = "<C-h>"
run = """shell "ya pub-to 0 MyMessageWithData --json '{\\"somedata\\": 123}'""""
```

### Define a handler in yazi.nvim

Add the following code to your configuration:

```lua
-- e.g. init.lua
---@module "yazi"

require("yazi").config.forwarded_dds_events =
  { "MyMessageNoData", "MyMessageWithData" }

vim.api.nvim_create_autocmd("User", {
  pattern = "YaziDDSCustom",
  -- see `:help event-args`
  ---@param event yazi.AutoCmdEvent
  callback = function(event)
    -- printing the messages will allow seeing them with `:messages` in tests
    print(vim.inspect({
      string.format(
        "Just received a YaziDDSCustom event '%s'!",
        event.data.type
      ),
      event.data,
    }))
  end,
})
```

### Resources

- Originally discussed in
  [#547](https://github.com/mikavilpas/yazi.nvim/issues/547)
- See the example in the integration-tests setup as a fully tested reference
  - yazi's config modifications for the tests are available in
    [keymap.toml](../integration-tests/test-environment/.config/yazi/keymap.toml)
  - the custom yazi.nvim event handler definition for tests is available in
    [notify_custom_events.lua](../integration-tests/test-environment/config-modifications/notify_custom_events.lua)
- yazi's documentation for keymaps
  <https://yazi-rs.github.io/docs/configuration/keymap>
- the key names that yazi supports in mappings are available in the source code
  <https://github.com/sxyazi/yazi/blob/1f32601dc4163b419257b74777271c283a32dca6/yazi-config/src/keymap/key.rs>

## Define different behavior when yazi is running outside of neovim

**Problem:** As a yazi.nvim user, I sometimes use yazi outside of Neovim and
yazi.nvim. When yazi.nvim is open, I want to do something different than when it
is not open.

**Solution:** We will define a keymap that checks if nvim is open.

When yazi.nvim starts yazi, it sets a special environment variable `NVIM_CWD` to
the current working directory of Neovim. We can use this to check if Neovim is
running.

### Define a keymap in yazi's config

```toml
# Augment https://yazi-rs.github.io/docs/tips/#cd-to-git-root - go to the nvim
# cwd when neovim is open, and to the git root when it is not
[[manager.prepend_keymap]]
on = ["g", "r"]
run = '''
  shell 'ya pub dds-cd --str "${NVIM_CWD:-$(git rev-parse --show-toplevel 2>/dev/null)}"'
'''
```
