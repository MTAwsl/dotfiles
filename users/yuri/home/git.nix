{ self, ... }:
{
  flake.modules.homeManager.yuri-git =
    { ... }:
    {
      programs.git = {
        enable = true;
        signing = {
          key = self.meta.owner.github-ssh-pubkey;
          signByDefault = true;
        };
        settings = {
          user.name = "Sayuri Nekomiya";
          user.email = "bbh@awsl.rip";
          init.defaultBranch = "master";
          gpg = {
            format = "ssh";
          };
        };
      };

      programs.difftastic = {
        enable = true;
        git.enable = true;
      };
    };
}
