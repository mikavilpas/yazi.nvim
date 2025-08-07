# Copying the relative path to files

## Usage with yazi

When yazi is open, you can copy the relative path from the current file to other
files or directories. By default it's mapped to `<c-y>` and requires GNU
`realpath` or `grealpath` on OSX.

## Customizing the path resolution

> Use case: I want to always resolve the path from Neovim's current working
> directory

You can customize the path resolution in your configuration:

```lua
-- Example: when using the `copy_relative_path_to_selected_files` key (default
-- <c-y>) in yazi, change the way the relative path is resolved.
require("yazi").setup({
  integrations = {
    resolve_relative_path_implementation = function(args, get_relative_path)
      -- By default, the path is resolved from the file/dir yazi was focused on
      -- when it was opened. Here, we change it to resolve the path from
      -- Neovim's current working directory (cwd) to the target_file.
      local cwd = vim.fn.getcwd()
      local path = get_relative_path({
        selected_file = args.selected_file,
        source_dir = cwd,
      })
      return path
    end,
  },
})
```

This allows for a couple of interesting things:

- fallback to the default implementation
- reuse the default implementation but change the source directory (e.g. to
  Neovim's current working directory)
- use a custom implementation, get creative! Some ideas just for fun:
  - Maybe it could convert the link to a GitHub url
  - If the current Neovim file is a markdown file, it could convert the link to
    a relative markdown link

This configuration is tested as part of the end-to-end test suite
[in this file](../integration-tests/test-environment/config-modifications/yazi_config/resolve_relative_files_from_cwd.lua).

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
