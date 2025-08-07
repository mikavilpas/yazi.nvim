-- NOTE this file is part of public documentation, remember to keep all changes
-- in sync

-- Example: when using the `copy_relative_path_to_selected_files` key (default
-- <c-y>) in yazi, change the way the relative path is resolved.
require("yazi").setup({
  integrations = {
    resolve_relative_path_implementation = function(args, get_relative_path)
      -- By default, the path is resolved from the file/dir yazi was focused on
      -- when it was opened. Here, we change it to resolve the path from
      -- Neovim's current working directory (cwd) to the target_file.
      local cwd = vim.fn.getcwd()
      local path = get_relative_path({
        selected_file = args.selected_file,
        source_dir = cwd,
      })
      return path
    end,
  },
})
