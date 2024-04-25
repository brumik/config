{ writeShellApplication }:
writeShellApplication {
  name = "find-app-hyprland";
  text = ''
    if [ $# -lt 1 ]; then
       echo "usage: find-app [class-name]"
       echo
       echo "Find and activate window with [class-name]."
       echo "Execute [command] if window cannot be found."
       echo
       echo "If [command] is not given, it is assumed to be [class-name]"
       exit 1
    fi

    if [ $# -lt 2 ]; then
      arg1="$1"
      first=''${arg1:0:1}
      class="[''${first^}''${first}]''${arg1:1}"

      # add true to then end otherwise grep propagates pipefail
      haswindow="$(hyprctl clients | grep "class: $class" -c || true)"

      if [ "$haswindow" != "0" ]; then
        hyprctl dispatch focuswindow "$class"
      else
        hyprctl dispatch exec "$arg1"
      fi
    fi
  '';
}
