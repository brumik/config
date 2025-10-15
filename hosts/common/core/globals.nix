{ lib, ... }:
with lib;
{
  options.globals = mkOption {
    type = types.attrs;
    description = "Global values reused across all configurations.";
    default = { };
  };

  config.globals.users = {
    # Real users
    gamer = {
      uname = "gamer";
      uid = 1012;
    };
    levente = {
      uname = "levente";
      uid = 1010;
    };
    work = {
      uname = "work";
      uid = 1011;
    };
    katerina = {
      uname = "katerina";
      uid = 1000;
    };

    # Services
    # Default Homelab share
    share = {
      uname = "share";
      uid = 994;
      gname = "share";
      gid = 993;
    };

    immich = {
      uname = "immich";
      uid = 988;
      gname = "immich";
      gid = 984;
    };

    karakeep = {
      uname = "karakeep";
      uid = 1100;
      gname = "karakeep";
      gid = 1101;
    };

    lldap = {
      uname = "lldap";
      uid = 992;
      gname = "lldap";
      gid = 990;
    };

    mealie = {
      uname = "mealie";
      uid = 63892;
      gname = "mealie";
      gid = 63892;
    };

    nextcloud = {
      uname = "nextcloud";
      uid = 985;
      gname = "nextcloud";
      gid = 983;
    };

    radicale = {
      uname = "radicale";
      uid = 995;
      gname = "radicale";
      gid = 994;
    };

    vaultwarden = {
      uname = "vaultwarden";
      uid = 993;
      gname = "vaultwarden";
      gid = 991;
    };
  };
}

