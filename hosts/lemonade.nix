{ self, ... }:
{
  flake.modules.hosts.lemonade =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    let
      users = self.lib.getHostUsers self.modules.users [ "yuri" ];
      inherit (users) yuri;
    in
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ]
      ++ (with self.modules.features; [
        # Home Manager
        home-manager

        # Services
        sshd

        # Host Features
        no-root-passwd
        yubikey
        lanzaboote
        nvidia
        docker
        qemu-host
        network
        veracrypt

        # Ram Optimisation
        earlyoom
        zram

        # Controller
        xpad
      ])
      # Import host profiles.
      ++ (with self.modules.profiles; [
        base
        desktop
      ])
      # Import user profiles.
      ++ (with yuri.profiles; [
        base
        desktop
      ])
      # Import host-specific user layout modules.
      ++ (with yuri.kanshiLayouts; [
        lemonade
      ]);

      # Host specific settings.

      # Uncomment this to test for docker.
      # users.users.yuri.extraGroups = [ "docker" ];

      environment.etc.crypttab.text = ''
        luks-data UUID=f24bb1b4-5204-4e57-ab7a-87a3ef751126 /root/data.key
        luks-swap UUID=695b24b6-2263-42dc-9db5-1a2545fe8675 /root/swap.key
      '';

      system.stateVersion = "26.05";

      # Network settings
      networking.hostName = "Yuri-Lemonade";

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

      boot = {
        initrd = {
          luks.devices.luks-root = {
            device = "/dev/disk/by-uuid/25a3784d-03b9-41c1-a156-cc0676ca9c85";
            crypttabExtraOpts = [ "fido2-device=auto" ];
          };

          compressor = "zstd";
          compressorArgs = [
            "-19"
            "-T0"
          ];
          availableKernelModules = [
            "xhci_pci"
            "ahci"
            "nvme"
            "usbhid"
            "usb_storage"
            "sd_mod"
          ];
          kernelModules = [
            "thunderbolt"
          ];
        };

        kernelModules = [
          "lenovo-legion-module"
          "kvm-intel"
        ];

        extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];
        extraModprobeConfig = "options kvm_intel nested=1";
        kernelPackages = pkgs.linuxPackages; # LTS
        kernelParams = [ ];
        loader.systemd-boot.configurationLimit = 3;
      };

      # Hardware specific packages.
      environment.systemPackages = with pkgs; [
        lenovo-legion
      ];

      # I agree with Linus.
      # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/483
      # hardware.nvidia.power-limit = 60; # Limit maximum power draw to 60W to prevent overheating.

      services.logind.settings.Login = {
        HandleLidSwitchExternalPower = "ignore";
      };

      fileSystems = {
        "/" = {
          device = "/dev/mapper/luks-root";
          fsType = "ext4";
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/EB49-40F3";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };

        "/mnt/data" = {
          device = "/dev/mapper/luks-data";
          fsType = "ext4";
        };
      };

      swapDevices = [
        { device = "/dev/mapper/luks-swap"; }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      hardware.enableRedistributableFirmware = true;
      hardware.cpu.intel.updateMicrocode = true;

      nix = {
        settings = {
          max-jobs = 8;
          cores = 0; # Auto-detect
        };
      };

      security.lockKernelModules = true;
    };
}
