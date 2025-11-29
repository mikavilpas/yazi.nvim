require("yazi").setup({
  ---@diagnostic disable-next-line: missing-fields
  hooks = {
    before_opening_window = function(options)
      options.col = vim.o.columns
      options.row = vim.o.lines
      options.height = math.floor(vim.o.lines / 2)
      options.width = math.floor(vim.o.columns * 0.8)
    end,
  },
})
