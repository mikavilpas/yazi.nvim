# Installing yazi from source

> This document explains how to install the latest version of yazi from source.
> If you're looking for a way to install an unreleased version of yazi.nvim, see
> [the instructions for developers](./for-developers/developing.md).

Yazi is moving fast, and some new yazi.nvim features might be supported only for
the latest version of yazi.

If you need the latest version of yazi, you can install it from source. This is
useful if you want to try out the latest features or if you want to contribute
to the project.

> [!WARNING]
>
> yazi.nvim tracks a recent version of yazi, but it might not always be the very
> latest version. Most of the time, the latest yazi version is compatible with
> yazi.nvim, but there might be exceptions. If you run into issues, you can try
> installing the version used in testing. The version can be found in
> [test.yml](../.github/workflows/test.yml).

> [!NOTE]
>
> Keep in mind that installing from source might be more complex than installing
> from a release. That being said, many yazi.nvim users run the latest version
> of yazi from source without any issues.

1. Install [rustup](https://rustup.rs/), which installs the Rust toolchain. Yazi
   is written in rust, so you need this to compile and install it.
   - if you have another way of installing the Rust toolchain, you can skip this
     step.
2. Clone the [yazi repository](https://github.com/sxyazi/yazi/) with git and
   navigate to it.
3. Execute these commands to build+install yazi:

   ```sh
   # in the yazi repository:

   # Install `yazi`, the main application
   cargo install --path yazi-fm --locked

   # Install `ya`, the command line interface that's internally used by yazi.nvim
   cargo install --path yazi-cli --locked
   ```

4. In case there are any issues, you can try these steps:

- Check <https://yazi-rs.github.io/docs/installation/> and see if you have
  followed all steps correctly
- Yazi has a `yazi --debug` command that can help you debug issues specific to
  yazi
- In yazi.nvim, you can run `:checkhealth yazi` to see if everything works

5. If you still have issues, please open an issue:
   <https://github.com/mikavilpas/yazi.nvim/issues>
