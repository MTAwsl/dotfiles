{ self, ... }:
{
  flake.modules.nixos.host-qemu-aarch64 = { lib, ... }:
  {
    imports = with self.modules.nixos; [
      home-manager
      basic-shell
      desktop
      sshd
      user-yuri
      user-yuri-desktop
    ];

    system.stateVersion = "26.05";
    
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

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

    networking.networkmanager.enable = true;
    networking.firewall.enable = true;

    hardware.graphics.enable = true;
    networking.hostName = "Yuri-NixOS-QEMU-AARCH64";

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_pci"
      "virtio_net"
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_scsi"
      "9p"
      "9pnet_virtio"  
      "usbhid"
      "usb_storage"
      "sr_mod"
    ];

    boot.initrd.kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
      "virtio_gpu"
    ];

    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/540fdbde-2b58-4533-9d1d-c0358f154edf";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/F667-C8FB";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/175f9ebf-3e3d-474a-aebb-7574d5bb7b60"; }
      ];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}

