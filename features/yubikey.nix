{ self, ... }:
{
  # systemd-cryptenroll --fido2-device=auto /dev/<device>
  # systemd-cryptenroll --recovery-key /dev/<device>
  flake.modules.nixos.yubikey =
    { pkgs, ... }:
    {
      security.pam.u2f = {
        # With pamu2fcfg, users listed in $XDG_CONFIG_HOME/Yubico/u2f_keys (or $HOME/.config/Yubico/u2f_keys if XDG variable is not set)
        # are able to log in with the associated U2F key.
        enable = true;
        settings = {
          authfile = "/etc/u2f_keys";
          origin = "pam://" + self.meta.owner.pam_origin;
          interactive = false;
          cue = false;
        };
      };

      security.pam.services = {
        polkit-1.u2fAuth = true;
        login.u2fAuth = true;
        sudo.u2fAuth = true;
      };

      # Lock screen after removing yubikey
      # Change Revision number if this is not working.
      services.udev.extraRules = ''
        ACTION=="remove",\
        ENV{SUBSYSTEM}=="usb",\
        ENV{PRODUCT}=="1050/407/574",\
        RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
      '';

      boot.initrd = {
        systemd.enable = true;
        availableKernelModules = [
          "usbhid"
          "hid_generic"
          "uhci_hcd"
          "ehci_pci"
          "nvme"
        ];

        luks.fido2Support = false; # Avoid conflicts
      };

      programs.yubikey-manager.enable = true;
    };
}
