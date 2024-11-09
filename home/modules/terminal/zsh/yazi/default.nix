{ ... }: {
  programs.zsh = {
    initExtra = ''
      function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
    '';
  };

  programs.yazi = {
    enable = true;
  };

  home.file.".config/yazi/yazi.toml".source = ./yazi.toml;
}
