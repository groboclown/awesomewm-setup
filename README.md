# awesomewm-setup

Simple library to get a basic Awesome WM environment ready for customization.

It automatically pulls in depedencies based on a simple configuration setup,
eliminating the search for dependencies.

It also allows for an easy setup of common values inside a single configuration
file.

## The Quick Start Guide

To get running quickly with the `awesomewm-setup` package, simply:

1. Install `awesomewm-setup` whereever you place such packages.  For example:
```bash
$ cd $HOME/dev
$ git clone https://github.com/groboclown/awesomewm-setup.git
```
2. Link the directory into your `$HOME/.config/awesome/` directory (or
   `$XDG_CONFIG_HOME/awesome` if you set that to a custom location).
```bash
$ cd $XDG_CONFIG_HOME/awesome
$ ln -s $HOME/dev/awesomewm-setup/ .
```
3. Create a configuration file in `$XDG_CONFIG_HOME/awesome/config.lua`:
```lua
return {
    logfile = '/tmp/awesome.log';
    modules = {
        'redflat', 'connman_widget'
    };
}
```
    A full list of available modules is [listed below](#modules).
4. Update your awesome `rc.lua` file to load the configuration, modules,
    and simple error handlers:
```lua
config = require "awesome-setup".setup()
```

## Usage



### Modules

`awesomewm-setup` provides a list of default modules that can be installed
by referencing their alias.  These are found in
[modules.lua](src/awesome-setup/modules.lua).

You can reference these modules in your configuration file by listing them
in the `modules` key:

```lua
modules = { 'redflat', 'connman_widget' };
```

If you have another module you'd like to add, you can specify the complete
module definition instead.

```lua
modules = {
    'connman_widget';
    redflat = {
        loader = "git";
        url = "https://github.com/worron/redflat.git";
        into = "worron.redflat.github.d";
        luadir = ".";
        sodir = nil;
        themedir = nil;
        version = "HEAD";
        depends = {};
    };
}
```

Modules are installed into the `$XDG_CONFIG_HOME/awesome/lib-repo` directory,
and dynamically added into the Lua path.
