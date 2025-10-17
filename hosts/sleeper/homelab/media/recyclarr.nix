{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.media.recyclarr;
  hcfg = config.homelab;

  extractApiKeys = pkgs.writeShellApplication {
    name = "extract-recyclarr-api-keys";
    runtimeInputs = with pkgs; [ gnugrep ];
    text = ''
      echo "Extracting Sonarr API key"
      mkdir -p /etc/recyclarr
      grep -oPm1 "(?<=<ApiKey>)[^<]+" ${hcfg.media.sonarr.baseDir}/config.xml > /etc/recyclarr/sonarr-api_key
      echo "Extracting Radarr API key"
      grep -oPm1 "(?<=<ApiKey>)[^<]+" ${hcfg.media.radarr.baseDir}/config.xml > /etc/recyclarr/radarr-api_key
    '';
  };
in {
  options.homelab.media.recyclarr = {
    enable = lib.mkEnableOption "recyclarr";
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    assertions = [
      {
        assertion = hcfg.media.sonarr.enable;
        message = "Recyclarr needs sonarr to be enabled";
      }
      {
        assertion = hcfg.media.radarr.enable;
        message = "Recyclarr needs radarr to be enabled";
      }
    ];

    systemd.services.recyclarr-setup = {
      description = "Setup Recyclarr environment";
      requiredBy = [ "recyclarr.service" ];
      before = [ "recyclarr.service" ];
      requires = (lib.optionals hcfg.media.radarr.enable [ "radarr.service" ])
        ++ (lib.optionals hcfg.media.sonarr.enable [ "sonarr.service" ]);
      after = (lib.optionals hcfg.media.radarr.enable [ "radarr.service" ])
        ++ (lib.optionals hcfg.media.sonarr.enable [ "sonarr.service" ]);

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.getExe extractApiKeys;
      };
    };

    systemd.services.recyclarr = {
      requires = [ "recyclarr-setup.service" ];
      after = [ "recyclarr-setup.service" ];
      serviceConfig.LoadCredential = [
        "sonarr-api_key:/etc/recyclarr/sonarr-api_key"
        "radarr-api_key:/etc/recyclarr/radarr-api_key"
      ];
    };

    services.recyclarr = {
      enable = true;
      user = hcfg.user;
      group = hcfg.group;
      configuration = {
        # The imports are from here: https://recyclarr.dev/wiki/guide-configs
        sonarr = {
          web-1080p-v4 = {
            base_url = "http://localhost:${
                toString config.services.sonarr.settings.server.port
              }";

            api_key = {
              _secret = "/run/credentials/recyclarr.service/sonarr-api_key";
            };

            delete_old_custom_formats = true;
            replace_existing_custom_formats = true;

            include = [
              { template = "sonarr-quality-definition-series"; }
              { template = "sonarr-v4-quality-profile-web-1080p"; }
              { template = "sonarr-v4-custom-formats-web-1080p"; }
            ];

            custom_formats = [{
              # Example: disabled trash IDs (uncomment to enable)
              trash_ids = [
                "32b367365729d530ca1c124a0b180c64" # Bad Dual Groups
                "82d40da2bc6923f41e14394075dd4b03" # No-RlsGroup
                "e1a997ddb54e3ecbfe06341ad323c458" # Obfuscated
                "06d66ab109d4d2eddb2794d21526d140" # Retags
                "1b3994c551cbb92a2c781af061f4ab44" # Scene
              ];
              assign_scores_to = [{ name = "WEB-1080p"; }];
            }];
          };
        };

        radarr = {
          hd-bluray-web = {
            base_url = "http://localhost:${
                toString config.services.radarr.settings.server.port
              }";

            api_key = {
              _secret = "/run/credentials/recyclarr.service/radarr-api_key";
            };

            delete_old_custom_formats = true;
            replace_existing_custom_formats = true;

            include = [
              # Comment out any of the following includes to disable them
              { template = "radarr-quality-definition-movie"; }
              { template = "radarr-quality-profile-hd-bluray-web"; }
              { template = "radarr-custom-formats-hd-bluray-web"; }
            ];

            custom_formats = [
              # Movie Versions
              {
                trash_ids = [
                  # Uncomment to prefer these movie versions
                  # "570bc9ebecd92723d2d21500f4be314c" # Remaster
                  # "eca37840c13c6ef2dd0262b141a5482f" # 4K Remaster
                  # "e0c07d59beb37348e975a930d5e50319" # Criterion Collection
                  # "9d27d9d2181838f76dee150882bdc58c" # Masters of Cinema
                  # "db9b4c4b53d312a3ca5f1378f6440fc9" # Vinegar Syndrome
                  # "957d0f44b592285f26449575e8b1167e" # Special Edition
                  # "eecf3a857724171f968a66cb5719e152" # IMAX
                  "9f6cbff8cfe4ebbc1bde14c7b7bec0de" # IMAX Enhanced
                ];
                assign_scores_to = [{ name = "HD Bluray + WEB"; }];
              }

              # Optional
              {
                trash_ids = [
                  "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
                  "cc444569854e9de0b084ab2b8b1532b2" # Black and White Editions
                  "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5" # No-RlsGroup
                  "7357cf5161efbf8c4d5d0c30b4815ee2" # Obfuscated
                  "5c44f52a8714fdd79bb4d98e2673be1f" # Retags
                  "f537cf427b64c38c8e36298f657e4828" # Scene
                ];
                assign_scores_to = [{ name = "HD Bluray + WEB"; }];
              }
            ];
          };
        };
      };
    };
  };
}
