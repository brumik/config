#!/usr/bin/env zsh
# add our local functions dir to the fpath
local funcs=$HOME/.zsh/functions

# FPATH is already tied to fpath, but this adds
# a uniqueness constraint to prevent duplicate entries
typeset -TUg +x FPATH=$funcs:$FPATH fpath

# Now autoload them
if [[ -d $funcs ]]; then
    autoload ${=$(cd "$funcs" && echo *)}
fi
