{ ... }:
{
  programs.tmux = {
    extraConfig = ''
## COLORSCHEME: everforest dark medium
      set-option -g status "on"
      set -g status-interval 2

      set-option -g status-fg '#D3C6AA' # fg
      set-option -g status-bg '#2D353B' # bg0

      set-option -g mode-style fg='#D699B6',bg='#514045' # fg=purple, bg=bg_visual

# default statusbar colors
      set-option -g status-style fg='#D3C6AA',bg='#232A2E',default # fg=fg bg=bg_dim

# ---- Windows ----
# default window title colors
      set-window-option -g window-status-style fg='#56635F',bg='#2D353B' # fg=yellow bg=bg0

# default window with an activity alert
      set-window-option -g window-status-activity-style bg=colour237,fg=colour248 # bg=bg1, fg=fg3

# active window title colors
      set-window-option -g window-status-current-style fg='#D3C6AA',bg='#425047' # fg=fg bg=bg_green

# ---- Pane ----
# pane borders
      set-option -g pane-border-style fg='#343F44' # fg=bg1
      set-option -g pane-active-border-style fg='#7FBBB3' # fg=blue

# pane number display
      set-option -g display-panes-active-colour '#7FBBB3' # blue
      set-option -g display-panes-colour '#E69875' # orange

# ---- Command ----
# message info
      set-option -g message-style fg='#E67E80',bg='#232A2E' # fg=statusline3 bg=bg_dim

# writing commands inactive
      set-option -g message-command-style fg=colour223,bg=colour239 # bg=fg3, fg=bg1

# ---- Miscellaneous ----
# clock
      set-window-option -g clock-mode-colour '#7FBBB3' #blue

# bell
      set-window-option -g window-status-bell-style fg='#2D353B',bg='#E67E80' # fg=bg, bg=statusline3

# ---- Formatting ----
      set-option -g status-left-style none
      set -g status-left-length 60
      set -g status-left '#[fg=#232A2E,bg=#A7C080,bold] #S #[fg=#A7C080,bg=#3D484D,nobold]#[fg=#A7C080,bg=#3D484D,bold] #(whoami) #[fg=#3D484D,bg=#2D353B,nobold]'

      set-option -g status-right-style none
      set -g status-right-length 150
      set -g status-right '#[fg=#3D484D]#[fg=#D3C6AA,bg=#3D484D] #[fg=#D3C6AA,bg=#3D484D]%Y-%m-%d  %H:%M #[fg=#83C092,bg=#3D484D,bold]#[fg=#232A2E,bg=#83C092,bold] #h '

      set -g window-status-separator '#[fg=#9DA9A0,bg=#2D353B] '
      set -g window-status-format "#[fg=#7A8478,bg=#2D353B] #I  #[fg=#7A8478,bg=#2D353B]#W "
      set -g window-status-current-format "#[fg=#2D353B,bg=#425047]#[fg=#D3C6AA,bg=#425047] #I  #[fg=#D3C6AA,bg=#425047,bold]#W #[fg=#425047,bg=#2D353B,nobold]"
    '';
  };
}
