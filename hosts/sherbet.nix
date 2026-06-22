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
        argononeLogLevel = 4; # WARNING
        argononeSettings = {
          fanTemp0 = 55;
          fanSpeed0 = 10;
          fanTemp1 = 60;
          fanSpeed1 = 55;
          fanTemp2 = 65;
          fanSpeed2 = 100;
          hysteresis = 3;
        };
        argononePackage = pkgs.callPackage (inputs.argononed + "/OS/nixos/pkg.nix") {
          logLevel = argononeLogLevel;
        };
        argononeFanConfig = lib.concatStringsSep " " (
          map toString (
            with argononeSettings;
            [
              fanSpeed0
              fanSpeed1
              fanSpeed2
              fanTemp0
              fanTemp1
              fanTemp2
              hysteresis
            ]
          )
        );
        users = self.lib.getHostUsers self.modules.users [
          "yuri"
          "deployer"
        ];
      inherit (users) yuri deployer;
    in
    {
      nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";

      imports =
        [
          inputs.nixos-hardware.nixosModules.raspberry-pi-4
        ]
        ++ (with self.modules.features; [
          home-manager
          sshd
          network
          nginx
          no-root-passwd
          msgraph-health-sentinel
          anthropic-readings
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

      hardware.raspberry-pi."4" = {
        bluetooth.enable = true;
        fkms-3d.enable = true;
        apply-overlays-dtmerge.enable = true;
      };

      hardware.raspberry-pi.configtxt.settings.all.dtparam = lib.mkAfter [ "i2c_arm=on" ];

      hardware.deviceTree.filter = "bcm2711-rpi-4*.dtb";

      # argononed daemon defaults (fan curve: 10%@55°C, 55%@60°C, 100%@65°C, hysteresis 3°C)
      environment.systemPackages = [ argononePackage ];

      hardware.deviceTree.overlays = [
        {
          name = "argonone";
          dtboFile = "${argononePackage}/share/argonone/boot/overlays/argonone.dtbo";
        }
        {
          name = "argonone-enable-overlay";
          dtsText = ''
            /dts-v1/;
            /plugin/;
            / {
              compatible = "brcm,bcm2711";
              fragment@0 {
                target-path = "/argonone";
                __overlay__ {
                  argonone-cfg = /bits/ 8 <${argononeFanConfig}>;
                };
              };
            };
          '';
        }
      ];

      systemd = {
        services.argononed = {
          enable = true;
          after = [ "multi-user.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "Argon ONE Fan and Button Daemon Service";

          serviceConfig = {
            Type = "forking";
            ExecStart = "${argononePackage}/sbin/argononed";
            PIDFile = "/run/argononed.pid";
            Restart = "on-failure";
          };
        };

        shutdown.argonone = "${argononePackage}/lib/systemd/system-shutdown/argonone-shutdown";
      };

      services.logrotate.settings.argononed = {
        files = toString /var/log/argononed.log;
        rotate = 2;
        frequency = "daily";
        create = "660 root root";
        missingok = true;
        notifempty = true;
        compress = true;
        delaycompress = true;
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

        openthread-border-router = {
          radio.device = "/dev/serial/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usbv2-0:1.4:1.0";
          backboneInterfaces = [ "end0" ];
        };

        nginx.virtualHosts = {
          _ = {
            default = true;
            addSSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:8123";
              proxyWebsockets = true;
            };
            sslCertificate = "/var/lib/secrets/nginx.crt";
            sslCertificateKey = "/var/lib/secrets/nginx.key";
          };

          ${homeAssistantHost} = {
            addSSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:8123";
              proxyWebsockets = true;
            };
            sslCertificate = "/var/lib/secrets/nginx.crt";
            sslCertificateKey = "/var/lib/secrets/nginx.key";
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
