--

local pcall = pcall
local io = io
local os = os

local gears = require 'gears'

local mod = {}


function mod.get_config_dir()
    return gears.filesystem.get_configuration_dir()
end

--- Check if a file or directory exists in this path
local function path_exists(file)
    return gears.filesystem.file_readable(file) or gears.filesystem.is_dir(file)
end

--- Check if a directory (or symlink to dir) exists in this path
function mod.is_dir(path)
    return gears.filesystem.is_dir(path)
end

-- Check if a file (or symlink to file) exists in this path
function mod.is_file(path)
    return gears.filesystem.file_readable(path)
end


return mod
