{ config, pkgs, ... }: {
  home.file.".ssh/id_ed25519.pub".source = ../../keys/id-brum.pub;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Levente Berky";
        email = "levente.berky@gmail.com";
        signingkey = "${config.sops.secrets."private-keys/id-brum".path}";
      };
      core.editor = "vi";
      push.default = "simple";
      pager.diff = "${pkgs.diffnav}/bin/diffnav";
      alias = {
        fap = "fetch --prune";
        lg =
          "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        fixup =
          "!sh -c '(git diff-files --quiet || (echo Unstaged changes, please commit or stash with --keep-index; exit 1)) && COMMIT=$(git rev-parse $1) && git commit --fixup=$COMMIT && git rebase -i --autosquash $COMMIT~1' -";
        clean-branches = "!git branch | grep -v rc | xargs git branch -D";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      gpg.format = "ssh";
      commit.gpgsign = true;
      rerere.enable = true;
      column.ui = "auto";
      # url = { "git@github.com:" = { insteadOf = "https://github.com/"; }; };
    };
  };

  home.file.".ssh/allowed_signers".text = ''
    * ${builtins.readFile ../../keys/id-brum.pub}
  '';

  home.file.".ssh/config".text = ''
    IdentityFile ${config.sops.secrets."private-keys/id-brum".path}
    Host sleeper.berky.me
      IdentityFile ${config.sops.secrets."private-keys/id-brum".path}
      IdentitiesOnly yes
  '';
}
