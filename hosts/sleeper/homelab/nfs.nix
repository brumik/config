{ config, lib, ... }:
let
  cfg = config.homelab.nfs;
  hcfg = config.homelab;
  share = config.globals.users.share;
  options = "rw,nohide,insecure,no_subtree_check,all_squash,anonuid=${
      toString share.uid
    },anongid=${toString share.gid}";
  hosts = [ "brumstellar" "anteater" ];
  constructor = str:
    lib.strings.concatStrings (map (host: "${host}.berky.me(${str}) ") hosts);
in {
  options.homelab.nfs = { enable = lib.mkEnableOption "email"; };

  config = lib.mkIf (hcfg.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "d /export 0755 nobody nogroup -"
    ];

    fileSystems."/export/media" = {
      device = "/media";
      options = [ "bind" ];
    };

    fileSystems."/export/backup" = {
      device = "/backup";
      options = [ "bind" ];
    };

    services.nfs.server.enable = true;
    services.nfs.server.exports = ''
      /export        ${constructor "rw,fsid=0,no_subtree_check"}
      /export/media  ${constructor options}
      /export/backup  ${constructor options}
    '';
    networking.firewall.allowedTCPPorts = [ 2049 ];
  };
}
