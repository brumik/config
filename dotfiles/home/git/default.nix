{ pkgs, ... }: {
  home.packages = [
    pkgs.git
  ];

  home.file.".gitconfig".source = ./.gitconfig;
  home.file.".ssh/config".source = ./config;
}
