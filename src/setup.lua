-- Setup script.
-- For pre-loading the modules.

-- grab globals
local os = os
local io = io

-- hack, to allow running outside of awesome wm.
awesome = {
    connect_signal = function(...) end;
    conffile = (
        os.getenv("XDG_CONFIG_HOME") or
        (os.getenv('HOME') .. '/.config')) .. '/awesome/rc.conf'
}

local asetup = require "awesome-setup"

local res = asetup.setup_modules(nil, true)
if not res.ok then
    print("Module loading issues: " .. res.err)
else
    print("Loaded modules without issue")
end
