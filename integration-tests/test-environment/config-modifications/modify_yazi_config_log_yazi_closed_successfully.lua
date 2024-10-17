---@module "yazi"

require("yazi").setup(
  ---@type YaziConfig
  {
    ---@diagnostic disable-next-line: missing-fields
    hooks = {
      yazi_closed_successfully = function(chosen_file, _, state)
        -- selene: allow(mixed_table)
        vim.notify(vim.inspect({
          "yazi_closed_successfully hook",
          chosen_file = chosen_file,
          last_directory = state.last_directory
            and state.last_directory:normalize(vim.uv.cwd()),
        }))
      end,
    },
  }
)
