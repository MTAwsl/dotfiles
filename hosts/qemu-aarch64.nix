{ self, ... }:
{
  flake.modules.hosts.qemu-aarch64 =
    { lib, pkgs, ... }:
    let
      users = self.lib.getHostUsers self.modules.users [ "yuri" ];
      inherit (users) yuri;
    in
    {
      imports =
        (with self.modules.features; [
          # Home Manager
          home-manager

          # Services
          sshd
        ])
        # Import host profiles.
        ++ (with self.modules.profiles; [
          base
          desktop
          qemu-guest
        ])
        # Import user profiles.
        ++ (with yuri.profiles; [
          base
          desktop
          qemu-guest
        ]);

      system.stateVersion = "26.05";
      environment.sessionVariables = {
        LIBGL_ALWAYS_SOFTWARE = "1";
      };
      programs.niri.package = lib.mkForce pkgs.niri; # niri-flake only contains x86_64 builds for now. Use nixpkgs instead.

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

      networking = {
        networkmanager.enable = true;
        firewall.enable = true;
        hostName = "Yuri-NixOS-QEMU-AARCH64";
      };

      hardware.graphics.enable = true;
      # services.xserver.enable = true;

      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        initrd = {
          availableKernelModules = [
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

          kernelModules = [
            "virtio_balloon"
            "virtio_console"
            "virtio_rng"
            "virtio_gpu"
          ];
        };

        kernelModules = [ ];
        extraModulePackages = [ ];
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/540fdbde-2b58-4533-9d1d-c0358f154edf";
          fsType = "ext4";
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/F667-C8FB";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/175f9ebf-3e3d-474a-aebb-7574d5bb7b60"; }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };
}
