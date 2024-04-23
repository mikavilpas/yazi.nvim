-- see :help :checkhealth
-- https://github.com/neovim/neovim/blob/b7779c514632f8c7f791c92203a96d43fffa57c6/runtime/doc/pi_health.txt#L17
return {
  check = function()
    vim.health.start('yazi')

    if vim.fn.executable('yazi') ~= 1 then
      vim.health.warn('yazi not found on PATH')
    end

    -- example data:
    -- 'yazi 0.2.4 (411ba2f 2024-03-15)'
    local raw_version = vim.fn.system('yazi --version')

    -- parse the version

    local semver = raw_version:match('^[Yy]azi (%w+%.%w+%.%w+)')

    if semver == nil then
      vim.health.warn('yazi --version looks unexpected, saw ' .. raw_version)
    end

    local checker = require('vim.version')
    if not checker.gt(semver, '0.2.4') then
      return vim.health.warn(
        'yazi version is too old, please upgrade to 0.2.5 or newer'
      )
    end

    local yazi_help = vim.fn.system('yazi --help')
    if not yazi_help:find('--local-events', 1, true) then
      vim.health.warn(
        'The yazi version does not support --local-events. Please upgrade to the newest version of yazi.'
      )
    end

    vim.health.ok('yazi')
  end,
}
