# The yazi.nvim plugin manager

Yazi.nvim ships with _experimental plugin manager_ support for lazy.nvim. It
allows you to fully manage your yazi and neovim plugins from inside neovim.

## Getting started

In this example, we will install the yazi plugin
[DreamMaoMao/keyjump.yazi](https://github.com/DreamMaoMao/keyjump.yazi), which
adds a "jump-to-line" feature to yazi. We will also install a _flavor_ which
applies a color scheme to yazi.

In your yazi.nvim configuration, add a new lazy.nvim plugin specification for
`DreamMaoMao/keyjump.yazi`:

```lua
-- this file is: /Users/mikavilpas/.config/nvim/lua/plugins/my-file-manager.lua
---@type LazySpec
return {
  {
    "mikavilpas/yazi.nvim",
    dependencies = { "nvim-lua/plenary.nvim", },
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
    -- example: include a plugin
    "DreamMaoMao/keyjump.yazi",
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
}
```

Make sure to add the `lazy` and `build` keys to the plugin specification .

Next, run `:Lazy` in neovim to install the plugin and flavor.

Finally, make changes in your yazi configuration:

- add a keybinding to your `~/.config/yazi/keymap.toml` according to the
  [instructions](https://github.com/DreamMaoMao/keyjump.yazi?tab=readme-ov-file#usage)
  provided by the plugin author.
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

The benefits of using the yazi.nvim plugin manager are:

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

As the Yazi plugin system is currently in beta, the yazi.nvim plugin manager is
subject to change. Users seeking stability are encouraged to use the official
plugin manager.

## More technical details and examples

> [!NOTE]
>
> This section is for advanced users.

```lua
-- Example plugins:
---@type LazyPlugin[]
return {
  {
    -- a yazi plugin which like flash.nvim in neovim,allow use key char to Precise selection
    -- https://github.com/DreamMaoMao/keyjump.yazi
    "DreamMaoMao/keyjump.yazi",
    lazy = true,
    build = function(plugin)
      require("yazi.plugin").build_plugin(plugin)
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
