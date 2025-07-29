# Integrations with Yazi Plugins

While yazi.nvim provides Neovim related integrations, some yazi functionality
can only be accessed through using yazi plugins along with yazi.nvim.

## `key-event.yazi`

Change Neovim's current working directory to the one yazi was in when it quit.

1. See
   [../yazi-plugins/key-event.yazi/README.md](../yazi-plugins/key-event.yazi/README.md)
   for instructions on how to install the `key-event.yazi` yazi plugin.
2. After installing the plugin, add the following to your yazi.nvim
   configuration:

   ```lua
   require("yazi").setup({
     integrations = {
       yazi_plugins = {
         key_event = true,
       },
     },
   })
   ```

3. Now, whenever yazi.nvim detects yazi quitting, it will change the current
   working directory to the one yazi was in when it quit. You can verify this
   with the `:pwd` command in Neovim.

## Resources

- <https://yazi-rs.github.io/docs/plugins/overview>
