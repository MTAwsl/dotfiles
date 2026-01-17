{ self, ... }:
{
  flake.modules.nixos."host-Yuri-Lemonade" =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ]
      ++ (with self.modules.nixos; [
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

      # Host specific settings.
      users.users.yuri.extraGroups = [ "docker" ];
      home-manager.users.yuri = {
        imports = with self.lib.withPrefix "yuri" self.modules.homeManager; [
          kanshi-lemonade
        ];
      };

      boot.initrd.luks.devices = {
        luks-root = {
          device = "/dev/disk/by-uuid/25a3784d-03b9-41c1-a156-cc0676ca9c85";
          crypttabExtraOpts = [ "fido2-device=auto" ];
        };
      };

      environment.etc.crypttab.text = ''
        luks-swap UUID=695b24b6-2263-42dc-9db5-1a2545fe8675 /root/swap.key
      '';

      system.stateVersion = "26.05";

      # Network settings
      networking.hostName = "Yuri-Lemonade";
      networking.networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };

      # The bluetooth device is ready to pair.
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

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
          "i915"
          "thunderbolt"
        ];
      };

      boot.extraModulePackages = [ ];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
      boot.kernelModules = [ "kvm-intel" ];
      boot.kernelParams = [ "i915.enable_guc=2" ];
      boot.loader.systemd-boot.configurationLimit = 3;

      services.logind.settings.Login = {
        HandleLidSwitchExternalPower = "ignore";
      };

      fileSystems."/" = {
        device = "/dev/mapper/luks-root";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/EB49-40F3";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        { device = "/dev/mapper/luks-swap"; }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      hardware.enableRedistributableFirmware = true;
      hardware.cpu.intel.updateMicrocode = true;

      # Graphics
      hardware.nvidia.prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      # Intel
      hardware.graphics = {
        extraPackages = with pkgs; [
          intel-media-driver
          intel-compute-runtime-legacy1
        ];
      };

      services.xserver.videoDrivers = [
        "modesetting"
        "nvidia"
      ];
    };
}
