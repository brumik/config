{ pkgs, ... }: {
  # Enable appimage support for some apps
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Enable flatpacks
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
