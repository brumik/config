{ config, ... }:
{
  # The root of this pc should be able to log in to the root of every other PC
  sops.secrets = { "private-keys/id-deploy" = { }; };

  programs.ssh.extraConfig = ''
    Match user root Host *.berky.me
        IdentityFile ${config.sops.secrets."private-keys/id-deploy".path}
        IdentitiesOnly yes
  '';

}
