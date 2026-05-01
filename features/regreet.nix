{ self, ... }:
{
  flake.modules.nixos.regreet =
    { config, pkgs, ... }:
    let
      niriConfigKdl = pkgs.writeText "regreet-niri-conf.kdl" ''
        spawn-sh-at-startup "kanshi -c /home/${self.meta.owner.username}/.config/kanshi/config"
        spawn-sh-at-startup "${pkgs.regreet}/bin/regreet; niri msg action quit --skip-confirmation"
        hotkey-overlay {
            skip-at-startup
        }
        cursor {
            // Change the theme and size of the cursor as well as set the
            // `XCURSOR_THEME` and `XCURSOR_SIZE` env variables.
            xcursor-theme "catppuccin-mocha-red-cursors"
        }
      '';
    in
    {
      environment.systemPackages = with pkgs; [
        kanshi
      ];

      services.greetd = {
        enable = true;
        useTextGreeter = false;
        settings = {
          default_session = {
            command = "niri --config ${niriConfigKdl}";
            user = "greeter";
          };
        };
      };

      programs.regreet.enable = true;

      # NOTE: We intentionally run regreet through a custom niri command.
      # Disable Stylix regreet target to avoid compatibility warnings for
      # non-default greetd session command shapes.
      stylix.targets.regreet.enable = false;
    };
}
