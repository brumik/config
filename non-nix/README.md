# Config file

This config files hosts all the configuration files I can use on an Unix based system.

The goal is to keep unix based systems the same with the use of external non platform specific applications.

## How to use it

- Clone the repository
- Symlink the folders to the `.config` folder (full path)
    - Example: `ln -s ~/Documents/config/alacritty ~/.config` (to link alacritty)


Some programs needs extra setup (like alacritty needs fonts). These extra setup guides should be included in the 
README of that specific folder. 

## Neovim setup

Currently I have saved 2 neovim setups: the main one which is hand built and 
the NvChad version which is a small configuration upon the NvChad settigs.
The install instructions are here: https://nvchad.com/docs/quickstart/install

If using terminal `alacritty` then the nerd font should be installed there (see `alacritty/README`).
`ripgrep` is a rust application, installable on most systems.


