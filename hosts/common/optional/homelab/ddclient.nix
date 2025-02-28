{ config, lib, ... }:
let
  cfg = config.homelab.ddclient;
in {
  options.homelab.ddclient = {
    enable = lib.mkEnableOption "ddclient";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."n100/ddclient-key" = {
      path = "/var/lib/ddclient/ddclient.key";
    };

    services.ddclient = {
      enable = true;
      usev4 = "webv4, webv4=ip.websupport.sk/";
      usev6 = "";
      ssl = true;
      protocol = "dyndns2";
      server = "dyndns.websupport.sk";
      username = "3a2bf436-c280-43f3-97b9-d71c27172191";
      passwordFile = config.sops.secrets."n100/ddclient-key".path;
      extraConfig = "wildcard=yes";
      domains = [ config.homelab.domain ];
    };
  };
}
