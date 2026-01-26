{ ... }: {
  # Enable appimage support for some apps
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Enable flatpacks
  services.flatpak.enable = true;
  # Fails sometimes on rebuilds, can run it as sudo on a fresh flatpak install manually
  # systemd.services.flatpak-repo = {
  #   wantedBy = [ "multi-user.target" ];
  #   path = [ pkgs.flatpak ];
  #   script = ''
  #     flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  #   '';
  # };
}
