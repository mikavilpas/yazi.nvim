# Changelog

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
