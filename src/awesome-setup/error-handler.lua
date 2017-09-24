--
-- Awesome startup and runtime error handlers.
--
-- Logs errors to the screen with "naughty", and to the log file.

local mod = {
    -- allows for access to the logger.
    log = nil;
}


-- Conditionally load "naughty" in case we've been loaded directly
-- from the CLI.
local nexist, naughty = pcall(require, "naughty")

local function log_error(...)
    if mod.log ~= nil then
        local depth = mod._config_module.log._logger_stack_depth
        mod._config_module.log._logger_stack_depth = 4
        mod._config_module.log.error(...)
        mod._config_module.log._logger_stack_depth = depth
    end
end


-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
function mod.check_startup_errors()
    if awesome.startup_errors then
        log_error("AwesomeWM Startup Errors:", awesome.startup_errors)
        naughty.notify{ preset = naughty.config.presets.critical;
                     title = "Oops, there were errors during startup!";
                     text = awesome.startup_errors }
    end
end

-- Handle runtime errors after startup
function mod.handle_runtime_errors()
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true
        
        log_error("AwesomeWM Runtime Error:", err)
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

function mod.setup_error_handlers(c)
    mod.log = c.log
    mod.check_startup_errors()
    mod.handle_runtime_errors()
end

return mod
