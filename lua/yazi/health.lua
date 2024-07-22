-- see :help :checkhealth
-- https://github.com/neovim/neovim/blob/b7779c514632f8c7f791c92203a96d43fffa57c6/runtime/doc/pi_health.txt#L17
return {
  check = function()
    vim.health.start('yazi')

    local yazi = require('yazi')

    local msg = string.format('Running yazi.nvim version %s', yazi.version)
    vim.health.info(msg)

    if vim.fn.has('nvim-0.10.0') ~= 1 then
      vim.health.warn(
        'yazi.nvim requires Neovim >= 0.10.0. You might have unexpected issues.'
      )
    end

    if vim.fn.executable('yazi') ~= 1 then
      vim.health.warn('yazi not found on PATH')
    end

    -- example data:
    -- 'yazi 0.2.4 (411ba2f 2024-03-15)'
    local raw_version = vim.fn.system('yazi --version')

    -- parse the version
    --
    -- the beginning of the output might contain CSI sequences on some systems. See
    -- https://github.com/mikavilpas/yazi.nvim/pull/73
    -- https://github.com/sxyazi/yazi/commit/4c35f26e
    local yazi_semver = raw_version:match('[Yy]azi (%w+%.%w+%.%w+)')

    if yazi_semver == nil then
      vim.health.warn('yazi --version looks unexpected, saw ' .. raw_version)
    end

    local checker = require('vim.version')
    if not checker.gt(yazi_semver, '0.2.4') then
      return vim.health.warn(
        'yazi version is too old, please upgrade to 0.2.5 or newer'
      )
    else
      vim.health.info(
        ('Found `yazi` version `%s` 👍'):format(raw_version:gsub('\n', ''))
      )
    end

    local logfile_location = require('yazi.log'):get_logfile_path()
    vim.health.info('yazi.nvim log file is at ' .. logfile_location)
    vim.health.info('    hint: use `gf` to open the file path under the cursor')

    local config = require('yazi').config

    if config.use_yazi_client_id_flag == true then
      local output = vim.fn.system('yazi --help')

      if output:find('--client-id', 1, true) == nil then
        vim.health.warn(
          'You have enabled `use_yazi_client_id_flag` in your config, which means using the `--client-id` flag with yazi. However, this flag is not found in the `yazi --help` output. Please upgrade to the newest version of yazi or disable `use_yazi_client_id_flag`.'
        )
        vim.health.info(string.format('`yazi --help` output: %s', output))
      end
    end

    -- TODO validate that the highlight_config is present in the configuration

    if config.use_ya_for_events_reading == true then
      if vim.fn.executable('ya') ~= 1 then
        vim.health.error(
          'You have opted in to using `ya` for events reading, but `ya` is not found on PATH. Please install `ya` or disable `use_ya_for_events_reading` in your config.'
        )
        return
      end

      -- example data:
      -- Ya 0.2.5 (f5a7ace 2024-06-23)
      local raw_ya_version = vim.fn.system('ya --version') or ''
      local ya_semver = raw_ya_version:match('[Yy]a (%w+%.%w+%.%w+)')
      if ya_semver == nil then
        vim.health.warn(
          string.format(
            '`ya --version` looks unexpected, saw `%s` 🤔',
            raw_ya_version
          )
        )
      else
        if not checker.gt(ya_semver, '0.2.4') then
          vim.health.warn(
            'The `ya` executable version (yazi command line interface) is too old. Please upgrade to the newest version.'
          )
        else
          vim.health.info(
            ('Found `ya` version `%s` 👍'):format(
              raw_ya_version:gsub('\n', '')
            )
          )
        end
      end

      if yazi_semver ~= ya_semver then
        vim.health.warn(
          string.format(
            'The versions of `yazi` and `ya` do not match. This is untested - try to make them the same. `yazi` is `%s` and `ya` is `%s`.',
            yazi_semver,
            ya_semver
          )
        )
      end
    end

    vim.health.ok('yazi')
  end,
}
