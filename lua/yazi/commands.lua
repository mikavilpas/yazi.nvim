local M = {}

function M.create_yazi_commands()
  local subcommand_tbl = {
    cwd = {
      impl = function()
        require("yazi").yazi(nil, vim.fn.getcwd())
      end,
    },
    toggle = {
      impl = function()
        require("yazi").toggle()
      end,
    },
  }

  ---@param opts table :h lua-guide-commands-create
  local function yazi_cmd(opts)
    -- Default action of :Yazi without subcommands
    if #opts.fargs == 0 then
      require("yazi").yazi()
      return
    end

    -- Get subcommand
    local subcommand_key = opts.fargs[1]
    local subcommand = subcommand_tbl[subcommand_key]

    -- If the user pass an non existing subcommand
    if not subcommand then
      vim.notify(
        "`:Yazi "
          .. subcommand_key
          .. "` command does not exist."
          .. "\nUse any of the next instead:"
          .. "\n  * `:Yazi`"
          .. "\n  * `:Yazi cwd`"
          .. "\n  * `:Yazi toggle`",
        vim.log.levels.ERROR,
        { title = "Yazi.nvim" }
      )
      return
    end
    -- Run sub-command
    subcommand.impl()
  end

  vim.api.nvim_create_user_command("Yazi", yazi_cmd, {
    nargs = "*", -- Allow no arguments or multiple arguments
    desc = "Valid yazi commands are `Yazi`, `Yazi cwd`, `Yazi toggle`",
    complete = function(arg_lead, cmdline, _)
      -- Get the subcommand.
      local subcmd_key, subcmd_arg_lead =
        cmdline:match("^['<,'>]*Yazi[!]*%s(%S+)%s(.*)$")
      if
        subcmd_key
        and subcmd_arg_lead
        and subcommand_tbl[subcmd_key]
        and subcommand_tbl[subcmd_key].complete
      then
        -- The subcommand has completions, return them
        return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
      end
      -- Check if cmdline is a subcommand
      if cmdline:match("^['<,'>]*Yazi[!]*%s+%w*$") then
        -- Filter subcommands that match
        local subcommand_keys = vim.tbl_keys(subcommand_tbl)
        return vim
          .iter(subcommand_keys)
          :filter(function(key)
            return key:find(arg_lead) ~= nil
          end)
          :totable()
      end
    end,
    bang = true, -- If you want to support ! modifiers
  })
end

return M
