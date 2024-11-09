{ ... }:

{
  programs.tmux.extraConfig = ''
    bind C-c display-popup -E "pet search --color"
  '';

  programs.pet = {
    enable = true;
    settings = {
      General = {
        editor = "nvim";
        selectcmd = "fzf --ansi";
        sortby = "command";
        color = true;
        format = "$command | $description | $tags |";
      };
    };
    snippets = [
      {
        command = ":cfdo %s/stringOne/stringTwo/g | update | bd";
        description = "Regex replace across the whole project";
        tag = ["cmd" "vim" "replace"];
      }
      {
        command = "sudo lsof -nP -iTCP -sTCP:LISTEN";
        description = "Show services which listen to any TCP port";
        tag = ["cmd" "networking" "system"];
      }
      {
        command = "docker system prune --volumes -af";
        description = "Clear all docker system resourses not in use";
        tag = ["cmd" "docker"];
      }
      {
        command = "journalctl -xeu [service].service";
        description = "Open journal logs for the given service";
        tag = ["cmd" "system"];
      }
      {
        command = "[d|v|c]a[character]";
        description = "Do the specified action for the section between the matching `charcter` inclusive";
        tag = ["shortcut" "vim"];
      }
      {
        command = "%";
        description = "Jump to matchin pair of bracket";
        tag = ["shortcut" "vim"];
      }
      {
        command = "_";
        description = "Jump to first character in the line";
        tag = ["shortcut" "vim"];
      }
      {
        command = "[f|F][character]";
        description = "Jump to the next/previous character in line";
        tag = ["shortcut" "vim"];
      }
      {
        command = "[t|T][character]";
        description = "Jump before the next/previous chracter in line";
        tag = ["shortcut" "vim"];
      }
      {
        command = "[d|v|c]i[character]";
        description = "Do the specified action fo the section between the matching `character`";
        tag = ["shortcut" "vim"];
      }
      {
        command = "<C-o>";
        description = "Jump to the previous place with cursor";
        tag = ["shortcut" "vim"];
      }
      {
        command = "<C-i>";
        description = "Jump to the next place with cursor";
        tag = ["shortcut" "vim"];
      }
      {
        command = "<C-w><C-w>";
        description = "Jump to next pane";
        tag = ["shortcut" "vim"];
      }
      {
        command = "<C-w><C-v>";
        description = "Split pane verticaly";
        tag = ["shortcut" "vim"];
      }
      {
        command = "<C-w><C-s>";
        description = "Split pane horizontaly";
        tag = ["shortcut" "vim"];
      }
      {
        command = "<C-w>=";
        description = "Equalize pane sizes";
        tag = ["shortcut" "vim"];
      }
      {
        command = "=";
        description = "Fix indent for line/selection";
        tag = ["shortcut" "vim"];
      }
      {
        command = "*";
        description = "Forward serarch the word under the cursor";
        tag = ["shortcut" "vim"];
      }
      {
        command = "#";
        description = "Backward serarch the word under the cursor";
        tag = ["shortcut" "vim"];
      }
      {
        command = "$";
        description = "Jump to the end of the line";
        tag = ["shortcut" "vim"];
      }
      {
        command = "<C-q>";
        description = "Telescope: Send all items to quickfixlist (qflist)";
        tag = ["shortcut" "vim" "telescope"];
      }
      {
        command = ":%s/[search]/[replace]/g";
        description = "Replace [search] with [replace] in [%] (file)";
        tag = ["shortcut" "vim"];
      }
      {
        command = "<C-a>,";
        description = "Tmux reanme window";
        tag = ["shortcut" "tmux"];
      }
      {
        command = "sudo netstat -tunlp | grep [port number]";
        description = "Find what is listening on a port";
        tag = ["cmd"];
      }
    ];
  };

}
