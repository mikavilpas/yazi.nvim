vim.lsp.handlers["window/showMessageRequest"] = function(_, params)
  print("automatically accepting LSP message request")

  -- emmylua_ls sends a message request when renaming a file that the user is
  -- expected to confirm. This is tricky to confirm reliably, so we just accept
  -- it immediately.
  assert(params.actions[1].title == "Modify")
  -- selene: allow(global_usage)
  _G.YaziTestFileRenameConfirmations = (_G.YaziTestFileRenameConfirmations or 0)
    + 1

  return params.actions and params.actions[1] or vim.NIL
end
