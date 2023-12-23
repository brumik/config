# tmux config

Download to your system the newest tmux (3.3a current).

Then we need to clone the plugin manager:

`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

Now inside tmux press `<prefix> I` to install the pacakges and set it up

Basic shortcuts to use:
- `<C-b>` - `<prefix>`
- `<prefix> "` - vertical split plane
- `<prefix> %` - horizontal split plane
- `C-[h/j/k/l]` - navigate panes (as in neovim)
- `<prefix I>` - install packages with the manager
- `<prefix> c` - new window
- `<prefix> ,` - rename window
- `<prefix> 0` to `<prefix> 9` - change between windows 
- `<prefix> n/p` - next and previous window
- `<prefix> z` - zen mode
