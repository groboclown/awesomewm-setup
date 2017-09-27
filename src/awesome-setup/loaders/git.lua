--

local io = io
local env = require 'awesome-setup.env'

local r = {}



function r.fetch(module_config, repo_dir)
    -- TODO let ".version" actually do something
    local cmd
    local git_dir = repo_dir .. module_config.into
    if env.is_dir(git_dir .. '/.git') then
        -- Update the git directory
        cmd = ("cd " .. git_dir ..
            " && git pull")
    else
        -- clone the git
        cmd = ("mkdir -p "  .. repo_dir ..
            " && cd " .. repo_dir ..
            " && git clone " .. module_config.url .. " " .. module_config.into)
    end
    local status, err = os.execute(cmd)
    if not status then
        print("Failed " .. err)
        return { ok = false; err = err; }
    end
    if module_config.version ~= nil then
        cmd = ("cd " .. git_dir ..
            " && git checkout " .. module_config.version)
        status, err = os.execute(cmd)
        if not status then
            print("Failed " .. err)
            return { ok = false; err = err; }
        end
    end
    return { ok = true; }
end


function r.validate(module_config)
    -- module-specific check
    if type(module_config.url) ~= "string" then
        return { ok = false; err = "no 'url' value"; }
    end
    if module_config.luadir ~= nil and type(module_config.luadir) ~= "string" then
        return { ok = false; err = "invalid 'luadir' value"; }
    end
    if module_config.sodir ~= nil and type(module_config.sodir) ~= "string" then
        return { ok = false; err = "invalid 'sodir' value"; }
    end
    if module_config.version ~= nil and type(module_config.version) ~= "string" then
        return { ok = false; err = "invalid 'version' value"; }
    end
    
    -- System level check
    local w = io.popen("which git >/dev/null 2>&1 ; echo -n $?")
    local exit_code = w:read('*all')
    if exit_code ~= "0" then
        return { ok = false; err = "git could not be found in your PATH (" .. exit_code .. ")"; }
    end
    
    return { ok = true }
end


function r.lpath(module_config, repo_dir)
    if module_config.luadir ~= nil then
        return {
            (repo_dir .. '/' .. module_config.into .. '/' .. module_config.luadir .. '/?/init.lua'),
            (repo_dir .. '/' .. module_config.into .. '/' .. module_config.luadir .. '/?.lua'),
        }
    end
    return {}
end


function r.cpath(module_config, repo_dir)
    if module_config.sodir ~= nil then
        return { (repo_dir .. '/' .. module_config.into .. '/' .. module_config.sodir); }
    end
    return {}
end


return r
