{ self, ... }:
{
  flake.modules.profiles.desktop =
    { lib, pkgs, ... }:
    {
      imports = with self.modules.features; [
        niri
        dms-shell
        plymouth
        stylix
        fonts

        # polkit-agent # Use DMS's Polkit agent.

        # Switch back to dms-greeter once it supports YubiKey.
        dms-greeter
        # tuigreet
        # regreet
      ];

      environment.systemPackages =
        with pkgs;
        [
          # Pipewire
          pwvucontrol
          gsettings-desktop-schemas
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
          easyeffects
        ];

      environment.sessionVariables = {
        XDG_DATA_DIRS = [ "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/*" ];
      };

      # sound
      security.rtkit.enable = true;
      services = {
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          wireplumber.enable = true;
        };

        udev.extraRules = ''
          # Allow the "wheel" group to write to the nvidia backlight file
          ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="nvidia_0", MODE="0664", GROUP="wheel"
        '';

        printing.enable = true;
        gvfs.enable = true;
        ratbagd.enable = true;
        udisks2.enable = true;
      };

      security.polkit.extraConfig = ''
        // Wheel group's passwordless actions
        polkit.addRule(function(action, subject) {
          var allowedActions = [
            "org.freedesktop.udisks2.filesystem-mount",       // Mount external drives
            "org.freedesktop.udisks2.filesystem-mount-system",// Mount internal drives
            "org.freedesktop.udisks2.eject-media",            // Eject media
            "org.freedesktop.udisks2.encrypted-unlock",       // Unlock LUKS partitions
            "org.freedesktop.udisks2.power-off-drive"         // Spin down drives
          ];

          // If the action is in our list AND the user is in the 'wheel' group
          if (allowedActions.indexOf(action.id) !== -1 && subject.isInGroup("wheel")) {
            return polkit.Result.YES;
          }
        });
      '';

      fonts.fontDir.enable = true;

      # controller
      # hardware.xone.enable = true;
      hardware.xpadneo.enable = true;
    };
}
