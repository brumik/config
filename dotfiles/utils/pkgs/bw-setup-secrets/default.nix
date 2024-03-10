{ pkgs, writeShellApplication }:
writeShellApplication {
  runtimeInputs = [ pkgs.bitwarden-cli ];
  name = "bw-setup-secrets";
  text = ''
    noteid="c660a85d-1081-464e-a37f-b396bca432f5"
    secretsFile="$HOME/.zshsecrets"

    # Setup and log in if not done so yet
    bw config server https://bitwarden.brumspace.synology.me


    if bw login --check --raw ; then
      echo "Already logged in"
    else
      bw login
    fi

    # Unlock first the vault
    # shellcheck disable=SC2155
    export BW_SESSION="$(bw unlock --raw)"

    # Copy the note to secretsFile if not exist, otherwise skip
    if [ -f "$secretsFile" ]; then
        echo "300: Not allowed: $secretsFile exist, skipping"
    else
        touch "$secretsFile"
        bw get notes $noteid >> "$secretsFile"
        echo "Written to $secretsFile - restart your terminal to take effect"
    fi

    # Get files
    copy_file () {
      local path=$1
      local file=$2

      if [ -f "$path" ]; then
          echo "300: Not allowed: $path exist, skipping"
      else
          touch "$path"
          bw get attachment "$file" --itemid "$noteid" --output "$path"
          echo "File $path completed"
      fi
    }

    file1="id_ed25519"
    path1="$HOME/.ssh/id_ed25519"
    copy_file "$path1" "$file1"

    file1="id_ed25519.pub"
    path1="$HOME/.ssh/id_ed25519.pub"
    copy_file "$path1" "$file1"

    file1="allowed_signers"
    path1="$HOME/.ssh/allowed_signers"
    copy_file "$path1" "$file1"

    export BW_SESSION=""
  '';
}
