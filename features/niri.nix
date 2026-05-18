{ inputs, ... }:
{
  flake.modules.features.niri =
    { lib, pkgs, ... }:
    {
      imports = [
        inputs.niri.nixosModules.niri
      ];

      services.gnome = {
        gnome-keyring.enable = lib.mkForce true;
        gcr-ssh-agent.enable = false;
        sushi.enable = true;
      };

      programs = {
        niri = {
          enable = true;

          # Switch back to stable once https://github.com/sodiboo/niri-flake/pull/1548 is closed.
          package = pkgs.niri-unstable;
        };

        xwayland.enable = true;
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
        config = {
          common.default = [
            "gnome"
            "gtk"
          ];
          niri = {
            default = [
              "gnome"
              "gtk"
            ];
          };
        };
      };

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

        # icons
        papirus-icon-theme
      ];

      environment.variables.NIXOS_OZONE_WL = "1";

      programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = "ghostty";
      };

      programs.uwsm = {
        enable = true;
        waylandCompositors.niri = {
          prettyName = "Niri";
          comment = "A scrollable-tiling Wayland compositor";
          binPath = "/run/current-system/sw/bin/niri";
          extraArgs = [ "--session" ];
        };
      };
    };
}
