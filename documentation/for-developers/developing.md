# Managing your development environment

## Install dependencies

- install luarocks, which is used to install dependencies for the tests:

  ```sh
  # for osx
  brew install luarocks
  ```

- install [nlua](https://github.com/mfussenegger/nlua), the neovim lua
  interpreter, which is used to run the tests.

- install [just](https://github.com/casey/just), which is used to run the
  development commands that are defined in the justfile.

Next, install all the dependencies with the following command:

```sh
just
```

When successful, the output will greet you with a message similar to the
following:

```text
Available recipes:
    build      # Build the project
    check      # Check the code for errors (lint + test + format)
    default
    format     # Reformat all code
    help
    lint       # Check the code for lint errors
    test       # Run all tests
    test-focus # Run only the tests marked with #focus somewhere in the test name
```

## Neovim development tools

Many of these are nicely available for [LazyVim](https://www.lazyvim.org/). Even
if you don't use LazyVim, you can still refer to how they are set up if you're
having trouble.

- <https://github.com/folke/neoconf.nvim> which sets your lua LSP to use the
  project settings
- <https://github.com/folke/lazydev.nvim> which allows fast LSP startup
- <https://github.com/folke/trouble.nvim> which shows errors and diagnostics
- <https://github.com/stevearc/conform.nvim> which formats your code on save.
  Configure it to use stylua and prettier using the instructions in its README
  file
- <https://www.lazyvim.org/extras/lang/typescript> or similar tooling for
  working with integration tests

## Running tests

This project has two types of tests

1. unit tests. These are run with
   [busted](https://github.com/lunarmodules/busted), a lua headless unit testing
   framework.
   - very fast to run
   - can make assertions about lua level results
   - more difficult to test high level features such as actual integration with
     yazi
2. integration tests. These are run with [cypress](https://www.cypress.io/), an
   interactive JavaScript browser testing framework.
   - very visual
   - slower to run but still very nice
   - can make assertions about the actual UI and integration with yazi
   - (optionally) can be run to drive the development of new features - this is
     explained in depth in the
     [philosophy of cypress](https://www.cypress.io/how-it-works)

### 1. Unit tests

![unit tests](https://github.com/mikavilpas/yazi.nvim/assets/300791/2cbc89e3-6933-4ccc-aadd-a92e42d78b37)

```sh
# run all tests
just test
# NOTE: if you get an error about "busted.runner" not being found, you may need
# to run the following command:
eval $(luarocks path --no-bin --lua-version 5.1)

# run only the tests marked with #focus in their name
just test-focus
```

Recommended: use a file watcher to run tests automatically when files change. I
like [watchexec 🦀](https://github.com/watchexec/watchexec), and I run it with
`watchexec just test`

Optionally, you can install test integration plugins for Neovim to start the
tests from within Neovim. See the "Tools" section of
[nvim-best-practices](https://github.com/nvim-neorocks/nvim-best-practices/tree/main?tab=readme-ov-file#hammer_and_wrench-tools-3)
for some ideas.

### 2. Integration tests

![integration tests](https://github.com/mikavilpas/yazi.nvim/assets/300791/817ccb3f-725b-4830-b5e0-d99a9b87ad26)

This project uses
[mikavilpas/tui-sandbox](https://github.com/mikavilpas/tui-sandbox) for running
integration tests. The setup shows Neovim running in a web based terminal and
allows simulating pressing keys and checking that the correct output is shown.
Because the real applications are being run in a real environment, almost all
features that Neovim and yazi support can be tested.

The tests are written in TypeScript using the [Cypress](https://www.cypress.io/)
browser testing framework.

Optional, but recommended: install
[Fast Node Manager](https://github.com/Schniz/fnm) to install the correct
version of node.

Run the following commands in the root of the project:

```sh
# activate the correct version of node
fnm use
# or fnm install <version> if you don't have the correct version installed

# install the dependencies
pnpm install # or `pnpm i`
```

Next, start the integration test environment inside the
[integration-tests](../../integration-tests/) directory:

```sh
pnpm dev
```

## Managing your development code

> As a developer using lazy.nvim, I want to make source code changes and try out
> unfinished ideas. I also want to be able to revert to a working setup at any
> time, because I need yazi.nvim for other activities as well.

You can use the following approach to have a nice split with unstable and stable
code:

1. (use lazy.nvim to install the plugin)
2. Create a fork of the project in Github. Put it in a separate directory such
   as `~/git/yazi.nvim/`
3. Specify the version you want to use in your plugin specification (see
   lazy.nvim [docs](https://github.com/folke/lazy.nvim)):

   ```lua
   -- this file is /Users/mikavilpas/.config/nvim/lua/plugins/my-file-manager.lua
   ---@type LazySpec
   return {
     {
       "mikavilpas/yazi.nvim",
       -- if you want to use a specific branch, tag, or commit, you can specify it too

       -- for development, load from local directory
       dir = "~/git/yazi.nvim/",
       -- (... Many more settings)
     }
   }
   ```

4. When you finish your development session, you can switch back to the stable
   version by commenting the `dir` setting from the plugin specification.

An example can be found
[here](https://github.com/mikavilpas/dotfiles/blob/75e070ce6ac45b7ed8ac4c818f77abadbdd4b152/.config/nvim/lua/plugins/my-file-manager.lua?plain=1#L9).

## Resources

More information about the setup:

- <https://github.com/nvim-neorocks/nvim-best-practices/tree/main?tab=readme-ov-file#test_tube-testing>
