{ self, inputs, ... }:
{
  flake.modules.nixos.niri =
    { lib, pkgs, ... }:
    {
      imports = [
        inputs.niri.nixosModules.niri
      ];

      services.gnome.gnome-keyring.enable = lib.mkForce true;
      services.gnome.gcr-ssh-agent.enable = false;

      programs.niri.enable = true;

      # Switch back to stable once https://github.com/sodiboo/niri-flake/pull/1548 is closed.
      programs.niri.package = pkgs.niri-unstable;

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

        # icons
        papirus-icon-theme
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
          binPath = "/run/current-system/sw/bin/niri";
          extraArgs = [ "--session" ];
        };
      };
    };
}
