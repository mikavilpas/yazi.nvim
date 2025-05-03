local retry = {}

---@class yazi.RetryParams
---@field action fun(retries_remaining: integer): unknown # the action to retry. Raises an error if the retry fails
---@field retries integer # number of retries to attempt if the action fails
---@field delay integer # delay in ms before retrying
---@field on_failure fun(fail_result: unknown, retries_remaining: integer) # called when a poll fails
---@field on_final_failure fun(fail_result: unknown) # called when all retries fail, before exiting

---@async
---@param params yazi.RetryParams
function retry.retry(params)
  local retries_remaining = params.retries
  local function try()
    local success, result = pcall(params.action, retries_remaining)

    if not success then
      retries_remaining = retries_remaining - 1
      if retries_remaining == 0 then
        params.on_final_failure(result)
        return
      end

      params.on_failure(result, retries_remaining)
      vim.defer_fn(try, params.delay)
    end
  end

  try()
end

return retry
