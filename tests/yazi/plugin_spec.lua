local assert = require('luassert')
local plugin = require('yazi.plugin')

describe('installing a plugin', function()
  local base_dir = os.tmpname() -- create a temporary file with a unique name

  before_each(function()
    -- convert the unique name from a file to a directory
    assert(base_dir:match('/tmp/'), 'Failed to create a temporary directory')
    os.remove(base_dir)
    vim.fn.mkdir(base_dir, 'p')
  end)

  after_each(function()
    vim.fn.delete(base_dir, 'rf')
  end)

  describe('installing a plugin', function()
    it('can install if everything goes well', function()
      local plugin_dir = vim.fs.joinpath(base_dir, 'test-plugin')
      local yazi_dir = vim.fs.joinpath(base_dir, 'fake-yazi-dir')

      vim.fn.mkdir(plugin_dir)
      vim.fn.mkdir(yazi_dir)
      vim.fn.mkdir(vim.fs.joinpath(yazi_dir, 'plugins'))

      plugin.build_plugin({
        dir = plugin_dir,
        name = 'test-plugin',
      }, { yazi_dir = yazi_dir })

      -- verify that the plugin was symlinked
      -- yazi_dir/plugins/test-plugin -> plugin_dir
      local symlink =
        vim.uv.fs_readlink(vim.fs.joinpath(yazi_dir, 'plugins', 'test-plugin'))

      assert.are.same(plugin_dir, symlink)
    end)

    it('warns the user if the plugin directory does not exist', function()
      local plugin_dir = vim.fs.joinpath(base_dir, 'test-plugin')
      local yazi_dir = vim.fs.joinpath(base_dir, 'fake-yazi-dir')
      vim.fn.mkdir(yazi_dir)

      local result = plugin.build_plugin({
        dir = plugin_dir,
        name = 'test-plugin-2',
      }, { yazi_dir = yazi_dir })

      assert.is_equal(
        result.error,
        'yazi plugin/flavor directory does not exist'
      )
      assert.is_equal(result.from, plugin_dir)
    end)
  end)

  describe('installing a flavor', function()
    it('can install if everything goes well', function()
      local flavor_dir = vim.fs.joinpath(base_dir, 'test-flavor')
      local yazi_dir = vim.fs.joinpath(base_dir, 'fake-yazi-dir')

      vim.fn.mkdir(flavor_dir)
      vim.fn.mkdir(yazi_dir)

      plugin.build_flavor({
        dir = flavor_dir,
        name = 'test-flavor',
      }, { yazi_dir = yazi_dir })

      local symlink =
        vim.uv.fs_readlink(vim.fs.joinpath(yazi_dir, 'flavors', 'test-flavor'))

      assert.are.same(flavor_dir, symlink)
    end)
  end)
end)
