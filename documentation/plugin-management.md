# Yazi plugin management

Yazi.nvim ships with plugin management support when using lazy.nvim. It allows
you to fully manage your yazi and neovim plugins from inside neovim.

![lazy.nvim showing available updates for yazi.nvim and some yazi plugins](https://github.com/user-attachments/assets/20a922e5-541e-453e-a032-c5456f07fa13)

## Getting started

In this example, we will install the yazi plugin
[starship.yazi](https://github.com/Rolv-Apneseth/starship.yazi), which adds
support for the [starship](https://starship.rs/) shell prompt to yazi. We will
also install a _flavor_ which applies a color scheme to yazi.

In your yazi.nvim configuration, add a new lazy.nvim plugin specification for
`Rolv-Apneseth/starship.yazi`:

```lua
-- this file is: /Users/mikavilpas/.config/nvim/lua/plugins/my-file-manager.lua
---@type LazySpec
return {
  {
    "mikavilpas/yazi.nvim",
    keys = {
      {
        "<up>",
        function()
          require("yazi").yazi()
        end,
      },
    },
  },
  {
    "Rolv-Apneseth/starship.yazi",
    lazy = true,
    build = function(plugin)
      require("yazi.plugin").build_plugin(plugin)
    end,
  },
  {
    -- example: include a flavor
    "BennyOe/onedark.yazi",
    lazy = true,
    build = function(plugin)
      require("yazi.plugin").build_flavor(plugin)
    end,
  },
  {
    -- example: include a flavor from a subdirectory. There are lots of flavors
    -- available in https://github.com/yazi-rs/flavors
    "yazi-rs/flavors",
    name = "yazi-flavor-catppuccin-macchiato",
    lazy = true,
    build = function(spec)
      require("yazi.plugin").build_flavor(spec, {
        sub_dir = "catppuccin-macchiato.yazi",
      })
    end,
  },
}
```

Make sure to add the `lazy` and `build` keys to the plugin specification .

Next, run `:Lazy` in neovim to install the plugin and flavor.

Finally, make changes in your yazi configuration:

- (for plugins requiring keybindings) add a keybinding to your
  `~/.config/yazi/keymap.toml` according to the instructions provided by the
  plugin author.
- include the flavor in your `~/.config/yazi/theme.toml` according to the
  [instructions](https://github.com/BennyOe/onedark.yazi?tab=readme-ov-file#%EF%B8%8F-usage)
  provided by the flavor author.

You're all set! You can now use the new plugin and flavor in yazi, and update
them using lazy.nvim.

> Demo: installing a new Yazi plugin with lazy.nvim, and then using `<leader>l`
> to view its commits

<https://github.com/mikavilpas/yazi.nvim/assets/300791/e746ba3a-7606-428c-9e6b-a6cb05094930>

## How it works

The way it works is the following:

- in your `lazy.nvim` configuration, you add the plugins you want to install
  - in each plugin, you add a `build` function that calls
    `require("yazi.plugin").build_plugin(plugin)`. This will link the plugin so
    that Yazi can find it.
  - lazy.nvim will install the plugins into its own directory
- you run `:Lazy` in neovim to install the plugins like you normally do
- you manually add any plugin specific Yazi keybindings to your Yazi
  configuration

The benefits of using lazy.nvim as a plugin manager are:

- See all installed plugins in one place in the excellent lazy.nvim dashboard
- Preview incoming updates before installing them
- Lock the versions of your plugins in the lazy.nvim `lazy-lock.json` file
  - You can commit it to your dotfiles, and replicate your setup on another
    machine, as well as roll back in case there are errors
- Install plugins from any sources supported by lazy.nvim
- Lock versions of plugins to a specific commit, branch, or tag

## Caveats

> [!NOTE]
>
> Note that only [lazy.nvim](https://github.com/folke/lazy.nvim) is supported at
> the moment.

> [!NOTE]
>
> Yazi also ships with its own plugin manager. Some of the features are very
> similar. The intent is to provide a more integrated experience with the same
> (or, if possible, improved) features.

> [!NOTE]
>
> Right now, it's not known if it works on Windows. Please report any issues.

## More technical details and examples

> [!NOTE]
>
> This section is for advanced users.

```lua
-- Example plugins:
---@type LazyPlugin[]
return {
  {
    -- example: a yazi plugin monorepo which provides multiple plugins for
    -- yazi. To use it, you need to specify the sub_dir for the plugin you want
    -- to install.
    "redbeardymcgee/yazi-plugins",
    lazy = true,
    build = function(plugin)
      -- This is a plugin like flash.nvim in neovim - it allows you to jump to
      -- a line by typing the first few characters of the line.
      -- https://github.com/redbeardymcgee/yazi-plugins
      require("yazi.plugin").build_plugin(plugin, { sub_dir = "easyjump.yazi" })
    end,
  },
  {
    -- Starship prompt plugin for yazi
    -- https://github.com/Rolv-Apneseth/starship.yazi
    "Rolv-Apneseth/starship.yazi",
    lazy = true,
    build = function(plugin)
      -- NOTE: you can customize the yazi directory, by default it is
      -- `~/.config/yazi/`
      require("yazi.plugin").build_plugin(plugin, { yazi_dir = vim.fs.normalize("~/.config/yazi/") })
    end,
  },
  {
    -- An archive previewer plugin for Yazi, using ouch.
    -- https://github.com/ndtoan96/ouch.yazi
    "ndtoan96/ouch.yazi",
    lazy = true,
    build = function(plugin)
      require("yazi.plugin").build_plugin(plugin)
    end,
  },
}

-- NOTE: best practice: set `lazy = true` to make neovim not load these
-- plugins (only install them). They are only for Yazi.
```

## In case of errors

- see if you should customize the `yazi_dir` in the `build` function
- try running `:Lazy build <plugin-name>` to see if there are any errors visible
  in `:messages`

## Resources

For further reading, please refer to the following resources:

- Yazi plugin documentation <https://yazi-rs.github.io/docs/plugins/overview>
- lazy.nvim documentation <https://github.com/folke/lazy.nvim>
- General discussion on the idea
  <https://github.com/folke/lazy.nvim/discussions/1488>
