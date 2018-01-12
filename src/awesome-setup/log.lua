-- Simple logging library.

-- Taken somewhat from https://github.com/rxi/log.lua
-- which is Copyright (c) 2016 rxi
-- and released under the MIT license.

local tostring = tostring
local ipairs = ipairs

local levels = {
    { name = "trace"; color = "\27[34m"; display = "[TRACE "; },
    { name = "debug"; color = "\27[36m"; display = "[DEBUG "; },
    { name = "info";  color = "\27[32m"; display = "[ INFO "; },
    { name = "warn";  color = "\27[33m"; display = "[ WARN "; },
    { name = "error"; color = "\27[31m"; display = "[ERROR "; },
    { name = "fatal"; color = "\27[35m"; display = "[FATAL "; },
}

local log = {
    logfile = nil;
    console = false;
    ui = false;
    ui_level = 4;
    color = true;
    level = "trace";
    _logger_stack_depth = 2;
    
    -- TODO look at adding log rotation.
}

local function _round(x, inc)
    inc = inc or 1
    x = x / inc
    return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * inc
end

local function _tostring(...)
    local t = {}
    for i = 1, select('#', ...) do
        local x = select(i, ...)
        if type(x) == 'number' then
            -- show just a limited value for the number
            x = round(x, 0.001)
        end
        t[#t + 1] = tostring(x)
    end
    return table.concat(t, " ")
end

local level_index = {}

for i,c in ipairs(levels) do
    level_index[c.name] = i
    log[c.name] = function(...)
        if level_index[log.level] == nil or i < level_index[log.level] then
            -- early out if log level hides this message
            return
        end
        local msg = _tostring(...)
        local info = debug.getinfo(log._logger_stack_depth, "Sl")
        local src = info.short_src .. ';' .. info.currentline
        local now = os.date("%H:%M:%S")
        local nocolor = nil
        
        if log.console and log.color then
            print(string.format("%s%s%s]\27[0m %s: %s"),
                c.color, c.display, now, src, msg)
        elseif log.console then
            nocolor = string.format("%s%s] %s: %s",
                c.display, now, src, msg)
            print(nocolor)
        end
        if log.logfile then
            if nocolor == nil then
                nocolor = string.format("%s%s] %s: %s",
                    c.display, now, src, msg)
            end
            local fp = io.open(log.logfile, 'a')
            if fp ~= nil then
                fp:write(nocolor)
                fp:write("\n")
                fp:close()
            end
        end
        if log.ui or i >= log.ui_level then
            if nocolor == nil then
                nocolor = string.format("%s%s] %s: %s",
                    c.display, now, src, msg)
            end
            local naughty = require("naughty")
            naughty.notify{
                preset = naughty.config.presets.critical;
                title = "Log";
                text = nocolor
            }
        end
    end
end

return log
