{ ... }:
{
  flake.modules.homeManager.yuri-opencode =
    { ... }:
    {
      programs.opencode = {
        enable = true;
        tui = {
          theme = "opencode";
        };
      };
    };
}
