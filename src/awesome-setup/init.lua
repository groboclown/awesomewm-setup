
-- init.lua references the current module path differently.
local __here = (...) .. '.'

local ret = {
    _version = '0.1.0';
    config_loader = require(__here .. "config-loader");
    env = require(__here .. "env");
    error_handler = require(__here .. "error-handler");
}

ret.setup = function()
    ret.config = ret.config_loader.load_config()
    ret.config_loader.setup_modules(ret.config)
    ret.error_handler.setup_error_handlers(ret.config)
    return ret.config
end

ret.load_config = ret.config_loader.load_config
ret.setup_modules = ret.config_loader.setup_modules
ret.setup_error_handlers = ret.error_handler.setup_error_handlers

return ret
