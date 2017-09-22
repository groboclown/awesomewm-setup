--
-- Loaders must provide these methods:

-- fetch(module_config, repo_dir)
--      return { ok = <boolean>; err=nil/<string> }
-- validate(module_config)
--      return { ok = <boolean>; err=nil/<string> }
-- lpath(module_config, repo_dir)
--      creates the lua path for this one module.
--      return string array
-- cpath(module_config, repo_dir)
--      creates the so path for this one module.
--      return string array

local __here = (...) .. '.'

return {
    git = require(__here .. "git");
    zip = require(__here .. "zip");
    rock = require(__here .. "rock");
}
