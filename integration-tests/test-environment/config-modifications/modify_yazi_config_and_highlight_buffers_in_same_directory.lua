---@module "yazi"

local macchiato = require("catppuccin.palettes.macchiato")

require("yazi").setup(
  ---@type YaziConfig
  {
    highlight_hovered_buffers_in_same_directory = true,
    highlight_groups = {
      -- https://catppuccin.com/palette
      hovered_buffer = { bg = macchiato.surface2 },
      hovered_buffer_in_same_directory = { bg = macchiato.surface0 },
    },
  }
)
