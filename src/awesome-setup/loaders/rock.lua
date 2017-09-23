--


local r = {}


function r.fetch(module_config, repo_dir)
    -- luarocks install --tree repo_dir module_config.rock
    local cmd = ('luarocks install --tree "' ..
        repo_dir .. '/' .. module_config.into .. '" ' ..
        module_config.rock)
    local status, err = os.execute(cmd)
    if not status then
        print("Failed " .. err)
        return { ok = false; err = err; }
    end
    return { ok = true; }
end

function r.validate(module_config)
    -- module-specific check
    if type(module_config.rock) ~= "string" then
        return { ok = false; err = "module must define 'rock' name"; }
    end
    
    
    -- System level check
    local w = io.popen("which git >/dev/null 2>&1 ; echo -n $?")
    local exit_code = w:read('*all')
    if exit_code ~= "0" then
        return { ok = false; err = "luarocks could not be found in your PATH"; }
    end
    
    return { ok = true }
end

function r.lpath(module_config, repo_dir)
    local version = _VERSION:match("%d+%.%d+")
    local module_dir = repo_dir .. '/' .. module_config.into
    return {
        (module_dir .. '/share/lua/' .. version .. '/?.lua');
        (module_dir .. '/share/lua/' .. version .. '/?/init.lua');
    }
end

function r.cpath(module_config, repo_dir)
    local version = _VERSION:match("%d+%.%d+")
    local module_dir = repo_dir .. '/' .. module_config.into
    return { (module_dir .. '/lib/lua' .. version .. '/?.so'); }
end



return r

