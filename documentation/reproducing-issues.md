# Reproducing issues

Since Neovim is very configurable and extensible, it's possible that some issues
are caused by plugins or configuration. This can also make it very difficult to
provide a fix. To help us diagnose the issue, please follow these steps:

1. Run the following to try to identify common issues:

   ```vim
   :checkhealth yazi
   ```

1. copy [repro.lua](../repro.lua) to a directory on your system
1. run `nvim -u repro.lua -c "lua require('lazy').update()"` in that directory
   - this will start Neovim with a minimal configuration, completely defined by
     that one file.
1. try to reproduce the issue
   - if you can't reproduce the issue, make changes to the file to make it more
     similar to your configuration until you can reproduce it.
1. when reporting the issue, attach the contents of your `repro.lua` file to the
   issue report.

## Logging

You can find out a lot of details about what is going on in yazi.nvim by reading
the log file.

### Enabling logging

To enable logging, you can do one of the following:

- set `log_level = vim.log.levels.DEBUG,` in your yazi configuration
- or, call yazi manually with logging on by running
  ```vim
  :lua require('yazi').yazi({log_level = vim.log.levels.DEBUG})
  ```

### Reading the log file

To open the log file, execute the following:

```vim
:Yazi logs
```

If inspecting a complicated issue, it's recommended to "tail" the log file to
see any new messages as soon as they arrive:

```sh
tail -F /path/to/logfile
```

If you want to get fancy, you can use the command line program
[bat's custom tailing](https://github.com/sharkdp/bat?tab=readme-ov-file#tail--f)
instructions to get colored output.
