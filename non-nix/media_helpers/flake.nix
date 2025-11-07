{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = (import (inputs.nixpkgs) { inherit system; });
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # system packages
            rsync
            ffmpeg
            flac
            mp3val
            sox
            (python3.withPackages (ps: [ # python3
              # pip packages
              ps.python-dotenv
            ]))

            # For ripping cds
            abcde
          ];
        };
      });
}
