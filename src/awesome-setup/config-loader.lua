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
local mod = {}


function mod.setup_modules(c, force_load)
    if c == nil then
        c = mod.load_config()
    end
    if c.ok then
        return mod.load_modules(c, force_load)
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
    if c.logui ~= nil then
        c.log.ui = c.logui
    end
    return c
end


local function _read_config(requires_filename)
    -- Check if the configuration file exists
    requires_filename = requires_filename or (env.get_config_dir() .. "config.lua")
    if env.is_file(requires_filename) then
        -- print("Loading configuration from " .. requires_filename)
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
        -- print("No configuration " .. requires_filename)
        return {
            ok = true;
            status = "default config; no such file " .. requires_filename;
            err = nil;
        }
    end
end

-- Public Module functions
function mod.load_config(c)
    if c == nil or type(c) == 'string' then
        c = _read_config(c)
    end
    return _populate_default_config_values(c)
end


function mod.load_modules(c, force_load)
    if c.ok and c.modules ~= nil and #c.modules > 0 and c.repo_dir ~= nil then
        local module_defs = repo.load_module_definitions(c.modules)
        local ret = { ok = true; err = nil; }
        local errors = ''
        for k,v in pairs(module_defs) do
            if c.log ~= nil then
                c.log.info("Processing module " .. k)
            end
            if not v.ok then
                errors = errors .. '\n * ' .. k .. ' (definition issue): ' .. v.err
            else
                local result = repo.process(v, c.repo_dir, force_load)
                if result.ok then
                    repo.update_lua_path(v, c.repo_dir)
                    if c.log ~= nil then
                        c.log.info("Loaded module " .. k)
                    end
                else
                    errors = errors .. '\n * ' .. k .. ': ' .. result.err
                    if c.log ~= nil then
                        c.log.info("Failed to load module " .. k .. ": " .. result.err)
                    end
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


return mod
