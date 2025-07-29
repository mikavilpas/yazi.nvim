--- @since 25.6.11
--- @sync entry

return {
  setup = function()
    -- currently this needs a nightly feature to work,
    --
    -- feat: key-* DDS events to allow canceling user key commands #3005
    -- https://github.com/sxyazi/yazi/pull/3005
    ps.sub("key-quit", function()
      ps.pub_to(0, "KeyEvent", {
        key = "key-quit",
        cwd = cx.active.current.cwd,
      })
    end)
  end,
}
