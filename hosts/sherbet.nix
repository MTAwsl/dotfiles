{ inputs, self, ... }:
{
  flake.modules.hosts.sherbet =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      homeAssistantHost = "ha.sherbet.lan";
      fireflyHost = "firefly.sherbet.lan";
      fireflyImporterHost = "firefly-importer.sherbet.lan";
      fireflyPublicRoot = "${config.services.firefly-iii.package}/public";
      fireflyImporterPublicRoot = "${config.services.firefly-iii-data-importer.package}/public";
      fireflyPhpSocket = config.services.phpfpm.pools.firefly-iii.socket;
      fireflyImporterPhpSocket = config.services.phpfpm.pools.firefly-iii-data-importer.socket;
      users = self.lib.getHostUsers self.modules.users [
        "yuri"
        "deployer"
      ];
      inherit (users) yuri deployer;
    in
    {
      # Patches for nvmd/nixos-raspberrypi.
      _module.args.nixos-raspberrypi = inputs.nixos-raspberrypi;
      nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
      nixpkgs.overlays = with inputs.nixos-raspberrypi.overlays; [
        bootloader
        vendor-kernel
        vendor-firmware
        kernel-and-firmware
        vendor-pkgs
      ];

      imports =
        with inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4;
        [
          base
          bluetooth
          display-vc4
          case-argonone
        ]
        ++ (with self.modules.features; [
          home-manager
          sshd
          network
          nginx
          no-root-passwd
          msgraph-health-sentinel
          anthropic-readings
          postgresql
          firefly-iii
          home-assistant
          otbr

          # Ram Optimisation
          earlyoom
          zram

          # I2C
          i2c

          # Sudo Agent
          rssh

          # Disable Wifi (Software)
          disable-wifi
        ])
        ++ (with self.modules.profiles; [
          base
          server
        ])
        ++ (with yuri.profiles; [
          base
        ])
        ++ (with deployer.profiles; [
          base
        ]);

      networking.hostName = "Yuri-Sherbet";

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

      system.stateVersion = "26.05";

      boot.loader = {
        grub.enable = false;
        generic-extlinux-compatible = {
          enable = true;
          configurationLimit = 3;
          # Raspberry Pi U-Boot reads extlinux from the root filesystem's
          # /boot directory. Keep the firmware partition off /boot so
          # nixos-rebuild updates the booted generation instead of the FAT
          # firmware partition.
          mirroredBoots = [ { path = "/boot"; } ];
        };
      };

      # NRF52840 USB-UART dongle (CDC ACM serial)
      boot.kernelModules = [ "cdc_acm" ];

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/NIXOS_SD";
          fsType = "ext4";
          options = [ "noatime" ];
        };

        "/boot/firmware" = {
          device = "/dev/disk/by-label/FIRMWARE";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };
      };

      hardware.raspberry-pi.config.all.base-dt-params.i2c_arm = {
        enable = true;
        value = "on";
      };

      hardware.deviceTree.filter = "bcm2711-rpi-4*.dtb";

      # argononed daemon defaults (fan curve: 10%@55°C, 55%@60°C, 100%@65°C, hysteresis 3°C)
      services.argonone = {
        enable = true;
        logLevel = 4; # WARNING
        settings = {
          fanTemp0 = 55;
          fanSpeed0 = 10;
          fanTemp1 = 60;
          fanSpeed1 = 55;
          fanTemp2 = 65;
          fanSpeed2 = 100;
          hysteresis = 3;
        };
      };

      networking.firewall.allowedTCPPorts = [
        22
        53
        443

        # Apple Homekit integration
        21064
      ];
      networking.firewall.allowedUDPPorts = [
        53
      ];

      services = {
        home-assistant.config.http = {
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
            "::1"
          ];
        };

        firefly-iii.settings.APP_URL = "http://${fireflyHost}";

        openthread-border-router = {
          radio.device = "/dev/serial/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usbv2-0:1.4:1.0";
          backboneInterfaces = [ "end0" ];
        };

        nginx.virtualHosts = {
          _ = {
            default = true;
            onlySSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:8123";
              proxyWebsockets = true;
            };
            sslCertificate = "/var/lib/secrets/nginx.crt";
            sslCertificateKey = "/var/lib/secrets/nginx.key";
          };

          ${homeAssistantHost} = {
            onlySSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:8123";
              proxyWebsockets = true;
            };
            sslCertificate = "/var/lib/secrets/nginx.crt";
            sslCertificateKey = "/var/lib/secrets/nginx.key";
          };

          ${fireflyHost} = {
            root = fireflyPublicRoot;
            onlySSL = true;
            extraConfig = ''
              index index.php;
            '';

            sslCertificate = "/var/lib/secrets/nginx.crt";
            sslCertificateKey = "/var/lib/secrets/nginx.key";

            locations."/".extraConfig = ''
              try_files $uri $uri/ /index.php?$query_string;
              index index.php;
              sendfile off;
            '';

            locations."~ \\.php$".extraConfig = ''
              include ${pkgs.nginx}/conf/fastcgi.conf;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_pass unix:${fireflyPhpSocket};
            '';
          };

          ${fireflyImporterHost} = {
            root = fireflyImporterPublicRoot;
            onlySSL = true;
            extraConfig = ''
              index index.php;
            '';

            sslCertificate = "/var/lib/secrets/nginx.crt";
            sslCertificateKey = "/var/lib/secrets/nginx.key";

            locations."/".extraConfig = ''
              try_files $uri $uri/ /index.php?$query_string;
              index index.php;
              sendfile off;
            '';

            locations."~ \\.php$".extraConfig = ''
              include ${pkgs.nginx}/conf/fastcgi.conf;
              fastcgi_param SCRIPT_FILENAME $request_filename;
              fastcgi_param modHeadersAvailable true;
              fastcgi_pass unix:${fireflyImporterPhpSocket};
            '';
          };
        };
      };

      nix = {
        settings = {
          max-jobs = 2;
          cores = 2;
        };
      };

      security.lockKernelModules = true;
    };
}
