{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    ollama 
  ];
  systemd.user.services.ollama = {
    enable = true;
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.ollama}/bin/ollama serve";
      Restart = "always";
      RestartSec = "3";
    };
  };
}
