require("yazi")

-- selene: allow(unused_variable)
function CountYaziModules()
  ---@type string[]
  local yazi_modules = {}

  for k, _ in pairs(package.loaded) do
    if k:sub(1, 4) == "yazi" then
      yazi_modules[#yazi_modules + 1] = k
    end
  end

  return vim.inspect({
    string.format("Loaded %s modules", #yazi_modules),
    table.concat(yazi_modules, ","),
  })
end
