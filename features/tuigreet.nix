{ ... }:
{
  flake.modules.nixos.tuigreet =
    { config, pkgs, ... }:
    {
      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session.command = ''
            ${pkgs.tuigreet}/bin/tuigreet \
            --sessions "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions" \
            --xsessions "${config.services.displayManager.sessionData.desktops}/share/xsessions" \
            --remember \
            --remember-user-session \
            --window-padding 1 \
            --time \
            --asterisks \
            --power-shutdown "/run/current-system/systemd/bin/systemctl poweroff" \
            --power-reboot "/run/current-system/systemd/bin/systemctl reboot"
          '';

          commands = {
            "reboot" = [
              "/run/current-system/systemd/bin/systemctl"
              "reboot"
            ];
            "poweroff" = [
              "/run/current-system/systemd/bin/systemctl"
              "poweroff"
            ];
          };
        };
      };
    };
}
