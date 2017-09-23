
-- init.lua references the current module path differently.
local __here = (...) .. '.'

local ret = {
    _version = '0.1.0';
    config = require(__here .. "config");
    env = require(__here .. "env");
    error_handler = require(__here .. "error-handler");
}

ret.error_handler._config_module = ret.config
ret.load_config = ret.config.load_config
ret.setup_modules = ret.config.setup_modules
ret.setup_error_handlers = ret.error_handler.setup_error_handlers

return ret
