--- @since 25.5.31

--- nvim.yazi is a companion plugin for yazi.nvim that enables neovim related
--- functionality. This is needed because some features are so complex that neovim
--- cannot implement them directly (yazi internal state is needed).
---
return {
  setup = function()
    require(".notify").guard("failed to add status indicator", function()
      require(".status").setup()
    end)

    -- The dynamic keymap API was merged in
    -- https://github.com/sxyazi/yazi/pull/4031 (merged 2026-06). On older yazi
    -- it's absent; do nothing so yazi.nvim can fall back.
    if km == nil then
      -- This can be moved to the @since annotation once yazi is released with
      -- the dynamic keymap API.
      ya.dbg("nvim.yazi: `km` API unavailable, not registering keymaps")
      return
    end

    require(".notify").guard("failed to register keymaps", function()
      local keymaps = require(".keymaps")
      local mappings =
        keymaps.parse_from_env(os.getenv("YAZI_NVIM_PLUGIN_KEYMAPS") or "")
      keymaps.register(mappings)
    end)
  end,

  ---@param job { args: string[] }
  entry = function(_, job)
    if os.getenv("YAZI_NVIM_ID") == nil then
      require(".notify").error("nvim.yazi can only be used from yazi.nvim")
      return
    end

    local action = job.args[1]
    if not action then
      return
    end

    require(".notify").guard(
      string.format("failed to handle keymap action '%s'", action),
      function()
        require(".publish").keymap_event(action)
      end
    )
  end,
}
