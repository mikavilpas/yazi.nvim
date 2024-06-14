# Setting up your development environment

## Install dependencies

- install luarocks, which is used to install dependencies for the tests:

  ```sh
  # for osx
  brew install luarocks
  ```

- install [nlua](https://github.com/mfussenegger/nlua), the neovim lua
  interpreter, which is used to run the tests.

- install [GNU Make](https://www.gnu.org/software/make/), which is used to run
  the development commands that are defined in the Makefile.

Next, install all the dependencies with the following command:

```sh
make
```

When successful, the output will greet you with a message similar to the
following:

```text
Welcome to yazi.nvim development! 🚀
Next, run one of these commands to get started:
  make test
    Run all tests
  make test-focus
    Run only the tests marked with #focus in the test name
  make lint
    Check the code for lint errors
  make format
    Reformat all code
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
  Configure it to use "stylua" using the instructions in its README file

## Running tests

### On the command line

```sh
# run all tests
make test
# run tests marked with #focus
make test-focus
```

Recommended: use a file watcher to run tests automatically when files change. I
like [watchexec 🦀](https://github.com/watchexec/watchexec), and I run it with
`watchexec make test`

### (optional) Install test integration plugins for Neovim

See the "Tools" section of
[nvim-best-practices](https://github.com/nvim-neorocks/nvim-best-practices/tree/main?tab=readme-ov-file#hammer_and_wrench-tools-3)
for some ideas.

## (optional) Install markdown related tooling

Markdown (`.md`) is used in the documentation. Various checks are performed on
all markdown files.

Install everything with `npm`:

- Install [Node Version Manager](https://github.com/nvm-sh/nvm), which is used
  to choose the correct node version.

```sh
nvm use
npm install
```

## Resources

More information about the setup:

- <https://github.com/nvim-neorocks/nvim-best-practices/tree/main?tab=readme-ov-file#test_tube-testing>
