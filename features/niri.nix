{ self, inputs, ... }:
{
  flake.modules.nixos.niri =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.niri.nixosModules.niri
      ];

      programs.niri.enable = true;
      programs.xwayland.enable = true;

      environment.systemPackages = with pkgs; [
        wl-clipboard
        wayland-utils
        libsecret
        xwayland-satellite
        app2unit

        kdePackages.ark
        nautilus

        pwvucontrol
        udiskie
      ];

      environment.variables.NIXOS_OZONE_WL = "1";

      services.gnome.sushi.enable = true;
      programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = "ghostty";
      };

      programs.uwsm = {
        enable = true;
        waylandCompositors.niri = {
          prettyName = "Niri";
          comment = "A scrollable-tiling Wayland compositor";
          binPath = "/run/current-system/sw/bin/niri-session";
        };
      };

      security = {
        polkit.enable = true;
        pam.services.greetd.enableGnomeKeyring = true;
      };

      networking.firewall = {
        allowedTCPPortRanges = [
          # {
          # # KDE Connect
          #   from = 1714;
          #   to = 1764;
          # }
        ];
        allowedUDPPortRanges = [
          # {
          # # KDE Connect
          #   from = 1714;
          #   to = 1764;
          # }
        ];
      };
    };
}
