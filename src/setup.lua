-- Setup script.
-- For pre-loading the modules.

-- grab globals
local os = os
local io = io
local asetup = require "awesome-setup"

local res = asetup.setup_modules(nil, true)
if not res.ok then
    print("Module loading issues: " .. res.err)
else
    print("Loaded modules without issue")
end
