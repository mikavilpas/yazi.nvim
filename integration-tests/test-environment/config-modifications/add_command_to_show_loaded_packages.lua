-- selene: allow(unused_variable)
function Yazi_show_loaded_packages(path)
  local modules = {}
  for k, _ in pairs(package.loaded) do
    if k:sub(1, 4) == "yazi" then
      table.insert(modules, k)
    end
  end
  table.sort(modules)

  return modules
end

print("Yazi: Loaded custom command to show loaded packages.")
