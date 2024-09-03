{ username }: { pkgs, ... }:

{
  home.packages = [
    pkgs.git
  ];

  home.file.".gitconfig".source = ./${username}.gitconfig;
}
