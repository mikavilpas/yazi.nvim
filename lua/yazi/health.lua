-- see :help :checkhealth
-- https://github.com/neovim/neovim/blob/b7779c514632f8c7f791c92203a96d43fffa57c6/runtime/doc/pi_health.txt#L17
return {
  check = function()
    vim.health.start("yazi")

    local yazi = require("yazi")

    local msg = string.format("Running yazi.nvim version %s", yazi.version)
    vim.health.info(msg)

    if vim.fn.has("nvim-0.10.0") ~= 1 then
      vim.health.warn(
        "yazi.nvim requires Neovim >= 0.10.0. You might have unexpected issues."
      )
    end

    if vim.fn.executable("yazi") ~= 1 then
      vim.health.warn("yazi not found on PATH")
    end

    -- example data:
    -- Yazi 0.3.1 (4112bf4 2024-08-15)
    local raw_version = vim.fn.system("yazi --version")

    -- parse the version
    --
    -- the beginning of the output might contain CSI sequences on some systems. See
    -- https://github.com/mikavilpas/yazi.nvim/pull/73
    -- https://github.com/sxyazi/yazi/commit/4c35f26e
    local yazi_semver = raw_version:match("[Yy]azi (%w+%.%w+%.%w+)")

    if yazi_semver == nil then
      vim.health.warn("yazi --version looks unexpected, saw " .. raw_version)
    end

    local checker = require("vim.version")
    if not checker.ge(yazi_semver, "0.3.0") then
      return vim.health.warn(
        "your yazi version is too old, please upgrade to the newest version of yazi"
      )
    else
      vim.health.info(
        ("Found `yazi` version `%s` 👍"):format(raw_version:gsub("\n", ""))
      )
    end

    local logfile_location = require("yazi.log"):get_logfile_path()
    vim.health.info("yazi.nvim log file is at " .. logfile_location)
    vim.health.info("    hint: use `gf` to open the file path under the cursor")

    local config = require("yazi").config

    -- TODO validate that the highlight_config is present in the configuration

    if vim.fn.executable("ya") ~= 1 then
      vim.health.error("`ya` is not found on PATH. Please install `ya`.")
      return
    end

    -- example data:
    -- Ya 0.3.1 (4112bf4 2024-08-15)
    local raw_ya_version = vim.fn.system("ya --version") or ""
    local ya_semver = raw_ya_version:match("[Yy]a (%w+%.%w+%.%w+)")
    if ya_semver == nil then
      vim.health.warn(
        string.format(
          "`ya --version` looks unexpected, saw `%s` 🤔",
          raw_ya_version
        )
      )
    else
      if not checker.ge(ya_semver, "0.3.0") then
        vim.health.warn(
          "The `ya` executable version (yazi command line interface) is too old. Please upgrade to the newest version."
        )
      else
        vim.health.info(
          ("Found `ya` version `%s` 👍"):format(raw_ya_version:gsub("\n", ""))
        )
      end
    end

    if yazi_semver ~= ya_semver then
      vim.health.warn(
        string.format(
          "The versions of `yazi` and `ya` do not match. This is untested - try to make them the same. `yazi` is `%s` and `ya` is `%s`.",
          yazi_semver,
          ya_semver
        )
      )
    end

    if config.open_for_directories == true then
      vim.health.info(
        "You have enabled `open_for_directories` in your config. Because of this, please make sure you are loading yazi when Neovim starts."
      )
    end

    local resolver = config.integrations.resolve_relative_path_application
    if
      config.keymaps.copy_relative_path_to_selected_files ~= false
      and vim.fn.executable(resolver) ~= 1
    then
      vim.health.warn(
        string.format(
          "The `resolve_relative_path_application` (`%s`) is not found on PATH. Please either install it, make sure it is on your PATH, or set `config.keymaps.copy_relative_path_to_selected_files = nil` in your configuration.",
          resolver
        )
      )
      vim.health.info(
        "The default application (realpath) should be installed on most linux systems by default. On OSX, the default (grealpath) can be found in https://formulae.brew.sh/formula/coreutils"
      )
    end

    if config.future_features and config.future_features.ya_emit_reveal then
      if not checker.ge(yazi_semver, "0.4.0") then
        vim.health.warn(
          "You have enabled `future_features.ya_emit_reveal` in your config. This requires yazi.nvim version 0.4.0 or newer."
        )
      end
    end

    vim.health.start("yazi.config")
    vim.health.info(table.concat({
      "hint: execute the following command to see your configuration: >",
      ":lua =require('yazi').config",
      "",
    }, "\n"))

    vim.health.ok("yazi")
  end,
}
