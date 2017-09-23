-- Setup script.
-- Can be run either from the command-line or from within an rc.lua script.

-- grab globals
local os = os
local io = io
local pcall = pcall
local pairs = pairs

-- Load libraries
local __here = (...):match("(.-)[^%.]+$")
local env = require(__here .. "env")
local repo = require(__here .. "repo")
local log = require(__here .. 'log')

-- Setup our module
local config = {}


function config.setup_modules(c, force_load)
    if c == nil then
        c = config.load_config()
    end
    if c.ok then
        return config.load_modules(c, force_load)
    else
        return c 
    end
end


local function _populate_default_config_values(c)
    if c.repo_dir == nil then
        c.repo_dir = env.get_config_dir() .. "/lib-repo/"
    end
    if c.modules == nil then
        c.modules = {}
    end
    c.log = log
    if c.logfile ~= nil then
        c.log.logfile = c.logfile
    end
    return c
end


local function _read_config()
    local confdir = env.get_config_dir()
    
    -- Check if the configuration file exists
    local requires_filename = confdir .. "/modules.lua"
    local f = io.open(requires_filename, "r")
    if f ~= nil then
        io.close(f)
        local status, value = pcall(dofile, requires_filename)
        if status then
            if type(value) ~= "table" then
                return {
                    ok = false;
                    status = "config did not return a table: " .. requires_filename;
                    err = "did not return a table";
                }
            end
            value.ok = true
            value.status = "loaded from " .. requires_filename
            value.err = nil
            return value
        else
            return {
                ok = false;
                status = "error loading from " .. requires_filename;
                err = value or ("error loading from " .. requires_filename);
            }
        end
    else
        -- No configuration
        return {
            ok = true;
            status = "default config; no such file " .. requires_filename;
            err = nil;
        }
    end
end

-- Public Module functions
function config.load_config()
    local c = _populate_default_config_values(_read_config())
    config.last = c
    return c
end


function config.load_modules(c, force_load)
    if c.ok and c.modules ~= nil and #c.modules > 0 and c.repo_dir ~= nil then
        print("loading module definitions")
        local module_defs = repo.load_module_definitions(c.modules)
        local ret = { ok = true; err = nil; }
        local errors = ''
        for k,v in pairs(module_defs) do
            print("Processing module " .. k)
            if not v.ok then
                errors = errors .. '\n * ' .. k .. ' (definition issue): ' .. v.err
            else
                local result = repo.process(v, c.repo_dir, force_load)
                if result.ok then
                    repo.update_lua_path(v, c.repo_dir)
                    print("Loaded module " .. k)
                else
                    errors = errors .. '\n * ' .. k .. ': ' .. result.err
                    print("Failed to load module " .. k .. ": " .. result.err)
                end
            end
        end
        if #errors > 0 then
            ret.ok = false
            ret.err = errors
        end
        return ret
    else
        return { ok = true; }
    end
end


return config