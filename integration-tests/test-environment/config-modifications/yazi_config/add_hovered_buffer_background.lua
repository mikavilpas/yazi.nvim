---@module "yazi"

local macchiato = require("catppuccin.palettes.macchiato")

require("yazi").setup(
  ---@type YaziConfig
  {
    highlight_hovered_buffers_in_same_directory = false,
    highlight_groups = {
      -- https://catppuccin.com/palette
      hovered_buffer = { bg = macchiato.surface2 },
    },
  }
)
