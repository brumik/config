{ pkgs, writeShellApplication }:
writeShellApplication {
  runtimeInputs = [ pkgs.xdotool ];
  name = "find-app-xdotool";
  text = ''
    if [ $# -lt 1 ]; then
       echo "usage: ''$(basename "$0") [class-name] [command] [args]"
       echo
       echo "Find and activate window with [class-name]."
       echo "Execute [command] if window cannot be found."
       echo
       echo "If [command] is not given, it is assumed to be [class-name]"
       exit 1
    fi

    if [ $# -lt 2 ]; then
       class="$1"
       find_app="xdotool search --onlyvisible --class $class windowactivate"
       command="$1"
    else
       class="$1"
       find_app="xdotool search --onlyvisible --class $class windowactivate"
       shift
       command="$*"
    fi

    if (! eval "''${find_app}") ; then
       eval "xdotool exec ''${command}"
    fi
  '';
}
