local M = {}

--
function M.setup_copy_relative_path_picker_action()
  local snacks_picker = require("snacks.picker")

  local yazi_copy_relative_path = "yazi_copy_relative_path"
  if snacks_picker.actions[yazi_copy_relative_path] then
    require("yazi.log"):debug(
      string.format(
        "snacks.picker already has the key '%s'. Not overriding it.",
        yazi_copy_relative_path
      )
    )
    return
  end

  ---@param picker snacks.Picker
  snacks_picker.actions[yazi_copy_relative_path] = function(picker)
    local Log = require("yazi.log")
    local config = require("yazi").config
    assert(
      config.clipboard_register,
      "clipboard_register is nil, cannot copy to it"
    )
    assert(
      config.integrations.resolve_relative_path_application,
      "resolve_relative_path_application is nil, cannot copy with it"
    )

    local current_file_dir = vim.fn.expand("#:p:h")
    if current_file_dir == nil then
      error("no current_file_dir, cannot do anything")
    end
    local cwd = picker.finder.filter.cwd
    assert(cwd, "cwd is nil")

    local selected_files = picker:selected({ fallback = true })

    ---@type string[]
    local relative_paths = {}
    for _, selected_file in ipairs(selected_files) do
      local full_path = vim.fs.joinpath(cwd, assert(selected_file.file))
      local relative_path = require("yazi.utils").relative_path(
        config.integrations.resolve_relative_path_application,
        current_file_dir,
        full_path
      )
      table.insert(relative_paths, relative_path)
    end
    local text = table.concat(relative_paths, "\n")

    vim.fn.setreg(config.clipboard_register, text)

    Log:debug(
      string.format(
        "Copied relative paths to the register '%s': %s",
        config.clipboard_register,
        vim.inspect(relative_paths)
      )
    )

    picker:close()
  end
end

return M
