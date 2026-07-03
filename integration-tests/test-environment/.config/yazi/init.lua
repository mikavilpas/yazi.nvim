if os.getenv("YAZI_NVIM_ID") ~= nil then
  -- load nvim.yazi only if running embedded within yazi.nvim
  local ok, nvim_plugin = pcall(require, "nvim")
  if ok then
    nvim_plugin:setup()
  end
end
