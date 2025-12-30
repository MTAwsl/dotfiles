{ ... }:
{
  flake.modules.homeManager.yuri-git =
    { ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user.name = "Sayuri Nekomiya";
          user.email = "bbh@awsl.rip";
          init.defaultBranch = "master";
        };
      };
    };
}
