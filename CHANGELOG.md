# Changelog

## [11.9.2](https://github.com/mikavilpas/yazi.nvim/compare/v11.9.1...v11.9.2) (2025-08-01)


### Bug Fixes

* enable new shell escaping feature by default ([#1104](https://github.com/mikavilpas/yazi.nvim/issues/1104)) ([fb4256c](https://github.com/mikavilpas/yazi.nvim/commit/fb4256c23e5746c292ee7dcff7c240115c161753))

## [11.9.1](https://github.com/mikavilpas/yazi.nvim/compare/v11.9.0...v11.9.1) (2025-08-01)


### Bug Fixes

* avoid using shell escaping for passing paths to yazi ([#1102](https://github.com/mikavilpas/yazi.nvim/issues/1102)) ([994a76d](https://github.com/mikavilpas/yazi.nvim/commit/994a76d28968606063aace8e9246c59c86272784))

## [11.9.0](https://github.com/mikavilpas/yazi.nvim/compare/v11.8.0...v11.9.0) (2025-08-01)


### Features

* allow customizing the way file paths are escaped ([#1099](https://github.com/mikavilpas/yazi.nvim/issues/1099)) ([a1448e1](https://github.com/mikavilpas/yazi.nvim/commit/a1448e16f4e27383cee2b6986cc1bb7bec413881))

## [11.8.0](https://github.com/mikavilpas/yazi.nvim/compare/v11.7.3...v11.8.0) (2025-08-01)


### Features

* **opt-in:** change Neovim's cwd when no files are selected in yazi ([bb70218](https://github.com/mikavilpas/yazi.nvim/commit/bb70218ad093f7924295f9c7a7d740d6c507e718))

## [11.7.3](https://github.com/mikavilpas/yazi.nvim/compare/v11.7.2...v11.7.3) (2025-08-01)


### Bug Fixes

* resolve the last directory using the `--cwd-file` option ([6611873](https://github.com/mikavilpas/yazi.nvim/commit/6611873f7aa4b15a2c1c451638ad1f8ada9d0c7d))

## [11.7.2](https://github.com/mikavilpas/yazi.nvim/compare/v11.7.1...v11.7.2) (2025-07-30)


### Bug Fixes

* only hijack netrw once on multiple yazi.setup() calls ([2c4880e](https://github.com/mikavilpas/yazi.nvim/commit/2c4880ecf1f79d508716269400d6ed8fe8205e85))

## [11.7.1](https://github.com/mikavilpas/yazi.nvim/compare/v11.7.0...v11.7.1) (2025-07-30)


### Bug Fixes

* only handle `cd` events for the current yazi instance ([2241764](https://github.com/mikavilpas/yazi.nvim/commit/2241764c47bf49878626787dc44afb95a8b53fed))

## [11.7.0](https://github.com/mikavilpas/yazi.nvim/compare/v11.6.4...v11.7.0) (2025-07-29)


### Features

* support installing plugins from deeply nested subdirectories ([#1078](https://github.com/mikavilpas/yazi.nvim/issues/1078)) ([52705bc](https://github.com/mikavilpas/yazi.nvim/commit/52705bcab62094c1c5d89ad72226b51f95dc9fba))

## [11.6.4](https://github.com/mikavilpas/yazi.nvim/compare/v11.6.3...v11.6.4) (2025-07-29)


### Bug Fixes

* remove snaks dependency from yazi.nvim rockspec ([5c6869f](https://github.com/mikavilpas/yazi.nvim/commit/5c6869fd77951ae9d6b1b6d87b422faaae03bf59))

## [11.6.3](https://github.com/mikavilpas/yazi.nvim/compare/v11.6.2...v11.6.3) (2025-07-28)


### Bug Fixes

* internal retry logic didn't log results on failure ([52b413b](https://github.com/mikavilpas/yazi.nvim/commit/52b413b2993061d75ff3b92f26f563d44d9c6abc))


### Performance Improvements

* fix `Yazi toggle` always failing the first try ([f594ead](https://github.com/mikavilpas/yazi.nvim/commit/f594ead1faad9ad9180670aafa2332c039151ac1))

## [11.6.2](https://github.com/mikavilpas/yazi.nvim/compare/v11.6.1...v11.6.2) (2025-07-28)


### Bug Fixes

* bulk renaming closing yazi in nvim `0.11.3` ([1968f71](https://github.com/mikavilpas/yazi.nvim/commit/1968f71ed8097942e9b15d22b6c132ffc576ef41))

## [11.6.1](https://github.com/mikavilpas/yazi.nvim/compare/v11.6.0...v11.6.1) (2025-07-22)


### Bug Fixes

* **logs:** clearly log when `emit_to_yazi` succeeds ([17d6822](https://github.com/mikavilpas/yazi.nvim/commit/17d6822f0bc15fb91e29112d42e3c93e59d19104))

## [11.6.0](https://github.com/mikavilpas/yazi.nvim/compare/v11.5.3...v11.6.0) (2025-06-29)


### Features

* can set the zindex of the yazi floating window ([#1016](https://github.com/mikavilpas/yazi.nvim/issues/1016)) ([635ff65](https://github.com/mikavilpas/yazi.nvim/commit/635ff65cdf33da03a109146ccc38fae367b68d8c))

## [11.5.3](https://github.com/mikavilpas/yazi.nvim/compare/v11.5.2...v11.5.3) (2025-06-14)


### Bug Fixes

* snacks picker grep not showing the title ([6f4b36c](https://github.com/mikavilpas/yazi.nvim/commit/6f4b36c5d49cd4a141f632cf548145e0ad759050))

## [11.5.2](https://github.com/mikavilpas/yazi.nvim/compare/v11.5.1...v11.5.2) (2025-06-12)


### Bug Fixes

* **ui:** correctly center floating window when cmdheight=0 ([c363b1a](https://github.com/mikavilpas/yazi.nvim/commit/c363b1a9e51d273a494d30a7f7230e78017cb9a8))

## [11.5.1](https://github.com/mikavilpas/yazi.nvim/compare/v11.5.0...v11.5.1) (2025-05-22)


### Bug Fixes

* crash when pressing tab if visible-buffer is nil ([#973](https://github.com/mikavilpas/yazi.nvim/issues/973)) ([b0d0985](https://github.com/mikavilpas/yazi.nvim/commit/b0d0985c4d2035cc6f796b81cf282abb1b0a8451))

## [11.5.0](https://github.com/mikavilpas/yazi.nvim/compare/v11.4.0...v11.5.0) (2025-05-18)


### Features

* **log:** add `:Yazi logs` command to open the log file ([a9e454e](https://github.com/mikavilpas/yazi.nvim/commit/a9e454e2219b6c2953d248b74ed24f0de5837c6e))

## [11.4.0](https://github.com/mikavilpas/yazi.nvim/compare/v11.3.0...v11.4.0) (2025-05-14)


### Features

* add option for nvim yazi to use a custom config file  ([#957](https://github.com/mikavilpas/yazi.nvim/issues/957)) ([fc77617](https://github.com/mikavilpas/yazi.nvim/commit/fc77617ae40a360dad5bb253300d96aa5013ba11))

## [11.3.0](https://github.com/mikavilpas/yazi.nvim/compare/v11.2.0...v11.3.0) (2025-05-11)


### Features

* **opt-out:** `open_and_pick_window` (`<c-o>`) using snacks.nvim ([#952](https://github.com/mikavilpas/yazi.nvim/issues/952)) ([9a6d334](https://github.com/mikavilpas/yazi.nvim/commit/9a6d334689f4b10047acba79177616661ab1773d))

## [11.2.0](https://github.com/mikavilpas/yazi.nvim/compare/v11.1.0...v11.2.0) (2025-05-09)


### Features

* allow emitting arbitrary yazi commands after yazi is ready ([#946](https://github.com/mikavilpas/yazi.nvim/issues/946)) ([c9a8c7b](https://github.com/mikavilpas/yazi.nvim/commit/c9a8c7be76356e93aad8949710a4c82f675ee114))

## [11.1.0](https://github.com/mikavilpas/yazi.nvim/compare/v11.0.3...v11.1.0) (2025-05-05)


### Features

* **snacks:** add copy relative path action to snacks.nvim picker ([#938](https://github.com/mikavilpas/yazi.nvim/issues/938)) ([07fcb3b](https://github.com/mikavilpas/yazi.nvim/commit/07fcb3b28992b58f8b51a115e35fa00ddc40bc43))

## [11.0.3](https://github.com/mikavilpas/yazi.nvim/compare/v11.0.2...v11.0.3) (2025-05-03)


### Bug Fixes

* cycling buffers with `<tab>` works with only one buffer open ([#931](https://github.com/mikavilpas/yazi.nvim/issues/931)) ([4338c9e](https://github.com/mikavilpas/yazi.nvim/commit/4338c9ed1be56228b05afe143d270f4b11c3b365))

## [11.0.2](https://github.com/mikavilpas/yazi.nvim/compare/v11.0.1...v11.0.2) (2025-05-02)


### Bug Fixes

* do not crash cycle buffers if only one is visible ([9be42be](https://github.com/mikavilpas/yazi.nvim/commit/9be42be7bd29b21bbb07a4ca1df3ade912766699))

## [11.0.1](https://github.com/mikavilpas/yazi.nvim/compare/v11.0.0...v11.0.1) (2025-05-02)


### Bug Fixes

* not being able to cycle buffers with `tab` after `:Yazi cwd` ([#922](https://github.com/mikavilpas/yazi.nvim/issues/922)) ([9b242be](https://github.com/mikavilpas/yazi.nvim/commit/9b242bef20df648b5d08ebfb4e62e227bc059623))

## [11.0.0](https://github.com/mikavilpas/yazi.nvim/compare/v10.3.0...v11.0.0) (2025-04-29)


### ⚠ BREAKING CHANGES

* remove nvim-0.10 termopen fallback completely

### Code Refactoring

* remove nvim-0.10 termopen fallback completely ([97039da](https://github.com/mikavilpas/yazi.nvim/commit/97039da8fd75fceeaf3f62c7bd969f296abb9b76))

## [10.3.0](https://github.com/mikavilpas/yazi.nvim/compare/v10.2.0...v10.3.0) (2025-04-28)


### Features

* allow overriding the buffer deletion implementation ([#909](https://github.com/mikavilpas/yazi.nvim/issues/909)) ([c82087d](https://github.com/mikavilpas/yazi.nvim/commit/c82087dfddce9c8622a2c40fb53d241c0e814c7e))

## [10.2.0](https://github.com/mikavilpas/yazi.nvim/compare/v10.1.1...v10.2.0) (2025-04-28)


### Features

* **api:** allow accessing the yazi context from the lua API ([f2e480d](https://github.com/mikavilpas/yazi.nvim/commit/f2e480d35573f164870bada19343a0ef5d7d01ad))


### Bug Fixes

* make toggling yazi more reliable ([5ab0c65](https://github.com/mikavilpas/yazi.nvim/commit/5ab0c65b6b7d21ce7f75f470c6e9a4ec9ea9cb24))

## [10.1.1](https://github.com/mikavilpas/yazi.nvim/compare/v10.1.0...v10.1.1) (2025-04-27)


### Bug Fixes

* don't hijack when using a protocol netrw should handle ([#906](https://github.com/mikavilpas/yazi.nvim/issues/906)) ([caa08ae](https://github.com/mikavilpas/yazi.nvim/commit/caa08ae4d568aca447fd1b06b7a4d7ed1f1cc1f4))

## [10.1.0](https://github.com/mikavilpas/yazi.nvim/compare/v10.0.2...v10.1.0) (2025-04-20)


### Features

* allow a yazi keymap to cycle through open buffers ([#894](https://github.com/mikavilpas/yazi.nvim/issues/894)) ([7656e82](https://github.com/mikavilpas/yazi.nvim/commit/7656e826faf1aadaa366bd9fbf1dad42310c210f))

## [10.0.2](https://github.com/mikavilpas/yazi.nvim/compare/v10.0.1...v10.0.2) (2025-04-12)


### Bug Fixes

* sending `i` on startup activating yazi actions ([c84f569](https://github.com/mikavilpas/yazi.nvim/commit/c84f569b38cae85018a41181e4a086c4a143d604))

## [10.0.1](https://github.com/mikavilpas/yazi.nvim/compare/v10.0.0...v10.0.1) (2025-03-29)


### Bug Fixes

* quickfix items not being processable with `:cfdo 1t1` ([#858](https://github.com/mikavilpas/yazi.nvim/issues/858)) ([b5596b9](https://github.com/mikavilpas/yazi.nvim/commit/b5596b981df9cdb219ece29eea60cd52f149c319))

## [10.0.0](https://github.com/mikavilpas/yazi.nvim/compare/v9.2.1...v10.0.0) (2025-03-24)


### ⚠ BREAKING CHANGES

* If you're using an old nightly Neovim version (older than 2 months) and cannot open yazi.nvim after this, you should update your nightly Neovim. If that is not possible, you can set `future_features.use_nvim_0_10_termopen=true` in your config to work around the issue. I will keep that around for a while, but eventually it might be removed.

### Code Refactoring

* remove 0.11 nightly termopen fallback logic ([1a15ad7](https://github.com/mikavilpas/yazi.nvim/commit/1a15ad738100e5e5c7b2b82ea9ee0a9c451388a9))

## [9.2.1](https://github.com/mikavilpas/yazi.nvim/compare/v9.2.0...v9.2.1) (2025-03-24)


### Bug Fixes

* don't restore the previous buffer when yazi is closed ([173d40f](https://github.com/mikavilpas/yazi.nvim/commit/173d40fa4161321bb82faef9d6945f90eb96db6f))

## [9.2.0](https://github.com/mikavilpas/yazi.nvim/compare/v9.1.0...v9.2.0) (2025-03-19)


### Features

* support `winborder` setting on Neovim nightly (0.11+) ([ccf6d32](https://github.com/mikavilpas/yazi.nvim/commit/ccf6d3247392075e8d2617086d351db3fddc6f1b))

## [9.1.0](https://github.com/mikavilpas/yazi.nvim/compare/v9.0.3...v9.1.0) (2025-03-14)


### Features

* open yazi tabs for the files in the quickfix list ([9d3754b](https://github.com/mikavilpas/yazi.nvim/commit/9d3754b56f4812a677d7b45a6f74d8e700483ad9))

## [9.0.3](https://github.com/mikavilpas/yazi.nvim/compare/v9.0.2...v9.0.3) (2025-03-14)


### Bug Fixes

* publishing move events to other nvim plugins ([e3fab1d](https://github.com/mikavilpas/yazi.nvim/commit/e3fab1df699e093134fa2790eb8d8d366078223a))

## [9.0.2](https://github.com/mikavilpas/yazi.nvim/compare/v9.0.1...v9.0.2) (2025-03-02)


### Bug Fixes

* clarify error message when yazi or ya is not on PATH ([27e13aa](https://github.com/mikavilpas/yazi.nvim/commit/27e13aab5d1c3cb874112ff629f22db2a799e14e))

## [9.0.1](https://github.com/mikavilpas/yazi.nvim/compare/v9.0.0...v9.0.1) (2025-02-27)


### Bug Fixes

* **health:** checkhealth fails if `config.keymaps = false` ([9909c81](https://github.com/mikavilpas/yazi.nvim/commit/9909c811c0502e50baf6faac8991495c139839eb))

## [9.0.0](https://github.com/mikavilpas/yazi.nvim/compare/v8.0.1...v9.0.0) (2025-02-25)


### ⚠ BREAKING CHANGES

* to migrate, you may need to add snacks.nvim as a dependency manually if your neovim does not already have it from another source. You can copy it from the instructions in the readme file.

### Code Refactoring

* don't install snacks.nvim automatically ([58169cd](https://github.com/mikavilpas/yazi.nvim/commit/58169cdd36333de3c7ecb7aeac71e6339254b791))

## [8.0.1](https://github.com/mikavilpas/yazi.nvim/compare/v8.0.0...v8.0.1) (2025-02-23)


### Bug Fixes

* **health:** add warning if snacks library is not found ([f5786b8](https://github.com/mikavilpas/yazi.nvim/commit/f5786b86990b9b3211998ba9add0663a0ebdda51))
* prettier complains ([e12ddff](https://github.com/mikavilpas/yazi.nvim/commit/e12ddffab524f2fee9f0c93a7f1cff2818a77799))

## [8.0.0](https://github.com/mikavilpas/yazi.nvim/compare/v7.5.4...v8.0.0) (2025-02-21)


### ⚠ BREAKING CHANGES

* This change now requires https://github.com/folke/snacks.nvim to be installed. Users of [lazy.nvim](https://lazy.folke.io/) and [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim) should have this dependency automatically installed.

### Features

* process yazi events live by default (requires snacks.nvim) ([#769](https://github.com/mikavilpas/yazi.nvim/issues/769)) ([c59c654](https://github.com/mikavilpas/yazi.nvim/commit/c59c65404facd34614ca5cf6c8b380608a84ee23))

## [7.5.4](https://github.com/mikavilpas/yazi.nvim/compare/v7.5.3...v7.5.4) (2025-02-12)


### Bug Fixes

* not being able live delete buffers without snacks.bufdelete ([3372a44](https://github.com/mikavilpas/yazi.nvim/commit/3372a447d89c934972681bf01c81f49f600bde9b))

## [7.5.3](https://github.com/mikavilpas/yazi.nvim/compare/v7.5.2...v7.5.3) (2025-02-10)


### Bug Fixes

* snacks.picker not being in insert mode when opened ([#749](https://github.com/mikavilpas/yazi.nvim/issues/749)) ([d645982](https://github.com/mikavilpas/yazi.nvim/commit/d645982e6f254ed62ba816299a491813e386e48b))

## [7.5.2](https://github.com/mikavilpas/yazi.nvim/compare/v7.5.1...v7.5.2) (2025-02-02)


### Bug Fixes

* `:Yazi toggle` not being able to hover a directory ([6fa08cf](https://github.com/mikavilpas/yazi.nvim/commit/6fa08cfc1037ae0529aac34261f3a4aba4bde7eb))

## [7.5.1](https://github.com/mikavilpas/yazi.nvim/compare/v7.5.0...v7.5.1) (2025-01-26)


### Bug Fixes

* renaming a file to its old name closed the buffer ([#722](https://github.com/mikavilpas/yazi.nvim/issues/722)) ([baeb1fa](https://github.com/mikavilpas/yazi.nvim/commit/baeb1faea912a8483a3876f8494ca8323ba23ddd))

## [7.5.0](https://github.com/mikavilpas/yazi.nvim/compare/v7.4.1...v7.5.0) (2025-01-25)


### Features

* allow processing all yazi events as soon as possible ([#718](https://github.com/mikavilpas/yazi.nvim/issues/718)) ([ac9fed8](https://github.com/mikavilpas/yazi.nvim/commit/ac9fed8c1666c99b2db5b3009e074375c0c52c44))

## [7.4.1](https://github.com/mikavilpas/yazi.nvim/compare/v7.4.0...v7.4.1) (2025-01-25)


### Bug Fixes

* opening files from visual mode did not work for relative paths ([#714](https://github.com/mikavilpas/yazi.nvim/issues/714)) ([14b5642](https://github.com/mikavilpas/yazi.nvim/commit/14b5642fe43a127878a2de343ca640989f1d7482))

## [7.4.0](https://github.com/mikavilpas/yazi.nvim/compare/v7.3.0...v7.4.0) (2025-01-24)


### Features

* Add hl YaziFloatBorder to customize border highlight ([#709](https://github.com/mikavilpas/yazi.nvim/issues/709)) ([27d6250](https://github.com/mikavilpas/yazi.nvim/commit/27d62509a98d8a0d7fb9b5a33d483d7d08f0d3ee))

## [7.3.0](https://github.com/mikavilpas/yazi.nvim/compare/v7.2.1...v7.3.0) (2025-01-24)


### Features

* add integration with snacks picker ([#704](https://github.com/mikavilpas/yazi.nvim/issues/704)) ([dfeba28](https://github.com/mikavilpas/yazi.nvim/commit/dfeba2890942004ba875123366c248bdbafbf1a3))

## [7.2.1](https://github.com/mikavilpas/yazi.nvim/compare/v7.2.0...v7.2.1) (2025-01-23)


### version

* 7.2.1 ([4f67b94](https://github.com/mikavilpas/yazi.nvim/commit/4f67b94f1c99eed31c382c6e8a1f8474323086bf))


### Bug Fixes

* pick correct jobstart method by default ([1ca7aed](https://github.com/mikavilpas/yazi.nvim/commit/1ca7aedc26547f2adfe49177263d48891b1635f7))

## [7.2.0](https://github.com/mikavilpas/yazi.nvim/compare/v7.1.1...v7.2.0) (2025-01-21)


### Features

* **health:** display the current neovim version in the healthcheck ([e188eaa](https://github.com/mikavilpas/yazi.nvim/commit/e188eaafa095509592124baeedbf8ade2c44495a))


### Bug Fixes

* `:Yazi` visual selection not recognizing directories, only files ([#693](https://github.com/mikavilpas/yazi.nvim/issues/693)) ([584cdda](https://github.com/mikavilpas/yazi.nvim/commit/584cdda3ce14b9c6c1cf8ba4fede03e8058886ab))

## [7.1.1](https://github.com/mikavilpas/yazi.nvim/compare/v7.1.0...v7.1.1) (2025-01-18)


### Bug Fixes

* **health:** verify resolver is set ([#683](https://github.com/mikavilpas/yazi.nvim/issues/683)) ([1674c9d](https://github.com/mikavilpas/yazi.nvim/commit/1674c9dcfd4eca1e02a2384ccb657eceef203c44))

## [7.1.0](https://github.com/mikavilpas/yazi.nvim/compare/v7.0.0...v7.1.0) (2025-01-16)


### Features

* open yazi, hovering the visual selection file path ([15f21e1](https://github.com/mikavilpas/yazi.nvim/commit/15f21e19cda6094fd9df352aadf2dcee75c8ffa1))

## [7.0.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.11.1...v7.0.0) (2025-01-10)


### ⚠ BREAKING CHANGES

* require yazi 0.4.0 or later from 2024-12-08

### Features

* require yazi 0.4.0 or later from 2024-12-08 ([5a78d8b](https://github.com/mikavilpas/yazi.nvim/commit/5a78d8b6208691e9b8651c3f441027c7783be20a))

## [6.11.1](https://github.com/mikavilpas/yazi.nvim/compare/v6.11.0...v6.11.1) (2025-01-06)


### Bug Fixes

* preserve line numbers when switching buffers in a new tab ([#653](https://github.com/mikavilpas/yazi.nvim/issues/653)) ([b023f1d](https://github.com/mikavilpas/yazi.nvim/commit/b023f1dfcb09e1319b5869452f17f5cc2fb3809f))

## [6.11.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.10.0...v6.11.0) (2024-12-22)


### Features

* add title to notify messages ([51c0d14](https://github.com/mikavilpas/yazi.nvim/commit/51c0d1453b8991f96caa5714b13db8f6a8651dba))

## [6.10.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.9.0...v6.10.0) (2024-12-15)


### Features

* add fzf-lua integration for grepping in files and dirs ([56b80f3](https://github.com/mikavilpas/yazi.nvim/commit/56b80f3e7cf6f4559fa2898cb33844eb10f0d97d))

## [6.9.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.8.0...v6.9.0) (2024-12-12)


### Features

* prevent conflicts with custom yazi config for `&lt;enter&gt;` (opt-in) ([e64d309](https://github.com/mikavilpas/yazi.nvim/commit/e64d3093895c68ec6f62b8a98c12d3f76d802e03))

## [6.8.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.7.0...v6.8.0) (2024-12-08)


### Features

* can use `ya emit` for more accurate &lt;tab&gt; to file (opt-in) ([#604](https://github.com/mikavilpas/yazi.nvim/issues/604)) ([b81e03c](https://github.com/mikavilpas/yazi.nvim/commit/b81e03c64bc1635acb15f536948b243ae975c960))

## [6.7.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.6.1...v6.7.0) (2024-12-07)


### Features

* using folke/snacks.nvim can preserve window layouts on deletes ([5c0f9b2](https://github.com/mikavilpas/yazi.nvim/commit/5c0f9b24ba0b87b8e2a79a685ac4a95577961fff))

## [6.6.1](https://github.com/mikavilpas/yazi.nvim/compare/v6.6.0...v6.6.1) (2024-12-02)


### Bug Fixes

* "invalid buffer id x" error when renaming a buffer ([6884a0f](https://github.com/mikavilpas/yazi.nvim/commit/6884a0feedecc6e1e274860893a2827d88740c6a))


### Performance Improvements

* **tests:** use `cy.runExCommand` in all tests ([97093b1](https://github.com/mikavilpas/yazi.nvim/commit/97093b16f3c9d027706bb97c4b65117e78d846d9))

## [6.6.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.5.1...v6.6.0) (2024-11-16)


### Features

* support reacting to custom yazi DDS events ([882c200](https://github.com/mikavilpas/yazi.nvim/commit/882c200d3abc0f4c950d149e014096efe59c46ae))

## [6.5.1](https://github.com/mikavilpas/yazi.nvim/compare/v6.5.0...v6.5.1) (2024-11-13)


### Bug Fixes

* avoid "E13: File exists" error after renaming a file ([#560](https://github.com/mikavilpas/yazi.nvim/issues/560)) ([58f1227](https://github.com/mikavilpas/yazi.nvim/commit/58f1227a82a656510e99202822ba8c67e2119e6e))

## [6.5.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.4.3...v6.5.0) (2024-11-04)


### Features

* allow using nvim's cwd in yazi keybindings ([#548](https://github.com/mikavilpas/yazi.nvim/issues/548)) ([f7ae54b](https://github.com/mikavilpas/yazi.nvim/commit/f7ae54bbe2346b28d0889140440272668708f33e))

## [6.4.3](https://github.com/mikavilpas/yazi.nvim/compare/v6.4.2...v6.4.3) (2024-10-17)


### Bug Fixes

* not being able to resolve the last_directory ([#523](https://github.com/mikavilpas/yazi.nvim/issues/523)) ([6c24b52](https://github.com/mikavilpas/yazi.nvim/commit/6c24b52074db2c7db55a92ff5ce845924b4d0a50))

## [6.4.2](https://github.com/mikavilpas/yazi.nvim/compare/v6.4.1...v6.4.2) (2024-10-16)


### Bug Fixes

* report parent directory of input_path as last_directory ([#519](https://github.com/mikavilpas/yazi.nvim/issues/519)) ([9ff955a](https://github.com/mikavilpas/yazi.nvim/commit/9ff955af4bd0a92b9c5dc76d24e7d24ec0d1748f))

## [6.4.1](https://github.com/mikavilpas/yazi.nvim/compare/v6.4.0...v6.4.1) (2024-10-05)


### Bug Fixes

* YaziRenamedOrMoved events could not be published in practice ([#499](https://github.com/mikavilpas/yazi.nvim/issues/499)) ([e379516](https://github.com/mikavilpas/yazi.nvim/commit/e37951699881885f1cfee5f3d794ad10da0a95dd))

## [6.4.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.3.1...v6.4.0) (2024-10-04)


### Features

* emit YaziRenamedOrMoved event when files are renamed or moved ([#495](https://github.com/mikavilpas/yazi.nvim/issues/495)) ([c4befd1](https://github.com/mikavilpas/yazi.nvim/commit/c4befd124f81741de987633e2ea08df0f996031f))

## [6.3.1](https://github.com/mikavilpas/yazi.nvim/compare/v6.3.0...v6.3.1) (2024-10-02)


### Bug Fixes

* use input dir if needed when changing cwd ([#487](https://github.com/mikavilpas/yazi.nvim/issues/487)) ([33857bf](https://github.com/mikavilpas/yazi.nvim/commit/33857bf7a32bdfff1a5236b80905e4c4f5ba4bd7))

## [6.3.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.2.0...v6.3.0) (2024-09-22)


### Features

* add keymap for changing cwd to current directory ([#474](https://github.com/mikavilpas/yazi.nvim/issues/474)) ([d63165d](https://github.com/mikavilpas/yazi.nvim/commit/d63165d5e122f27f985591bd4803c0222383f770))
* expose the current working directory to keybindings ([#471](https://github.com/mikavilpas/yazi.nvim/issues/471)) ([445f487](https://github.com/mikavilpas/yazi.nvim/commit/445f4877d8b80f9d24ea1f9b890c878211878d63))

## [6.2.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.1.0...v6.2.0) (2024-09-16)


### Features

* allow scaling the floating window width and height separately ([56912be](https://github.com/mikavilpas/yazi.nvim/commit/56912beffcdd6950e39f6e8782ffdf15fbc13d15))

## [6.1.0](https://github.com/mikavilpas/yazi.nvim/compare/v6.0.7...v6.1.0) (2024-09-11)


### Features

* allow cycle_open_buffers (`tab`) to work for a single file ([#451](https://github.com/mikavilpas/yazi.nvim/issues/451)) ([2d80e92](https://github.com/mikavilpas/yazi.nvim/commit/2d80e926e352841c411ef5c72eafd64d4c0b4763))

## [6.0.7](https://github.com/mikavilpas/yazi.nvim/compare/v6.0.6...v6.0.7) (2024-09-08)


### Bug Fixes

* opening a LazyVim session with folke/persistence.nvim starting yazi ([#442](https://github.com/mikavilpas/yazi.nvim/issues/442)) ([b8f4cc7](https://github.com/mikavilpas/yazi.nvim/commit/b8f4cc7fe365a4c16826efd5e07a9ca13fc6c11e))

## [6.0.6](https://github.com/mikavilpas/yazi.nvim/compare/v6.0.5...v6.0.6) (2024-09-07)


### Bug Fixes

* `nvim .` sent extra `i` key to yazi ([8253e11](https://github.com/mikavilpas/yazi.nvim/commit/8253e11e23b94c15f7c55d1c040f8847a86ecaeb))

## [6.0.5](https://github.com/mikavilpas/yazi.nvim/compare/v6.0.4...v6.0.5) (2024-09-01)


### Bug Fixes

* opening directories in splits and tabs opening empty buffers ([#421](https://github.com/mikavilpas/yazi.nvim/issues/421)) ([88cb633](https://github.com/mikavilpas/yazi.nvim/commit/88cb633d31b17c8f2fffbe47796f1bc13c489ac0))

## [6.0.4](https://github.com/mikavilpas/yazi.nvim/compare/v6.0.3...v6.0.4) (2024-08-22)


### Bug Fixes

* closing split when opening directory ([#403](https://github.com/mikavilpas/yazi.nvim/issues/403)) ([80e8dc4](https://github.com/mikavilpas/yazi.nvim/commit/80e8dc45c050b85f1cf09be7a3377964615c0be3))

## [6.0.3](https://github.com/mikavilpas/yazi.nvim/compare/v6.0.2...v6.0.3) (2024-08-21)


### Bug Fixes

* not being able to delete a buffer when it is modified ([#399](https://github.com/mikavilpas/yazi.nvim/issues/399)) ([8b0ecd8](https://github.com/mikavilpas/yazi.nvim/commit/8b0ecd8a6e0abe1af6bddf368cf6e10196443b24))

## [6.0.2](https://github.com/mikavilpas/yazi.nvim/compare/v6.0.1...v6.0.2) (2024-08-18)


### Bug Fixes

* showing error message when background color is not found ([#393](https://github.com/mikavilpas/yazi.nvim/issues/393)) ([b2c0bf3](https://github.com/mikavilpas/yazi.nvim/commit/b2c0bf3144290bb35240aac8ffa1350dda827b9b))

## [6.0.1](https://github.com/mikavilpas/yazi.nvim/compare/v6.0.0...v6.0.1) (2024-08-18)


### Bug Fixes

* starting telescope or grug-far when hovering a directory ([#388](https://github.com/mikavilpas/yazi.nvim/issues/388)) ([d6da015](https://github.com/mikavilpas/yazi.nvim/commit/d6da015cd2a6aee19ed798495318e227d8a720c0))

## [6.0.0](https://github.com/mikavilpas/yazi.nvim/compare/v5.7.1...v6.0.0) (2024-08-17)


### ⚠ BREAKING CHANGES

* yazi 0.3 is now required. Currently the version of yazi is 0.3.1 https://yazi-rs.github.io/docs/installation/

### Features

* enable yazi 0.3 features by default ([#386](https://github.com/mikavilpas/yazi.nvim/issues/386)) ([7ecfdd7](https://github.com/mikavilpas/yazi.nvim/commit/7ecfdd76a4016a0ccf7f9d1987b5c30661829519))

## [5.7.1](https://github.com/mikavilpas/yazi.nvim/compare/v5.7.0...v5.7.1) (2024-08-15)


### Bug Fixes

* leaving an empty buffer when opening a directory with `:edit .` ([#379](https://github.com/mikavilpas/yazi.nvim/issues/379)) ([ebe93e5](https://github.com/mikavilpas/yazi.nvim/commit/ebe93e5136091d7de001432089a3c8d9a6c52548))

## [5.7.0](https://github.com/mikavilpas/yazi.nvim/compare/v5.6.0...v5.7.0) (2024-08-15)


### Features

* allow using :Yazi commands automatically by default ([#377](https://github.com/mikavilpas/yazi.nvim/issues/377)) ([9a07ed5](https://github.com/mikavilpas/yazi.nvim/commit/9a07ed5dedabfe6f93f25eadb3d05cf1d5ca41ea))

## [5.6.0](https://github.com/mikavilpas/yazi.nvim/compare/v5.5.1...v5.6.0) (2024-08-13)


### Features

* **health:** show a command for double checking the configuration ([#374](https://github.com/mikavilpas/yazi.nvim/issues/374)) ([d66dbef](https://github.com/mikavilpas/yazi.nvim/commit/d66dbef2303e75ead47384171a51af5726b8947c))

## [5.5.1](https://github.com/mikavilpas/yazi.nvim/compare/v5.5.0...v5.5.1) (2024-08-12)


### Bug Fixes

* don't open duplicate tabs when opening files ([#367](https://github.com/mikavilpas/yazi.nvim/issues/367)) ([1c1ac86](https://github.com/mikavilpas/yazi.nvim/commit/1c1ac86293bb2429b0f69280abfcba165847bbbc))

## [5.5.0](https://github.com/mikavilpas/yazi.nvim/compare/v5.4.0...v5.5.0) (2024-08-11)


### Features

* **health:** suggest enabling new features for yazi &gt;= 0.3.0 ([#362](https://github.com/mikavilpas/yazi.nvim/issues/362)) ([8cd2f71](https://github.com/mikavilpas/yazi.nvim/commit/8cd2f712461ae69e25e2ef99b9ced5edb0cefc26))

## [5.4.0](https://github.com/mikavilpas/yazi.nvim/compare/v5.3.1...v5.4.0) (2024-08-11)


### Features

* open currently visible splits as yazi tabs (opt-in) ([#359](https://github.com/mikavilpas/yazi.nvim/issues/359)) ([c57a4ea](https://github.com/mikavilpas/yazi.nvim/commit/c57a4ea81d2a08a615e27c77fc03bd941ad2b8e1))

## [5.3.1](https://github.com/mikavilpas/yazi.nvim/compare/v5.3.0...v5.3.1) (2024-08-10)


### Bug Fixes

* highlighting siblings of hovered directories ([#357](https://github.com/mikavilpas/yazi.nvim/issues/357)) ([ed31153](https://github.com/mikavilpas/yazi.nvim/commit/ed31153bb80205e556fb40cc9284dd00d5e32b72))
* **tests:** changing the tests had delay in restarting the test ([#355](https://github.com/mikavilpas/yazi.nvim/issues/355)) ([d5f170d](https://github.com/mikavilpas/yazi.nvim/commit/d5f170d4a75a8007c657ecb55c8c2adadbdb6074))

## [5.3.0](https://github.com/mikavilpas/yazi.nvim/compare/v5.2.1...v5.3.0) (2024-08-10)


### Features

* highlight buffers in the same directory (opt-out) ([#351](https://github.com/mikavilpas/yazi.nvim/issues/351)) ([879984b](https://github.com/mikavilpas/yazi.nvim/commit/879984b9181cb2489699edeac78ee2203f502c9e))

## [5.2.1](https://github.com/mikavilpas/yazi.nvim/compare/v5.2.0...v5.2.1) (2024-08-09)


### Bug Fixes

* opening multiple files in a directory with spaces ([#347](https://github.com/mikavilpas/yazi.nvim/issues/347)) ([f7be6c1](https://github.com/mikavilpas/yazi.nvim/commit/f7be6c1f7b5cec69baf8f5d610f9d2a2a0ff5d20))

## [5.2.0](https://github.com/mikavilpas/yazi.nvim/compare/v5.1.1...v5.2.0) (2024-08-08)

### Features

* feat: add support for external integrations to hover events ([#341](https://github.com/mikavilpas/yazi.nvim/issues/341)) ([ed00655](https://github.com/mikavilpas/yazi.nvim/commit/ed00655f7047ada4fa03a1f255f66507b49f4f45))

### Miscellaneous Chores

* release 5.2.0 ([a801cb0](https://github.com/mikavilpas/yazi.nvim/commit/a801cb09854cd94a7ba2cc97f759cc42972c1325))

## [5.1.1](https://github.com/mikavilpas/yazi.nvim/compare/v5.1.0...v5.1.1) (2024-08-06)


### Performance Improvements

* don't set up nvim-tree and neo-tree in lsp-file-operations ([#332](https://github.com/mikavilpas/yazi.nvim/issues/332)) ([604f3d1](https://github.com/mikavilpas/yazi.nvim/commit/604f3d1035b5d186befb6f159cf9d59007aac61e))

## [5.1.0](https://github.com/mikavilpas/yazi.nvim/compare/v5.0.1...v5.1.0) (2024-08-05)


### Features

* keymaps can now be done with "&lt;cmd&gt;Yazi<cr>" etc. ([b038b35](https://github.com/mikavilpas/yazi.nvim/commit/b038b35f13caa468fd7df37ff5b65c293e251323))

## [5.0.1](https://github.com/mikavilpas/yazi.nvim/compare/v5.0.0...v5.0.1) (2024-08-04)


### Bug Fixes

* not being in insert mode when opening a dir from the command line ([#321](https://github.com/mikavilpas/yazi.nvim/issues/321)) ([c44ad14](https://github.com/mikavilpas/yazi.nvim/commit/c44ad14b71b30fa19ede4795158b010eb40a407a))

## [5.0.0](https://github.com/mikavilpas/yazi.nvim/compare/v4.2.0...v5.0.0) (2024-08-04)


### ⚠ BREAKING CHANGES

* **openers:** when multiple files were selected in yazi, the previous behaviour was to open them as items in the quickfix list. This has been changed to open them as buffers instead. The previous behaviour can be restored by setting `config.hooks.yazi_opened_multiple_files` to `openers.send_files_to_quickfix_list`.

### Features

* **openers:** multiple files are opened as buffers by default ([5cd3ad7](https://github.com/mikavilpas/yazi.nvim/commit/5cd3ad7ef02053d1360b9521d473f8f5a7ac7c3f))

## [4.2.0](https://github.com/mikavilpas/yazi.nvim/compare/v4.1.3...v4.2.0) (2024-08-03)


### Features

* **help:** allow closing help menu with the help key ([#314](https://github.com/mikavilpas/yazi.nvim/issues/314)) ([7dbda3c](https://github.com/mikavilpas/yazi.nvim/commit/7dbda3cb8b25183454404f2ee719305179e19088))

## [4.1.3](https://github.com/mikavilpas/yazi.nvim/compare/v4.1.2...v4.1.3) (2024-08-03)


### Bug Fixes

* pressing &lt;esc&gt; has a 1 second delay ([#311](https://github.com/mikavilpas/yazi.nvim/issues/311)) ([c38ca8f](https://github.com/mikavilpas/yazi.nvim/commit/c38ca8f1af71e87ac79abedb3bacee482200a3d8))

## [4.1.2](https://github.com/mikavilpas/yazi.nvim/compare/v4.1.1...v4.1.2) (2024-08-03)


### Bug Fixes

* `open_yazi_in_directory` error in nvim 0.10.1 & nightly ([#309](https://github.com/mikavilpas/yazi.nvim/issues/309)) ([7eb5f93](https://github.com/mikavilpas/yazi.nvim/commit/7eb5f933c863591411013a7944b0f02e80edeefc))

## [4.1.1](https://github.com/mikavilpas/yazi.nvim/compare/v4.1.0...v4.1.1) (2024-07-30)


### Bug Fixes

* grepping or replacing in cwd instead of the directory of the file ([#293](https://github.com/mikavilpas/yazi.nvim/issues/293)) ([aee19fb](https://github.com/mikavilpas/yazi.nvim/commit/aee19fb1b6ef17d961237a0682358d5ec02fe50f))

## [4.1.0](https://github.com/mikavilpas/yazi.nvim/compare/v4.0.1...v4.1.0) (2024-07-28)


### Features

* `&lt;c-y&gt;` to copy relative path to selected file(s) ([#287](https://github.com/mikavilpas/yazi.nvim/issues/287)) ([dd8995e](https://github.com/mikavilpas/yazi.nvim/commit/dd8995e9783c7a424cdbb37fab4c072177355bcc))

## [4.0.1](https://github.com/mikavilpas/yazi.nvim/compare/v4.0.0...v4.0.1) (2024-07-28)


### Bug Fixes

* help menu crashing when a keybinding is disabled ([#285](https://github.com/mikavilpas/yazi.nvim/issues/285)) ([dca52dd](https://github.com/mikavilpas/yazi.nvim/commit/dca52dd35ab76b6b6a994c1e7f2dc908cf15957d))

## [4.0.0](https://github.com/mikavilpas/yazi.nvim/compare/v3.5.0...v4.0.0) (2024-07-28)


### ⚠ BREAKING CHANGES

* If you use `use_ya_for_events_reading = true` in your yazi.nvim config, you need to upgrade your yazi version to the currently latest version:

### Miscellaneous Chores

* update to the latest commit of yazi ([#283](https://github.com/mikavilpas/yazi.nvim/issues/283)) ([c1b4e9a](https://github.com/mikavilpas/yazi.nvim/commit/c1b4e9a3136092db473708d807db5a495d38d7ce))

## [3.5.0](https://github.com/mikavilpas/yazi.nvim/compare/v3.4.0...v3.5.0) (2024-07-28)


### Features

* **health:** add instructions for `open_for_directories` ([#281](https://github.com/mikavilpas/yazi.nvim/issues/281)) ([0df9393](https://github.com/mikavilpas/yazi.nvim/commit/0df939302b632368317f3d074590b72795c63334))

## [3.4.0](https://github.com/mikavilpas/yazi.nvim/compare/v3.3.0...v3.4.0) (2024-07-28)


### Features

* allow searching in selected files with telescope ([#279](https://github.com/mikavilpas/yazi.nvim/issues/279)) ([55e98d8](https://github.com/mikavilpas/yazi.nvim/commit/55e98d867104490ab7a139f55578d0300d4c8f1d))

## [3.3.0](https://github.com/mikavilpas/yazi.nvim/compare/v3.2.0...v3.3.0) (2024-07-27)


### Features

* can limit search and replace to selected files only ([#277](https://github.com/mikavilpas/yazi.nvim/issues/277)) ([5a12444](https://github.com/mikavilpas/yazi.nvim/commit/5a12444e811925f8454483061a8313211a6d618c))

## [3.2.0](https://github.com/mikavilpas/yazi.nvim/compare/v3.1.8...v3.2.0) (2024-07-27)


### Features

* can toggle help menu with `&lt;f1&gt;` key in the yazi window ([#275](https://github.com/mikavilpas/yazi.nvim/issues/275)) ([cc65bb5](https://github.com/mikavilpas/yazi.nvim/commit/cc65bb57abb970b7f5c1ce8db498f9712c3462cf))

## [3.1.8](https://github.com/mikavilpas/yazi.nvim/compare/v3.1.7...v3.1.8) (2024-07-27)


### Bug Fixes

* not being able to open directories with enter ([#272](https://github.com/mikavilpas/yazi.nvim/issues/272)) ([d70bb91](https://github.com/mikavilpas/yazi.nvim/commit/d70bb91569a472e5d9876bf445b161e7be087831))

## [3.1.7](https://github.com/mikavilpas/yazi.nvim/compare/v3.1.6...v3.1.7) (2024-07-26)


### Bug Fixes

* close the floating terminal if it loses focus ([#269](https://github.com/mikavilpas/yazi.nvim/issues/269)) ([c9ebbf6](https://github.com/mikavilpas/yazi.nvim/commit/c9ebbf6749980680a533125ac08a0d57257c04a9))

## [3.1.6](https://github.com/mikavilpas/yazi.nvim/compare/v3.1.5...v3.1.6) (2024-07-26)


### Bug Fixes

* escape spaces in paths for grug-far integration ([#267](https://github.com/mikavilpas/yazi.nvim/issues/267)) ([f265e95](https://github.com/mikavilpas/yazi.nvim/commit/f265e957399ae80ffbbd63d75cef35c9f6b574ab))

## [3.1.5](https://github.com/mikavilpas/yazi.nvim/compare/v3.1.4...v3.1.5) (2024-07-25)


### Bug Fixes

* grug-far appending extra text at the end of replaced files ([#263](https://github.com/mikavilpas/yazi.nvim/issues/263)) ([be2ac43](https://github.com/mikavilpas/yazi.nvim/commit/be2ac43a530b9b8c8b1a6185f07fac13f128f046))

## [3.1.4](https://github.com/mikavilpas/yazi.nvim/compare/v3.1.3...v3.1.4) (2024-07-25)


### Bug Fixes

* renaming a file twice not updating the buffer name ([#259](https://github.com/mikavilpas/yazi.nvim/issues/259)) ([98caf39](https://github.com/mikavilpas/yazi.nvim/commit/98caf394dc998793dbb4987cbfefa5182ac4a65a))

## [3.1.3](https://github.com/mikavilpas/yazi.nvim/compare/v3.1.2...v3.1.3) (2024-07-25)


### Bug Fixes

* LSP renaming did not work in some cases ([#260](https://github.com/mikavilpas/yazi.nvim/issues/260)) ([6afe997](https://github.com/mikavilpas/yazi.nvim/commit/6afe997df07ba668fb443bc6e20b3c024078d8cb))

## [3.1.2](https://github.com/mikavilpas/yazi.nvim/compare/v3.1.1...v3.1.2) (2024-07-25)


### Bug Fixes

* grug-far integration not being able to search outside of the cwd ([#256](https://github.com/mikavilpas/yazi.nvim/issues/256)) ([f446cb8](https://github.com/mikavilpas/yazi.nvim/commit/f446cb8734b839ee3bd971dd44abdf5dcd4ce0db))


### Performance Improvements

* improve lazy loading to 7 -&gt; 4 modules ([#255](https://github.com/mikavilpas/yazi.nvim/issues/255)) ([e29f633](https://github.com/mikavilpas/yazi.nvim/commit/e29f633e2d74e0e54f6580b5b4cf03a5f249fa85))

## [3.1.1](https://github.com/mikavilpas/yazi.nvim/compare/v3.1.0...v3.1.1) (2024-07-24)


### Performance Improvements

* lazy load yazi.nvim modules by default ([#253](https://github.com/mikavilpas/yazi.nvim/issues/253)) ([f832c3c](https://github.com/mikavilpas/yazi.nvim/commit/f832c3cc50aab5bb3aad1a14b03850295628bc6d))

## [3.1.0](https://github.com/mikavilpas/yazi.nvim/compare/v3.0.1...v3.1.0) (2024-07-24)


### Features

* add optional search and replace integration (grug-far.nvim) ([#250](https://github.com/mikavilpas/yazi.nvim/issues/250)) ([b512d38](https://github.com/mikavilpas/yazi.nvim/commit/b512d3898d7d37273fdad43e6ad697cf29839a28))

## [3.0.1](https://github.com/mikavilpas/yazi.nvim/compare/v3.0.0...v3.0.1) (2024-07-23)


### Bug Fixes

* not being able to override the log level per invocation ([f5c7b73](https://github.com/mikavilpas/yazi.nvim/commit/f5c7b73f30cf0ca19935dd7c92999e1e3549a128))

## [3.0.0](https://github.com/mikavilpas/yazi.nvim/compare/v2.6.0...v3.0.0) (2024-07-23)


### ⚠ BREAKING CHANGES

* If you, for some reason, relied on the fact that `set_keymappings_function` removed all the built-in keymappings, you will need to change your configuration. You can get the same behaviour by setting `keymaps = false`. But realistically I think almost nobody has done this, so it should be fine.

### Features

* allow customizing keymaps more clearly ([#244](https://github.com/mikavilpas/yazi.nvim/issues/244)) ([f511e64](https://github.com/mikavilpas/yazi.nvim/commit/f511e64197bf29b5e1eda792791f0541fadc1c32))

## [2.6.0](https://github.com/mikavilpas/yazi.nvim/compare/v2.5.1...v2.6.0) (2024-07-22)


### Features

* **health:** show exact version of yazi and ya in health check ([#238](https://github.com/mikavilpas/yazi.nvim/issues/238)) ([a2f6e2b](https://github.com/mikavilpas/yazi.nvim/commit/a2f6e2b6a96e3b3fd53c15629cb95b0347b1324a))

## [2.5.1](https://github.com/mikavilpas/yazi.nvim/compare/v2.5.0...v2.5.1) (2024-07-21)


### Bug Fixes

* buffer cycling small errors ([#234](https://github.com/mikavilpas/yazi.nvim/issues/234)) ([a43465e](https://github.com/mikavilpas/yazi.nvim/commit/a43465efef62b897474808e680fd9248c4ce6c71))

## [2.5.0](https://github.com/mikavilpas/yazi.nvim/compare/v2.4.0...v2.5.0) (2024-07-21)


### Features

* pressing `tab` in yazi jumps to dir of next open split ([#232](https://github.com/mikavilpas/yazi.nvim/issues/232)) ([3cbc40c](https://github.com/mikavilpas/yazi.nvim/commit/3cbc40c01ef96c0d1d56b6caa33bb951b7212c0e))

## [2.4.0](https://github.com/mikavilpas/yazi.nvim/compare/v2.3.1...v2.4.0) (2024-07-20)


### Features

* add `yazi.toggle()` to continue from the last hovered file ([#230](https://github.com/mikavilpas/yazi.nvim/issues/230)) ([dbddef0](https://github.com/mikavilpas/yazi.nvim/commit/dbddef0e047f95d15f6e1fa93cbb7be730200092))

## [2.3.1](https://github.com/mikavilpas/yazi.nvim/compare/v2.3.0...v2.3.1) (2024-07-19)


### Bug Fixes

* crash without newest yazi ([#227](https://github.com/mikavilpas/yazi.nvim/issues/227)) ([de4e79e](https://github.com/mikavilpas/yazi.nvim/commit/de4e79e07867c29c871a91d464c421ca1f26ba33))

## [2.3.0](https://github.com/mikavilpas/yazi.nvim/compare/v2.2.2...v2.3.0) (2024-07-19)


### Features

* add targeted communication with the yazi instance (opt-in) ([#225](https://github.com/mikavilpas/yazi.nvim/issues/225)) ([8114817](https://github.com/mikavilpas/yazi.nvim/commit/81148178ccdfacd68f302b5c54dec649eb0a1ae3))

## [2.2.2](https://github.com/mikavilpas/yazi.nvim/compare/v2.2.1...v2.2.2) (2024-07-18)


### Bug Fixes

* **health:** warn when yazi and ya versions do not match ([#221](https://github.com/mikavilpas/yazi.nvim/issues/221)) ([e694c26](https://github.com/mikavilpas/yazi.nvim/commit/e694c2661af2c2443f8636247a1def9a9b398276))

## [2.2.1](https://github.com/mikavilpas/yazi.nvim/compare/v2.2.0...v2.2.1) (2024-07-16)


### Bug Fixes

* symlinked files cannot be highlighted when hovered ([#212](https://github.com/mikavilpas/yazi.nvim/issues/212)) ([85e8d1d](https://github.com/mikavilpas/yazi.nvim/commit/85e8d1d050f5e73bf5f5f3275109a676257f53ae))

## [2.2.0](https://github.com/mikavilpas/yazi.nvim/compare/v2.1.0...v2.2.0) (2024-07-16)


### Features

* healthcheck reports yazi nvim version ([#208](https://github.com/mikavilpas/yazi.nvim/issues/208)) ([08ffd84](https://github.com/mikavilpas/yazi.nvim/commit/08ffd84e613d9dbc843188d4a2e3b2f04cd9bc6a))

## [2.1.0](https://github.com/mikavilpas/yazi.nvim/compare/v2.0.0...v2.1.0) (2024-07-15)


### Features

* **plugin:** overwrite existing symlinks when installing plugins ([#199](https://github.com/mikavilpas/yazi.nvim/issues/199)) ([d09818e](https://github.com/mikavilpas/yazi.nvim/commit/d09818e19d4b43d64a1ca2872d940924ca7b2819))

## [2.0.0](https://github.com/mikavilpas/yazi.nvim/compare/v1.5.1...v2.0.0) (2024-07-14)


### ⚠ BREAKING CHANGES

* The optional `hovered_buffer_background` key in the `YaziConfigHighlightGroups` has been renamed to `hovered_buffer`. This change was made to better reflect the purpose of the key.

### Features

* add default colors for hover highlighting ([#194](https://github.com/mikavilpas/yazi.nvim/issues/194)) ([1deeba2](https://github.com/mikavilpas/yazi.nvim/commit/1deeba2fb2ab6a741d1df66a80b08112bae59327))

## [1.5.1](https://github.com/mikavilpas/yazi.nvim/compare/v1.5.0...v1.5.1) (2024-07-12)


### Bug Fixes

* not handling bulk renaming events correctly ([607db68](https://github.com/mikavilpas/yazi.nvim/commit/607db68b14b72dc38d235b6ebdb9a6361ba84691))

## [1.5.0](https://github.com/mikavilpas/yazi.nvim/compare/v1.4.0...v1.5.0) (2024-07-12)


### Features

* highlight the currently hovered file in yazi (opt-in) ([#180](https://github.com/mikavilpas/yazi.nvim/issues/180)) ([78cb7d2](https://github.com/mikavilpas/yazi.nvim/commit/78cb7d2eb67cefaeed60dd8d1649ccb443dbf154))

## [1.4.0](https://github.com/mikavilpas/yazi.nvim/compare/v1.3.0...v1.4.0) (2024-07-11)


### Features

* **plugin:** allow specifying a subdirectory for plugins ([0e79514](https://github.com/mikavilpas/yazi.nvim/commit/0e795143ac53d8805e9b08cf2454c55cb3a6a83a))

## [1.3.0](https://github.com/mikavilpas/yazi.nvim/compare/v1.2.3...v1.3.0) (2024-07-10)


### version

* 1.3.0 ([bd19300](https://github.com/mikavilpas/yazi.nvim/commit/bd193005f818473dd924d35448b8af7eb398cf9a))


### Features

* support bulk renaming files in nightly yazi (opt-in) ([#152](https://github.com/mikavilpas/yazi.nvim/issues/152)) ([8bd164d](https://github.com/mikavilpas/yazi.nvim/commit/8bd164dc0631e6bb394ba6f680e85c1adefd74be))


## [1.2.3](https://github.com/mikavilpas/yazi.nvim/compare/v1.2.2...v1.2.3) (2024-07-03)


### Bug Fixes

* remove extra debug logging ([#153](https://github.com/mikavilpas/yazi.nvim/issues/153)) ([2fc4679](https://github.com/mikavilpas/yazi.nvim/commit/2fc46796d35a89958aca8666ddbeda81b81a3d0a))

## [1.2.2](https://github.com/mikavilpas/yazi.nvim/compare/v1.2.1...v1.2.2) (2024-07-02)


### Bug Fixes

* not being able to disable writing DEBUG logs ([#150](https://github.com/mikavilpas/yazi.nvim/issues/150)) ([8f251de](https://github.com/mikavilpas/yazi.nvim/commit/8f251defe31ce7b3e623b499e08a7c558d79bfdb))

## [1.2.1](https://github.com/mikavilpas/yazi.nvim/compare/v1.2.0...v1.2.1) (2024-06-30)


### Bug Fixes

* **repro:** update the repro instructions to update the dependencies ([#146](https://github.com/mikavilpas/yazi.nvim/issues/146)) ([b90d4fe](https://github.com/mikavilpas/yazi.nvim/commit/b90d4fe28ea8338174daf8922f49718c82d66161))

## [1.2.0](https://github.com/mikavilpas/yazi.nvim/compare/v1.1.5...v1.2.0) (2024-06-30)


### Features

* lazy.nvim users no longer need to specify dependencies ([#144](https://github.com/mikavilpas/yazi.nvim/issues/144)) ([e6fe720](https://github.com/mikavilpas/yazi.nvim/commit/e6fe720ca30459f67a798e31e6d84fdce76f2b89))

## [1.1.5](https://github.com/mikavilpas/yazi.nvim/compare/v1.1.4...v1.1.5) (2024-06-29)


### Bug Fixes

* open file results in one empty buffer ([#138](https://github.com/mikavilpas/yazi.nvim/issues/138)) ([73a5f8f](https://github.com/mikavilpas/yazi.nvim/commit/73a5f8f37971cc133bbab978eac825968e90bb9c))

## [1.1.4](https://github.com/mikavilpas/yazi.nvim/compare/v1.1.3...v1.1.4) (2024-06-21)


### Bug Fixes

* opening "nvim dir/" may focus wrong window ([93de590](https://github.com/mikavilpas/yazi.nvim/commit/93de590cf13e430ed7077e8abc65b2213878706a))

## [1.1.3](https://github.com/mikavilpas/yazi.nvim/compare/v1.1.2...v1.1.3) (2024-06-16)


### Bug Fixes

* exiting insert mode with "&lt;esc&gt;<esc>" ([bc2aabb](https://github.com/mikavilpas/yazi.nvim/commit/bc2aabbc23aa194b7a3e7aed5a0d466d0a7565f9))

## [1.1.2](https://github.com/mikavilpas/yazi.nvim/compare/v1.1.1...v1.1.2) (2024-06-05)


### Bug Fixes

* open buffers deleted in yazi were not closed ([6dc4a48](https://github.com/mikavilpas/yazi.nvim/commit/6dc4a48c586201f545a9bac6c1e69474d3059c93))


### Performance Improvements

* processing open buffers only processes normal buffers ([5acce15](https://github.com/mikavilpas/yazi.nvim/commit/5acce153d31c821dcc3535f1cd2da2ddbd4200f7))

## [1.1.1](https://github.com/mikavilpas/yazi.nvim/compare/v1.1.0...v1.1.1) (2024-06-03)


### Bug Fixes

* **plugins:** fix failure on repeated installation ([3df04c4](https://github.com/mikavilpas/yazi.nvim/commit/3df04c467e11b448083a0987688ba4d4782e73ec))

## [1.1.0](https://github.com/mikavilpas/yazi.nvim/compare/v1.0.0...v1.1.0) (2024-06-03)


### Features

* **plugins:** support including yazi flavors with `.build_flavor` ([efc0ef1](https://github.com/mikavilpas/yazi.nvim/commit/efc0ef111835534455a93a05432aff13ea05bde2))

## 1.0.0 (2024-05-26)


### ⚠ BREAKING CHANGES

* This commit removes the `lsp_util` module, which was used to provide compatibility with Neovim 0.9.0. We now only support nvim 0.10.0 and later.
* require yazi version 0.2.5 (previously required 0.2.4)
* **window:** greatly simplify the code
* remap default horizontal split c-s -> c-x
* allow customizing the config when calling yazi()
* remove possibility to configure the border characters
* The plugin is now written in Lua and the vimscript part is removed.
* this plugin now requires yazi 0.2.4 or newer.
* remove vim.g.yazi_opened (integer)
* remove g:yazi_use_neovim_remote (not used)

### Features

* &lt;c-s&gt; closes yazi and starts telescope.nvim's live_grep ([33657fc](https://github.com/mikavilpas/yazi.nvim/commit/33657fcda1a23f920208caa34bb3f0ef7d8d4913))
* add healthcheck ([4dd9284](https://github.com/mikavilpas/yazi.nvim/commit/4dd9284a037d33352727f2b0413e938a5446b925))
* add mp4 demo that is generated using vhs ([6e1df89](https://github.com/mikavilpas/yazi.nvim/commit/6e1df89ea36b0aaf528095bb6a50e3066eb677bb))
* allow customizing the config when calling yazi() ([13e35c2](https://github.com/mikavilpas/yazi.nvim/commit/13e35c2cde918fa52e8249474bf04a9f5f0fd160))
* allow opening the selected file in a horizontal split ([f3847fd](https://github.com/mikavilpas/yazi.nvim/commit/f3847fde94ce506df92a04eaffed1f98be02a27f))
* allow opening the selected file in a new tab ([e4c5532](https://github.com/mikavilpas/yazi.nvim/commit/e4c55323c73f237a77a97b04bfc456734ed34227))
* allow opening the selected file in a vertical split ([1bb74ca](https://github.com/mikavilpas/yazi.nvim/commit/1bb74ca0327a12e41d3f198707442582d8837ce7))
* allow yazi_closed_successfully hook to know the last yazi dir ([4541e44](https://github.com/mikavilpas/yazi.nvim/commit/4541e44f3a48cc7a5da5a06c033e1b1bfc36db46))
* basic support for resizing the yazi window ([01e4685](https://github.com/mikavilpas/yazi.nvim/commit/01e4685b197bf09b7b41c9ab4b170f50692d0394))
* can open a directory from the command line ([c32b990](https://github.com/mikavilpas/yazi.nvim/commit/c32b990c84b0e5b55a8f8cbe53f2e5ee6ecd37ef))
* can open multiple files in splits or tabs ([e6878ed](https://github.com/mikavilpas/yazi.nvim/commit/e6878ed78f373d0b93a0a8418f67034177f2072b))
* **config:** allow customizing the method of opening the file ([45cc55f](https://github.com/mikavilpas/yazi.nvim/commit/45cc55f4734599fb68952eca1089c1a6479c2503))
* **config:** the chosen_file_path is configurable ([181f156](https://github.com/mikavilpas/yazi.nvim/commit/181f1563ea030add9376d1e066b0f069ccbfc221))
* **config:** the events file path is configurable ([bf45ac7](https://github.com/mikavilpas/yazi.nvim/commit/bf45ac783f372ad0dc38f5628b53cd2db249ba8a))
* directories sent to the qf list end in '/' ([85dafe2](https://github.com/mikavilpas/yazi.nvim/commit/85dafe2167b2542caf380f889629d94636ca9ba2))
* file opener hooks get access to the last dir visited ([0abd8e9](https://github.com/mikavilpas/yazi.nvim/commit/0abd8e91d191f72983d6241035f26a3bb4a22f0f))
* files renamed in yazi are kept in sync in nvim ([bd57653](https://github.com/mikavilpas/yazi.nvim/commit/bd576536084d99a95bb23d3d11ae62bb399ab6b0))
* **health:** warn when using nvim &lt; 0.10.0 ([9b4130b](https://github.com/mikavilpas/yazi.nvim/commit/9b4130ba1b19672633a768c0cef97b118d7c5936))
* **hooks:** add yazi_closed_successfully hook ([cb11663](https://github.com/mikavilpas/yazi.nvim/commit/cb11663730e39fe0f40bc7364cdc9df6f1098f03))
* **hooks:** add yazi_opened hook ([ce48deb](https://github.com/mikavilpas/yazi.nvim/commit/ce48debc3dfc7694ef568d286db48b2f2a2f0106))
* items sent to the quickfix list don't specify renundant lnum 1 ([a9d76ab](https://github.com/mikavilpas/yazi.nvim/commit/a9d76ab5c69f1182fc5452619cbf6f91ae9d9555))
* **log:** add possibility for debug logging to diagnose issues ([db4ca7b](https://github.com/mikavilpas/yazi.nvim/commit/db4ca7bc1090ba6f4962e23db776e73df9b87848))
* **lsp:** apply changes to related files when a file is deleted ([e824eb2](https://github.com/mikavilpas/yazi.nvim/commit/e824eb2dbb2c195cbbd5f3e628297f741258d041))
* **lsp:** apply changes to related files when a file is renamed ([43ed7dc](https://github.com/mikavilpas/yazi.nvim/commit/43ed7dcd24fc6e9ecbc8b74bc934d5619fce0c12))
* make it easier to completely override the default keymappings ([96ff34a](https://github.com/mikavilpas/yazi.nvim/commit/96ff34ab383ae93609112e4e84b7dacd20114614))
* make it easier to create custom keymappings in the user config ([a6df4d7](https://github.com/mikavilpas/yazi.nvim/commit/a6df4d7e28b824fb3ce1e7cd1fcce3231a5afbc9))
* **mouse:** add hacky support for scrolling inside tmux ([26eb08f](https://github.com/mikavilpas/yazi.nvim/commit/26eb08f1c50c74a49581bf3f6bbc456c7cf36290))
* **mouse:** add hacky support for scrolling yazi (opt-in) ([83619ea](https://github.com/mikavilpas/yazi.nvim/commit/83619eae7f94b881ef9367d7f601271ee0a59633))
* plugin manager for installing and updating yazi plugins ([fd727d8](https://github.com/mikavilpas/yazi.nvim/commit/fd727d8f7c6eaef14ce7a784b406cb2b7f089164))
* **plugins:** add some sanity checking and error reporting ([169ac39](https://github.com/mikavilpas/yazi.nvim/commit/169ac399d4efab8dd7f6fbd94c8b8b48568a1f82))
* require yazi version 0.2.5 (previously required 0.2.4) ([ad4f8a2](https://github.com/mikavilpas/yazi.nvim/commit/ad4f8a2543ac959532d304baf43ac3b0a1a88d48))
* show multiple selected files in the quickfix list ([13aa3e4](https://github.com/mikavilpas/yazi.nvim/commit/13aa3e478c0e92da66843e5c1c4bd519fdba4a65))
* the path given to yazi is not ignored ([5226589](https://github.com/mikavilpas/yazi.nvim/commit/5226589bc429b1835c8b9152dda57b56affaa3d0))
* update demo to showcase new features ([5c1b7ae](https://github.com/mikavilpas/yazi.nvim/commit/5c1b7aebb3cdc1e84841cded4781dd1d012f2c62))
* warn when the yazi version is too old ([3c36057](https://github.com/mikavilpas/yazi.nvim/commit/3c36057a3a1ae70fe5e0ff426d6b5d25b25fb492))
* when files are deleted in yazi, they are closed in nvim ([d06d61e](https://github.com/mikavilpas/yazi.nvim/commit/d06d61eaea37d5090212b714f1a74b08eba11f2b))
* when files are moved in yazi, they stay in sync in nvim ([0904cdd](https://github.com/mikavilpas/yazi.nvim/commit/0904cdd30aed8cfbf3f1cc03130b256e23cdd455))
* **window:** allow customizing the border ([410c9ed](https://github.com/mikavilpas/yazi.nvim/commit/410c9ed1570ba8f4755b8741ea1702284c95721c))


### Bug Fixes

* 4: account for paths with spaces ([e0006ec](https://github.com/mikavilpas/yazi.nvim/commit/e0006ec83f353461ba8bacf5c200cda0a3634a34))
* add quotes back for windows systems ([1dd8403](https://github.com/mikavilpas/yazi.nvim/commit/1dd84034e6a881d59dbd8931e4dffc52cd0a57c8))
* avoid issues with events_file_path having spaces ([a6d918f](https://github.com/mikavilpas/yazi.nvim/commit/a6d918f9a742cb7f8de804f2118b4deb3f59dc8b))
* complex character file name resolution for multiple files ([051bfce](https://github.com/mikavilpas/yazi.nvim/commit/051bfcef27f68aa22d14fc11342d3473bae1cb78))
* crash when current file contains "()" characters in its path/name ([ca914e0](https://github.com/mikavilpas/yazi.nvim/commit/ca914e0539e123143d12a03a8e3d37d0b722057f))
* crash when renaming to an open buffer ([0ff9086](https://github.com/mikavilpas/yazi.nvim/commit/0ff90869ced6e3c347f2677e5b2d16eead98e3a9))
* don't close a removed file if renamed to later ([82aa8a4](https://github.com/mikavilpas/yazi.nvim/commit/82aa8a4e885a54aa636755f45855b0a6ecf56963))
* **healthcheck:** support different yazi version formats ([07826ef](https://github.com/mikavilpas/yazi.nvim/commit/07826ef63a77ee08d8345ab4877063a763f73a59))
* **lsp:** only notifying lsp of renames for open buffers ([85bac6b](https://github.com/mikavilpas/yazi.nvim/commit/85bac6b14f79b270274bca115645014770373fa1))
* **lsp:** renaming only notified the lsp for the current file ([f3ccc14](https://github.com/mikavilpas/yazi.nvim/commit/f3ccc14fd1c685dc16ad6db77154dc5a804093ec))
* not being able to open file names with complex characters ([bdec3b6](https://github.com/mikavilpas/yazi.nvim/commit/bdec3b6211b665ca1233d117efbf4025a350a31a))
* not being able to open files with special chars on osx ([8c5ef23](https://github.com/mikavilpas/yazi.nvim/commit/8c5ef239f73c07e80e51cdacf55b609a4ef012ae))
* not being able to open yazi for directories ([9b80f3e](https://github.com/mikavilpas/yazi.nvim/commit/9b80f3ee0d7665bffc0462994b5693a0c8d80b5f))
* not entering insert mode when invoked from telescope results ([4beaec3](https://github.com/mikavilpas/yazi.nvim/commit/4beaec3bb42a344d1cc4f2d953e2ba6b0e7ec2f0))
* opening many files with custom keymappings causing an error ([86f3623](https://github.com/mikavilpas/yazi.nvim/commit/86f3623a5ca0290c50a65e1bc1f37232aa88648b))
* remap default horizontal split c-s -&gt; c-x ([e9dce4f](https://github.com/mikavilpas/yazi.nvim/commit/e9dce4fd669bec0284c660a6860afe83594cbda2))
* renaming did not work any longer ([ff05b58](https://github.com/mikavilpas/yazi.nvim/commit/ff05b58d26471e883cfc8ddc5dc437c69b2182f3))
* renaming the same file multiple times did not sync to nvim ([3a59384](https://github.com/mikavilpas/yazi.nvim/commit/3a59384296703a3553bc7cc17436d4a3f5f7e4ce))
* try to fix opening paths with spaces on windows ([e375060](https://github.com/mikavilpas/yazi.nvim/commit/e375060189714aa8462018c3c59c8096102ce974))
* use explicit buffer id to ensure the behavior of 'winleave' autocmd meets expectations; avoid closing a window that does not exist. ([d8a773a](https://github.com/mikavilpas/yazi.nvim/commit/d8a773a89591498ccd78243568ab766fa0cc1b0d))
* when opening a directory, insert mode is not activated ([2cf6057](https://github.com/mikavilpas/yazi.nvim/commit/2cf605783e66523d1ac83cc65b2196193d81adcd))
* **window:** try to always close the window when focus is lost ([40eb32c](https://github.com/mikavilpas/yazi.nvim/commit/40eb32cd81e3ae9836ed3b761a04704aa8d3080b))


### Code Refactoring

* remove g:yazi_use_neovim_remote (not used) ([dbd15c1](https://github.com/mikavilpas/yazi.nvim/commit/dbd15c10a51e2e9be7de99f659778942e70aa8cf))
* remove lsp_util (nvim 0.9.0 compatibility) ([6f27462](https://github.com/mikavilpas/yazi.nvim/commit/6f27462fc5022c5d64e3ff21ed9aff5b7b653d97))
* remove possibility to configure the border characters ([447c5f0](https://github.com/mikavilpas/yazi.nvim/commit/447c5f0f05350c7830c7c30722161b8f9caf4921))
* remove vim.g.yazi_opened (integer) ([9e5b584](https://github.com/mikavilpas/yazi.nvim/commit/9e5b584082c012b6c834a605111b8a19e9219dc3))
* remove vimscript part of the plugin ([9939329](https://github.com/mikavilpas/yazi.nvim/commit/9939329bf74ed5af5b1fcfa10bebb00aa1c1b742))
* **window:** greatly simplify the code ([eb7cf24](https://github.com/mikavilpas/yazi.nvim/commit/eb7cf24b00c3288e824f4022dec5fd42840d99b7))
