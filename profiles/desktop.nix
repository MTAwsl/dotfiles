{ self, ... }:
{
  flake.modules.nixos.profile-desktop =
    { pkgs, ... }:
    {
      imports = with self.modules.nixos; [
        niri
        dms-shell
        plymouth
        stylix
        fonts

        # polkit-agent # Use DMS's Polkit agent.

        # Switch back to dms-greeter once it supports YubiKey.
        # dms-greeter
        # tuigreet

        regreet
        hyprlock # Choose hyprlock as lock screen cmd in DMS Settings
      ];

      environment.systemPackages = with pkgs; [
        # Pipewire
        pwvucontrol
        easyeffects

        gsettings-desktop-schemas
      ];

      environment.sessionVariables = {
        XDG_DATA_DIRS = [ "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/*" ];
      };

      # sound
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      services.udev.extraRules = ''
        # Allow the "wheel" group to write to the nvidia backlight file
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="nvidia_0", MODE="0664", GROUP="wheel"
      '';

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

      # printing
      services.printing.enable = true;

      # GNOME virtual FS
      services.gvfs.enable = true;

      # controller
      # hardware.xone.enable = true;
      hardware.xpadneo.enable = true;

      # mouse config (piper)
      services.ratbagd.enable = true;

      # USB Mass Storage
      services.udisks2.enable = true;
    };
}
