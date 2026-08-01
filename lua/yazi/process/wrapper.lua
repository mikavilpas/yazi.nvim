-- lua/yazi/process/wrapper.lua
local uv = vim.uv or vim.loop
local port = tonumber(arg[1])
local yazi_exe = arg[2]
local yazi_args = {}
for i = 3, #arg do table.insert(yazi_args, arg[i]) end

local socket = uv.new_tcp()
socket:connect("127.0.0.1", port, function(err)
    if err then os.exit(1) end
    local stdout_pipe = uv.new_pipe(false)
    local handle, _ = uv.spawn(yazi_exe, {
        args = yazi_args,
        stdio = { 0, stdout_pipe, 2 }
    }, function(code)
        socket:close()
        os.exit(code)
    end)
    if not handle then os.exit(1) end
    stdout_pipe:read_start(function(_, data)
        if data then socket:write(data) end
    end)
end)
uv.run()