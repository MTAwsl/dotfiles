{ self, inputs, ... }:
{
  flake.modules.nixos.niri = { pkgs, ... } : {
    imports = [ inputs.niri.nixosModules.niri ];

    programs.niri.enable = true;
    services.greetd = {
      enable = true;
      settings = {
        commands = {
          "reboot" = ["systemctl" "reboot"];
          "poweroff" = ["systemctl" "poweroff"];
        };

        default_session = {
          command = "niri";
          user = "yuri";
        };
      };
    };

    programs.regreet.enable = true;

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
  };
}

