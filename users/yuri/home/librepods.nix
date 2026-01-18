{ ... }:
{
  flake.modules.homeManager.yuri-librepods =
    { config, pkgs, ... }:
    let
      systemdTarget = config.wayland.systemd.target;
    in
    {
      home.packages = with pkgs; [
        librepods
      ];

      systemd.user.services.librepods = {
        Unit = {
          Description = "AirPods liberated from Apple's ecosystem. ";
          ConditionEnvironment = "WAYLAND_DISPLAY";
          PartOf = systemdTarget;
          Requires = systemdTarget;
          After = systemdTarget;
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.librepods}/bin/librepods --start-minimized";
          Restart = "on-failure";
          RestartSec = "5s";
        };

        Install = {
          WantedBy = [ systemdTarget ];
        };
      };

    };
}
