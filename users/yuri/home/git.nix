{ self, ... }:
{
  flake.modules.homeManager.yuri-git =
    { ... }:
    {
      programs.git = {
        enable = true;
        signing = {
          key = self.meta.owner.github-ssh-pubkey;
          format = "ssh";
          signByDefault = true;
        };
        settings = {
          user.name = "Sayuri Nekomiya";
          user.email = "bbh@awsl.rip";
          init.defaultBranch = "master";
        };
      };

      programs.difftastic = {
        enable = true;
        git.enable = true;
      };
    };
}
