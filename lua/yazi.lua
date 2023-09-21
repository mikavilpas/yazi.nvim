-- local cmd = string.format('yazi --file-chooser --output-file %s %s', output_path, current_directory)

local open_floating_window = require("yazi.window").open_floating_window
local project_root_dir = require("yazi.utils").project_root_dir
local get_root = require("yazi.utils").get_root
local is_yazi_available = require("yazi.utils").is_yazi_available
local is_symlink = require("yazi.utils").is_symlink

YAZI_BUFFER = nil
YAZI_LOADED = false
vim.g.yazi_opened = 0
local prev_win = -1
local win = -1
local buffer = -1

local output_path = "/tmp/yazi_filechosen"

local function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end

local function on_exit(job_id, code, event)
	if code ~= 0 then
		return
	end
	
	-- test
	-- local file=io.open("/tmp/test.txt","w+")
	-- io.output(file)
	-- io.write(code)
	-- io.close()

	YAZI_BUFFER = nil
	YAZI_LOADED = false
	vim.g.yazi_opened = 0
	vim.cmd("silent! :checktime")

	if vim.api.nvim_win_is_valid(prev_win) then
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_set_current_win(prev_win)
		if code == 0 and file_exists(output_path) == true then
			local chosen_file = vim.fn.readfile(output_path)[1]
			if chosen_file then
				vim.cmd(string.format('edit %s', chosen_file))
			end
		end
		prev_win = -1
		if vim.api.nvim_buf_is_valid(buffer) and vim.api.nvim_buf_is_loaded(buffer) then
			vim.api.nvim_buf_delete(buffer, { force = true })
		end
		buffer = -1
		win = -1
	end
end

--- Call yazi
local function exec_yazi_command(cmd)
	-- print(cmd)
	if YAZI_LOADED == false then
		-- ensure that the buffer is closed on exit
		vim.g.yazi_opened = 1
		vim.fn.termopen(cmd, { on_exit = on_exit })
	end
	vim.cmd("startinsert")
end

--- :Yazi entry point
local function yazi(path)
	if is_yazi_available() ~= true then
		print("Please install yazi. Check documentation for more information")
		return
	end

	prev_win = vim.api.nvim_get_current_win()
	path = vim.fn.expand('%:p:h')

	win, buffer = open_floating_window()

	_ = project_root_dir()

	-- if path == nil then
	-- 	if is_symlink() then
	-- 		path = project_root_dir()
	-- 	else
	-- 	end
	-- end

	os.remove(output_path)
	local cmd = string.format('yazi "%s" --chooser-file "%s"', path, output_path)

	exec_yazi_command(cmd)
end

return {
	yazi = yazi,
}
