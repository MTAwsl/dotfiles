{ ... }:
{
  # systemd-cryptenroll --fido2-device=auto /dev/<device>
  # systemd-cryptenroll --recovery-key /dev/<device>
  flake.modules.nixos.yubikey = { self, pkgs, ... }:
  {
    boot.initrd = {
      systemd.enable = true;
      availableKernelModules = [ "usbhid" "hid_generic" "uhci_hcd" "ehci_pci" "nvme" ];

      luks.fido2Support = false; # Avoid conflicts
    };

    security.pam.u2f = {
      # With pamu2fcfg, users listed in $XDG_CONFIG_HOME/Yubico/u2f_keys (or $HOME/.config/Yubico/u2f_keys if XDG variable is not set)
      # are able to log in with the associated U2F key.
      enable = true;
      settings = {
        origin = "pam://" + self.meta.owner.pam_origin;
        interactive = true;
        cue = true;
      };
    };

    programs.yubikey-manager.enable = true;
  };

  flake.lib.mkLuksYubiKeySupport = name: device: {
    luks.devices."${name}" = {
      inherit device;
      cryptotabExtraOpts = [ "fido2-device=auto" ];
    };
  };
}
