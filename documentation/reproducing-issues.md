# Reproducing issues

Since Neovim is very configurable and extensible, it's possible that some issues
are caused by plugins or configuration. This can also make it very difficult to
provide a fix. To help us diagnose the issue, please follow these steps:

1. copy [repro.lua](../repro.lua) to a directory on your system
2. run `nvim -u repro.lua` in that directory
   - this will start Neovim with a minimal configuration, completely defined by
     that one file.
3. try to reproduce the issue
   - if you can't reproduce the issue, make changes to the file to make it more
     similar to your configuration until you can reproduce it.
4. when reporting the issue, attach the contents of your `repro.lua` file to the
   issue report.
