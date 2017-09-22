--

local pcall = pcall
local io = io
local os = os

local mod = {}

function mod.get_config_dir()
    -- This should use the "gears.get_configuration_dir()"
    -- function, but that may not be available.
    local status, gears = pcall(require, "gears")
    if status then
        return gears.get_configuration_dir()
    end
    
    local confdir = os.getenv("XDG_CONFIG_HOME")
    if confdir == nil then
        confdir = os.getenv("HOME") .. "/.config"
    end
    return confdir .. '/awesome'
end

--- Check if a file or directory exists in this path
local function path_exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok
end

--- Check if a directory (or symlink to dir) exists in this path
function mod.is_dir(path)
   -- "/" works on both Unix and Windows
   return path_exists(path.."/")
end

-- Check if a file (or symlink to file) exists in this path
function mod.is_file(path)
    return path_exists(path) and not is_dir(path)
end


function mod.symlink(fromfile, tofile)
    -- TODO escape the ' marks in the names.
    local handle = io.popen("ln -s '" ..fromfile .. "' '" .. tofile .. "'")
    handle:close()
end

return mod
