# Copying the relative path to files

## Usage with yazi

When yazi is open, you can copy the relative path from the current file to other
files or directories. By default it's mapped to `<c-y>` and requires GNU
`realpath` or `grealpath` on OSX.

## Usage with snacks.nvim

If you use
[snacks.nvim](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md),
you can also copy relative file paths with the snacks.nvim picker. To do this,
do the following in your config:

- create a snacks.nvim keymap available in the picker, e.g. for `<C-y>` in
  normal and insert mode
- ```lua
  ---@module "lazy"
  ---@type LazySpec
  return {
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
        picker = {
          win = {
            input = {
              keys = {
                ["<C-y>"] = { "yazi_copy_relative_path", mode = { "n", "i" } },
                -- 👆🏻 add this and customize the keybinding to suit your needs
              },
            },
          },
        },
      },
    },
    {
      "mikavilpas/yazi.nvim",
      -- (more config keys here)
      ---@type YaziConfig
      opts = {
        integrations = {
          picker_add_copy_relative_path_action = "snacks.picker",
          -- 👆🏻 add this
        },
      },
    },
  }
  ```
