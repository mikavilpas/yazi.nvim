# 🎲 A Neovim Plugin for [yazi](https://github.com/sxyazi/yazi.git)

> [!TIP]
>
> 2024-07: Some users are experiencing issues updating with lazy.nvim, and have
> reported uninstalling and reinstalling the plugin seems to work. More
> information can be found in
> [#198](https://github.com/mikavilpas/yazi.nvim/pull/198).

<a href="https://dotfyle.com/plugins/mikavilpas/yazi.nvim">
  <img src="https://dotfyle.com/plugins/mikavilpas/yazi.nvim/shield?style=flat-square" alt="shield image for plugin usage" /> </a>

[![LuaRocks](https://img.shields.io/luarocks/v/mikavilpas/yazi.nvim?logo=lua)](https://luarocks.org/modules/mikavilpas/yazi.nvim)
[![Type checked codebase](https://github.com/mikavilpas/yazi.nvim/actions/workflows/typecheck.yml/badge.svg)](https://github.com/mikavilpas/yazi.nvim/actions/workflows/typecheck.yml)

Yazi is a blazing fast file manager for the terminal. This plugin allows you to
open yazi in a floating window in Neovim.

<https://github.com/mikavilpas/yazi.nvim/assets/300791/c7ff98ee-54d6-4ad0-9318-903e4b674f84>

## ✨ Features

- Press `<f1>` to display all keymaps!
- Open yazi in a floating window. All visible splits are opened as yazi tabs for
  easy and fast navigation.
- Files that are hovered in yazi are highlighted in Neovim to intuitively show
  where you are in relation to your Neovim session. Currently this works for
  splits that you have open.
- Files selected in yazi can be opened in various ways: as the current buffer, a
  vertical split, a horizontal split, a new tab, as quickfix items...
- Integrations to other plugins and tools, if they are installed:

  - For [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim): you
    can grep/search in the directory yazi is in
  - For [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim): you can
    search and replace in the directory yazi is in
  - Copy the relative path from the start file to the currently hovered file.
    Requires
    [realpath (1)](https://www.man7.org/linux/man-pages/man1/realpath.1.html) on
    linux and windows, or
    [grealpath](https://formulae.brew.sh/formula/coreutils) on osx

- If multiple files are selected, they can be sent to the quickfix list
- (optionally) open yazi instead of netrw for directories
- Files that are renamed, moved, or deleted in yazi are kept in sync with open
  buffers in Neovim
  - The files are also kept in sync with currently running LSP servers
- Customizable keybindings
- 🆕 Plugin management for Yazi plugins and flavors
  ([documentation](./documentation/plugin-management.md))

For previewing images with yazi, see Yazi's documentation related to Neovim
[here](https://yazi-rs.github.io/docs/image-preview/#neovim).

## 📦 Installation

First, make sure you have the requirements:

- Neovim 0.10.x or later
- yazi [0.3.0](https://github.com/sxyazi/yazi/releases/tag/v0.3.0) or later
- New features might require a recent version of yazi (see
  [installing-yazi-from-source.md](documentation/installing-yazi-from-source.md))

> [!TIP]
>
> You can run `:checkhealth yazi` to see if compatible versions are installed
> and working.

## ⚙️ Configuration

### Using [lazy.nvim](https://lazy.folke.io/)

This is the preferred installation method.

```lua
---@type LazySpec
{
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      "<leader>-",
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      -- Open in the current working directory
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory" ,
    },
    {
      -- NOTE: this requires a version of yazi that includes
      -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
      '<c-up>',
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  ---@type YaziConfig
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
    keymaps = {
      show_help = '<f1>',
    },
  },
}
```

Notice that yazi.nvim adds some minimal dependencies for you automatically when
using a plugin manager like lazy.nvim. To see which dependencies are installed,
see [lazy.lua](./lazy.lua). If you are not using lazy.nvim (or
[rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim?tab=readme-ov-file)),
you need to install the dependencies yourself. Also see the discussion in
[issue 306](https://github.com/mikavilpas/yazi.nvim/issues/306) and examples of
[other Neovim plugins using this feature](https://github.com/search?q=path%3A%2F%5Elazy%5C.lua%24%2F&type=code).

### Without a package manager

<details>
<summary>Instructions</summary>

If you are not using lazy.nvim, see [lazy.lua](./lazy.lua) for what dependencies
are required.

```lua
-- (Obtain yazi.nvim and its dependencies using your preferred method first)
--
-- Next, map a key to open yazi.nvim
vim.keymap.set("n", "<leader>-", function()
  require("yazi").yazi()
end)
```

</details>

### ⚙️⚙️ Advanced configuration

> [!IMPORTANT]
>
> You don't have to set any of these options. The defaults are fine for most
> users.
>
> For advanced configuration, it's recommended to have your Lua language server
> set up so that you can type check your configuration and avoid errors.
>
> For help on how to do this, there is a section for Neovim development tools in
> the [documentation](./documentation/for-developers/developing.md).

You can optionally configure yazi.nvim by setting any of the options below.

https://github.com/mikavilpas/yazi.nvim/blob/a82ccb33ffe139415285946a5154907c3f1db1dd/lua/yazi/config.lua#L1-L299

## ⌨️ Keybindings

These are the default keybindings that are available when yazi is open:

- `<f1>`: show the help menu
- `<c-v>`: open the selected file(s) in vertical splits
- `<c-x>`: open the selected file(s) in horizontal splits
- `<c-t>`: open the selected file(s) in new tabs
- `<c-q>`: send the selected file(s) to the quickfix list
- There are also integrations to other plugins, which you need to install
  separately:
  - `<c-s>`: search in the current yazi directory using
    [telescope](https://github.com/nvim-telescope/telescope.nvim)'s `live_grep`,
    if available.
    - if multiple files/directories are selected in yazi, the search and replace
      will only be done in the selected files/directories
  - `<c-g>`: search and replace in the current yazi directory using
    [grug-far](https://github.com/MagicDuck/grug-far.nvim), if available
    - if multiple files/directories are selected in yazi, the operation is
      limited to those only
  - `<c-y>`: copy the relative path of the selected file(s) to the clipboard.
    Requires GNU `realpath` or `grealpath` on OSX
  - `<tab>`: make yazi jump to the open buffers in Neovim. See
    [#232](https://github.com/mikavilpas/yazi.nvim/pull/232) for more
    information

## 🪛 Customizing yazi

Yazi is highly customizable. It features its own plugin and event system,
themes, and keybindings. This section lists some of the plugins and themes that
I like.

- <https://gitee.com/DreamMaoMao/easyjump.yazi.git> allows jumping to a line by
  typing a hint character, much like
  [hop.nvim](https://github.com/smoka7/hop.nvim)
- <https://github.com/Rolv-Apneseth/starship.yazi> is a port of the
  [starship prompt](https://starship.rs) to yazi. It allows reusing the prompt
  you are using in your shell in yazi.
- <https://github.com/catppuccin/yazi> ports the catppuccin theme to yazi.
- <https://github.com/catppuccin/bat> can be used to change the syntax
  highlighting theme yazi uses to preview files. See
  [this discussion](https://github.com/sxyazi/yazi/discussions/818) or
  [my config](https://github.com/mikavilpas/dotfiles/commit/bb07515f69d219fd3435d222fcb2d80d27a25025#diff-973b37f40e024ca0f7e62f2569efce24ad550d0352adc8449168ac950af9eaf5R8)
  for an example of using it

## Contributing

Please see [COMMUNITY.md](./COMMUNITY.md) for more information on the project!

## In case there are issues

See [reproducing-issues.md](./documentation/reproducing-issues.md).
