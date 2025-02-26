{ config, lib, ... }:
let cfg = config.homelab.languagetool;
in {
  options.homelab.languagetool = {
    enable = lib.mkEnableOption "languagetool";
  };

  config = lib.mkIf cfg.enable {
    services.languagetool = {
      enable = true;
      # jvmOptions = [ "-Xmx512m" ];
      # Turn off after reverse proxy
      public = true;
      # port = 8081
    };

    networking.firewall.allowedTCPPorts = [ 8081 ];
  };
}
