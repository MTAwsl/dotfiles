{ ... }:
{
  flake.modules.homeManager.yuri-kde-connect =
    { ... }:
    {
      programs.niri.settings.spawn-at-startup = [
        { sh = "kdeconnect-indicator &"; }
      ];

      services.kdeconnect.enable = false;
    };
}
