{ config, self, ... }:
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
          lanzaboote
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
      
      boot.initrd = {
        availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
        kernelModules = [ ];
      }
      // self.lib.mkInitrdLuksYubiKeySupport "luks-695b24b6-2263-42dc-9db5-1a2545fe8675" "/dev/disk/by-uuid/luks-695b24b6-2263-42dc-9db5-1a2545fe8675"
      // self.lib.mkInitrdLuksYubiKeySupport "luks-25a3784d-03b9-41c1-a156-cc0676ca9c85" "/dev/disk/by-uuid/25a3784d-03b9-41c1-a156-cc0676ca9c85";

      boot.extraModulePackages = [ ];
      boot.kernelModules = [ "kvm-intel" ];

      fileSystems."/" =
        { device = "/dev/mapper/luks-25a3784d-03b9-41c1-a156-cc0676ca9c85";
          fsType = "ext4";
        };

      fileSystems."/boot" =
        { device = "/dev/disk/by-uuid/eb49-40f3";
          fsType = "vfat";
          options = [ "fmask=0077" "dmask=0077" ];
        };

      swapDevices =
        [ { device = "/dev/mapper/luks-695b24b6-2263-42dc-9db5-1a2545fe8675"; }
        ];

      nixpkgs.hostPlatform = lib.mkdefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkdefault config.hardware.enableRedistributableFirmware;
    };
}
