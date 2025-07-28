# Emitting Commands to Yazi

> [!NOTE]
>
> This is an advanced feature that requires some manual coding.

When Yazi is running, it supports receiving instructions to execute yazi
commands. These can be sent using `ya emit-to`:

- <https://yazi-rs.github.io/docs/dds#ya-emit>

The available commands are documented in the Yazi documentation:

- <https://yazi-rs.github.io/docs/configuration/keymap>

## Example: start yazi and immediately enter find mode

```lua
-- open yazi and immediately enter find mode ("Find next") in yazi
vim.keymap.set("n", "<leader>r", function()
  require("yazi").yazi({
    ---@diagnostic disable-next-line: missing-fields
    hooks = {
      on_yazi_ready = function(_, _, process_api)
        -- https://yazi-rs.github.io/docs/configuration/keymap/#manager.find
        process_api:emit_to_yazi({ "find", "--smart" })
      end,
    },
  })
end)
```

An end-to-end tested example of this can be found in
[add_keybinding_to_start_yazi_and_find.lua](../integration-tests/test-environment/config-modifications/yazi_config/add_keybinding_to_start_yazi_and_find.lua)
file.
