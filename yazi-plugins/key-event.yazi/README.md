# key-event.yazi

Publish the cwd when yazi quits.

Needs this feature in yazi
https://github.com/sxyazi/yazi/commit/74bd98031e04b0455f83bed8b7970967a3ec9a1e
(requires nightly yazi as of 2025-07-30)

## Installation

With `ya pkg`:

```sh
ya pkg add mikavilpas/yazi.nvim:yazi-plugins/key-event
```

With yazi.nvim's [plugin management](../../documentation/plugin-management.md):

```lua
return {
  "mikavilpas/yazi.nvim",
  opts = {},
  build = function(plugin)
    require("yazi.plugin").build_plugin(plugin, {
      sub_dir = "yazi-plugins/key-event.yazi",
      name = "key-event.yazi",
    })
  end,
}
```

## Usage

Add this to your `~/.config/yazi/init.lua`:

```lua
require("key-event"):setup()
```

An end-to-end tested example can be found in
[integration-tests/test-environment/.config/yazi_with_plugins/init.lua](../../integration-tests/test-environment/.config/yazi_with_plugins/init.lua).

Once installed, you can use yazi.nvim to react to quit events. See the
[documentation](../../documentation/integrations-with-yazi-plugins.md) for more
information.

## License

This plugin is MIT-licensed. For more information check the [LICENSE](LICENSE)
file.
