#!/bin/sh

# Used for explicit setup of the configuration directory,
# rather than including it during setup.

cfgdir="$XDG_CONFIG_HOME"
if [ -z "$cfgdir" ]; then
    cfgdir="$HOME/.config"
fi

export LUA_PATH=";;/usr/share/awesome/lib/?.lua;/usr/share/awesome/lib/?/init.lua"
export LUA_CPATH=";;"

lua $(dirname $0)/setup.lua