{ username }: { pkgs, ... }:

{
  home.packages = [ pkgs.bw-setup-secrets ];
  home.file.".config/bw-setup-secrets/conf.toml".source = ./${username}.toml;
}
