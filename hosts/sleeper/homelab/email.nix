{ config, lib, ... }:
let
  cfg = config.homelab.email;
in {
  options.homelab.email = {
    enable = lib.mkEnableOption "email";

    addr = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "The subdomain where the service will be served";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = { "n100/smtp-pass" = { }; };

    programs.msmtp = {
      enable = true;
      setSendmail = true;
      defaults = {
        aliases = "/etc/aliases";
        port = 465;
        tls = "on";
        auth = "login";
        tls_starttls = "off";
      };
      accounts = {
        default = {
          host = "smtp.m1.websupport.sk";
          passwordeval = "cat ${config.sops.secrets."n100/smtp-pass".path}";
          user = "sleeper@berky.me";
          from = "sleeper@berky.me";
        };
      };
    };

    environment.etc = {
      "aliases" = {
        text = ''
          ${cfg.addr}: levente.berky@gmail.com
        '';
        mode = "0644";
      };
    };
  };
}
