_: {
  flake.modules.users.yuri.home.git = _: {
    programs.git = {
      enable = true;
      signing = {
        key = "~/.ssh/id_ed25519_sk";
        format = "ssh";
        signByDefault = true;
      };
      settings = {
        user.name = "Sayuri Nekomiya";
        user.email = "contactme@awsl.rip";
        init.defaultBranch = "master";
      };
    };

    programs.difftastic = {
      enable = true;
      git.enable = true;
    };
  };
}
