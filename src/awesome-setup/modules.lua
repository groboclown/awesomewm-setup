-- Default supported AwesomeWM modules.

return {
    redflat = {
        loader = "git";
        url = "https://github.com/worron/redflat.git";
        into = "worron.redflat.github.d/redflat";
        luadir = "..";
        sodir = nil;
        themedir = nil;
        version = "HEAD";
        depends = {};
    };
    radical = {
        loader = "git";
        url = "https://github.com/Elv13/radical.git";
        into = "Elv13.radical.github.d/radical";
        luadir = "..";
        sodir = nil;
        themedir = nil;
        version = "HEAD";
        depends = {};
    };
    poppin = {
        loader = "git";
        url = "https://github.com/raksooo/poppin.git";
        into = "raksooo.poppin.github.d/poppin";
        luadir = "..";
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
    
    -- awesome-config is more of an example layout, rather than a library.
    -- However, parts of it can be included.
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
};
