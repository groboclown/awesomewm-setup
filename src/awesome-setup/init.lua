
-- init.lua references the current module path differently.
local __here = (...) .. '.'

local mod = {
    _version = '0.1.0';
    config_loader = require(__here .. "config-loader");
    env = require(__here .. "env");
    error_handler = require(__here .. "error-handler");
}

mod.setup = function(c)
    local r = mod.config_loader.load_config(c)
    if r.ok then
        mod.config_loader.setup_modules(r)
    end
    mod.error_handler.setup_error_handlers(r)
    return r
end

mod.load_config = mod.config_loader.load_config
mod.setup_modules = mod.config_loader.setup_modules
mod.setup_error_handlers = mod.error_handler.setup_error_handlers

return mod
