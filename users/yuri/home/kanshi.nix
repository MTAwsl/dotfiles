{ ... }:
{
  flake.modules.homeManager.yuri-kanshi =
    { ... }:
    {
      services.kanshi = {
        enable = true;
        systemdTarget = "graphical-session.target";
      };
    };
}
