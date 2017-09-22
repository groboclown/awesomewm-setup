--

-- grab globals
local pairs = pairs
local os = os
local io = io

local __here = (...):match("(.-)[^%.]+$")
local env = require(__here .. 'env')

-- module definition

local r = {
    _source = {
        redflat = {
            loader = "git";
            url = "https://github.com/worron/redflat.git";
            into = "worron.redflat.github.d";
            luadir = ".";
            sodir = nil;
            themedir = nil;
            version = "HEAD";
            depends = {};
        };
        radical = {
            loader = "git";
            url = "https://github.com/Elv13/radical.git";
            into = "Elv13.radical.github.d";
            luadir = ".";
            sodir = nil;
            themedir = nil;
            version = "HEAD";
            depends = {};
        };
        poppin = {
            loader = "git";
            url = "https://github.com/raksooo/poppin.git";
            into = "raksooo.poppin.github.d";
            luadir = ".";
            sodir = nil;
            themedir = nil;
            version = "HEAD";
            depends = {};
        };
        awesome_config = {
            loader = "git";
            url = "https://github.com/worron/awesome-config.git";
            into = "worron.awesome-config.github.d";
            luadir = ".";
            sodir = nil;
            themedir = nil;
            version = "HEAD";
            depends = {};
        };
        connman_widget = {
            loader = "rock";
            rock = "connman_widget";
            into = "connman_widget.rock.d";
            themedir = "themes";
            depends = {};
        };
    };
}
r._source["worron.redflat"] = { alias = "redflat"; }
r._source["awesome-config"] = { alias = "awesome_config"; }
r._source["worron.awesome-config"] = { alias = "awesome_config"; }
r._source["Elv13.radical"] = { alias = "radical"; }
r._source["raksooo.poppin"] = { alias = "poppin"; }
r._source["connman-widget"] = { alias = "connman_widget"; }



local loaders = require(__here .. 'loaders')


local function _split_path(path)
   local ret={}
   path:gsub("([^;]*)", function(c) ret[#ret+1] = c end)
   return ret
end

local function _add_unique_value(list, value)
    for _,v in pairs(list) do
        if v == vv then
            return list
        end
    end
    table.insert(list, value)
    return list
end

local function _add_unique(list_a, list_b)
    for _,v in pairs(list_b) do
        _add_unique_value(list_a, v)
    end
    return list_a
end


function r.update_lua_path(module_def, repo_dir)
    local loader = loaders[module_def.loader]
    if loader ~= nil then
        local lp = loader.lpath(module_def, repo_dir)
        if lp ~= nil then
            -- split the path and add in the parts that don't already exist
            lp = _add_unique(_split_path(package.path), lp)
            package.path = table.concat(lp, ";")
        end
        local cp = loader.cpath(module_def, repo_dir)
        if cp ~= nil then
            -- split the path and add in the parts that don't already exist
            cp = _add_unique(_split_path(package.cpath), cp)
            package.cpath = table.concat(cp, ";")
        end
    end
end



-- Process a specific module definition into the given repo directory.
function r.process(module_def, repo_dir, force_load)
    if not force_load and env.is_dir(repo_dir .. '/' .. module_def.into) then
        return { ok = true; err = "path already exists"; }
    end
    local loader = loaders[module_def.loader]
    local results = loader.fetch(module_def, repo_dir)
    if not results.ok then
        return results
    end
    -- FIXME do something with the theme?
    return { ok = true; }
end




local function _merge_mods(tgt, src)
    -- start the error at some high-ish number
    local error_count = 10
    while tgt["err" .. error_count] ~= nil do
        error_count = error_count + 1
    end
    for k,v in pairs(src) do
        if k:match("err%d+") then
            tgt["err" .. error_count] = v
            error_count = error_count + 1
        elseif tgt[k] == nil then
            tgt[k] = v
        end
        -- else it's already been added
    end
end



local function _load_module_definitions(module_table, existing)
    local ret = existing
    local err_count = 0
    for k, v in pairs(module_table) do
        local m
        if type(k) == "number" and type(v) == "string" then
            m = r._load_module_ref(v)
        elseif type(k) == "string" and type(v) == "table" then
            m = r._load_module_def(k, v)
        else
            local key = "error" .. err_count
            err_count = err_count + 1
            ret[key] = { ok = false; err = "bad module definition " .. k .. " => " .. v; }
        end
        if m ~= nil and m.ok and ret[m.into] == nil then
            if existing[m.into] == nil then
                ret[m.into] = m
                if m.depends ~= nil then
                    -- Note: there's a small chance for infinite recursion here.
                    _merge_mods(ret, r.load_module_definitions(m.depends, ret))
                end
            end
            -- else it was loaded earlier, so don't repeat ourselves
        elseif m ~= nil and not m.ok then
            ret['err' .. err_count] = m
            err_count = err_count + 1
        end
    end
    return ret
end



-- Load the module definitions given from the input.  The definitions in the
-- argument can either be a list of the names in r._source, or a complete
-- module source definition.
function r.load_module_definitions(module_table)
    return _load_module_definitions(module_table, {})
end



function r._load_module_ref(name, displayname)
    local ret = {}
    if r._source[name] ~= nil then
        ret = r._load_module_def(displayname, r._source[name])
    else
        ret.ok = false
        ret.err = 'unknown module ' .. displayname
    end
    return ret
end


local function _global_moddef_validation(name, moddef)
    if type(moddef.into) ~= "string" then
        return { ok = false; err = name .. ": no 'into' value"}
    end
    return { ok = true; }
end


function r._load_module_def(name, moddef)
    local ret = {}
    if moddef == nil then
        ret.ok = false
        ret.err = "bad module format for " .. name
    elseif moddef.alias ~= nil then
        -- TODO escape '%' in alias.
        if name:match('>' .. moddef.alias .. '>') ~= nil then
            ret.ok = false
            ret.err = 'Alias module self-reference: ' .. name .. '>' .. moddef.alias
        else
            ret = r._load_module_ref(moddef.alias, name .. '>' .. moddef.alias)
        end
    elseif moddef.loader == nil or type(moddef.loader) ~= "string" then
        ret.ok = false
        ret.err = "Invalid module format for " .. name .. ": " .. moddef
    elseif loaders[moddef.loader] == nil then
        ret.ok = false
        ret.err = "Invalid module format for " .. name .. ": " .. moddef
    else
        -- Global validation
        local valid = _global_moddef_validation(name, moddef)
        if not valid.ok then
            ret = valid
        else
            -- Loader-specific validation
            valid = loaders[moddef.loader].validate(moddef)
            if valid.ok then
                for k,v in pairs(moddef) do
                    ret[k] = v
                end
                ret.ok = true
                ret.err = nil
            else
                ret = valid
            end
        end
    end
    return ret
end

return r
