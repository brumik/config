{ config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix

    ../common/core

    ../common/optional/base-gnome.nix
    ../common/optional/sound.nix
    ../common/optional/docker.nix
    ../common/optional/smb.nix
    ../common/optional/nvidia.nix
    ../common/optional/ollama.nix
    ../common/optional/scanner.nix
    ../common/optional/sound.nix
    ../common/optional/gaming.nix

    ../common/users/levente.nix
    ../common/users/work.nix
  ];

  mySystems.smb = {
    enable = true;
    credentials = config.sops.secrets."brum/smb-credentials".path;
  };

  mySystems.docker = { enable = true; };

  mySystems.scanner = { enable = true; };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "brumstellar";

  #############################################
  # Custom or temporary stuff                 #
  #############################################

  # Needed for the yubike UI
  services.pcscd = { enable = true; };
  virtualisation.vmware.host.enable = true;

  # sops.secrets."n100/mealie-credentials" = { };
  #
  # services.mealie = {
  #   enable = true;
  #   listenAddress = "0.0.0.0";
  #   port = 9000;
  #   package = pkgs.mealie;
  #   settings = {
  #     BASE_URL = "https://mealie.berky.me";
  #     ALLOW_SIGNUP = "false";
  #     LOG_LEVEL = "ERROR";
  #     # LOG_LEVEL = "DEBUG";
  #
  #     # =====================================;
  #     # Email Configuration;
  #     SMTP_HOST = "smtp.m1.websupport.sk";
  #     SMTP_PORT = "465";
  #     SMTP_FROM_NAME = "Mealie";
  #     SMTP_AUTH_STRATEGY = "SSL";
  #     SMTP_FROM_EMAIL = "mealie-noreply@berky.me";
  #     SMTP_USER = "mealie-noreply@berky.me";
  #
  #     DB_ENGINE = "sqlite";
  #     # =====================================;
  #     # SSO Configuration;
  #     OIDC_AUTH_ENABLED = "true";
  #     OIDC_SIGNUP_ENABLED = "true";
  #     OIDC_CONFIGURATION_URL =
  #       "https://authelia.berky.me/.well-known/openid-configuration";
  #     OIDC_CLIENT_ID = "mealie";
  #     OIDC_AUTO_REDIRECT = "true";
  #     OIDC_ADMIN_GROUP = "mealie_admin";
  #     OIDC_USER_GROUP = "mealie_user";
  #   };
  #   credentialsFile = config.sops.secrets."n100/mealie-credentials".path;
  # };

}
