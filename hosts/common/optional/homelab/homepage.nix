{ config, lib, ... }:
let cfg = config.homelab.homepage;
in {
  options.homelab.homepage = { enable = lib.mkEnableOption "homepage"; };

  # TODO The services format is absolutely unusable for distributed config...
  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      port = 8082;
      openFirewall = true;
      services = [
        { Admin = []; }
        { Media = []; }
        { Services = []; }
        { App = []; }
      ];
      widgets = [
        {
          resources = {
            cpu = true;
            disk = "/";
            memory = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
      ];
    };
  };
}
