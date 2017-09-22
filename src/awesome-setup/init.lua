
-- init.lua references the current module path differently.
local __here = (...) .. '.'

local ret = {
    config = require(__here .. "config");
    env = require(__here .. "env");
}

ret.setup_modules = ret.config.setup_modules

return ret
