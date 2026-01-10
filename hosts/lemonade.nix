{ self, ... }:
{
  flake.modules.nixos.host-lemonade =
    { lib, pkgs, ... }:
    {
      imports =
        (with self.modules.nixos; [
          # Home Manager
          home-manager

          # Services
          sshd

          # Host Features
          no-root-passwd
          yubikey
        ])
        # Import host profiles.
        ++ (with self.lib.withPrefix "profile" self.modules.nixos; [
          base
          desktop
        ])
        # Import user profiles.
        ++ (with self.lib.withUserProfile "yuri"; [
          base
          desktop
        ]);

      system.stateVersion = "26.05";

      boot.initrd.luks.devices."luks-695b24b6-2263-42dc-9db5-1a2545fe8675".device = "/dev/disk/by-uuid/695b24b6-2263-42dc-9db5-1a2545fe8675";
      networking.hostName = "Yuri-Lemonade";

      networking.networkmanager.enable = true;
      time.timeZone = "Australia/Sydney";
      i18n.defaultLocale = "en_AU.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_AU.UTF-8";
        LC_IDENTIFICATION = "en_AU.UTF-8";
        LC_MEASUREMENT = "en_AU.UTF-8";
        LC_MONETARY = "en_AU.UTF-8";
        LC_NAME = "en_AU.UTF-8";
        LC_NUMERIC = "en_AU.UTF-8";
        LC_PAPER = "en_AU.UTF-8";
        LC_TELEPHONE = "en_AU.UTF-8";
        LC_TIME = "en_AU.UTF-8";
      };
      
      boot.initrd.availablekernelmodules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      boot.initrd.kernelmodules = [ ];
      boot.kernelmodules = [ "kvm-intel" ];
      boot.extramodulepackages = [ ];

      filesystems."/" =
        { device = "/dev/mapper/luks-25a3784d-03b9-41c1-a156-cc0676ca9c85";
          fstype = "ext4";
        };

      boot.initrd.luks.devices."luks-25a3784d-03b9-41c1-a156-cc0676ca9c85".device = "/dev/disk/by-uuid/25a3784d-03b9-41c1-a156-cc0676ca9c85";

      filesystems."/boot" =
        { device = "/dev/disk/by-uuid/eb49-40f3";
          fstype = "vfat";
          options = [ "fmask=0077" "dmask=0077" ];
        };

      swapdevices =
        [ { device = "/dev/mapper/luks-695b24b6-2263-42dc-9db5-1a2545fe8675"; }
        ];

      nixpkgs.hostplatform = lib.mkdefault "x86_64-linux";
      hardware.cpu.intel.updatemicrocode = lib.mkdefault config.hardware.enableredistributablefirmware;
    };
}
