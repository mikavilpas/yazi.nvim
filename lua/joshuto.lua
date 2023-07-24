-- local cmd = string.format('joshuto --file-chooser --output-file %s %s', output_path, current_directory)

local open_floating_window = require("joshuto.window").open_floating_window
local project_root_dir = require("joshuto.utils").project_root_dir
local get_root = require("joshuto.utils").get_root
local is_joshuto_available = require("joshuto.utils").is_joshuto_available
local is_symlink = require("joshuto.utils").is_symlink

JOSHUTO_BUFFER = nil
JOSHUTO_LOADED = false
vim.g.joshuto_opened = 0
local prev_win = -1
local win = -1
local buffer = -1

local output_path = "/tmp/joshuto_filechosen"

local function on_exit(job_id, code, event)
	if code ~= 0 and code ~= 102 then
		return
	end

	JOSHUTO_BUFFER = nil
	JOSHUTO_LOADED = false
	vim.g.joshuto_opened = 0
	vim.cmd("silent! :checktime")

	if vim.api.nvim_win_is_valid(prev_win) then
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_set_current_win(prev_win)
		if code == 102 then
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

--- Call joshuto
local function exec_joshuto_command(cmd)
	-- print(cmd)
	if JOSHUTO_LOADED == false then
		-- ensure that the buffer is closed on exit
		vim.g.joshuto_opened = 1
		vim.fn.termopen(cmd, { on_exit = on_exit })
	end
	vim.cmd("startinsert")
end

--- :Joshuto entry point
local function joshuto(path)
	if is_joshuto_available() ~= true then
		print("Please install joshuto. Check documentation for more information")
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
	local cmd = string.format('joshuto --file-chooser --output-file "%s" "%s"', output_path, path)

	exec_joshuto_command(cmd)
end

return {
	joshuto = joshuto,
}
