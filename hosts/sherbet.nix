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
      onedriveIndexHost = "drive.sherbet.lan";
      fireflyPublicRoot = "${config.services.firefly-iii.package}/public";
      fireflyPhpSocket = config.services.phpfpm.pools.firefly-iii.socket;
      users = self.lib.getHostUsers self.modules.users [
        "yuri"
        "deployer"
      ];
      inherit (users) yuri deployer;
    in
    {
      imports = [
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
      ]
      ++ (with self.modules.features; [
        home-manager
        sshd
        network
        nginx
        no-root-passwd
        argon-fan-hat
        msgraph-health-sentinel
        anthropic-readings
        postgresql
        redis
        firefly-iii
        onedrive-index

        # Ram Optimisation
        earlyoom
        zram

        ssh-agent-auth
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
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

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

      hardware.raspberry-pi."4".i2c1.enable = true;

      hardware.argonFanHat = {
        enable = true;
        writeMethod = "raw";
      };

      networking.firewall.allowedTCPPorts = [ 80 ];

      services = {
        home-assistant.config.http = {
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
            "::1"
          ];
        };

        firefly-iii.settings.APP_URL = "http://${fireflyHost}";

        nginx.virtualHosts = {
          ${homeAssistantHost} = {
            locations."/" = {
              proxyPass = "http://127.0.0.1:8123";
              proxyWebsockets = true;
            };
          };

          ${fireflyHost} = {
            root = fireflyPublicRoot;
            extraConfig = ''
              index index.php;
            '';

            locations."/".extraConfig = ''
              try_files $uri $uri/ /index.php?$query_string;
            '';

            locations."~ \\.php$".extraConfig = ''
              include ${pkgs.nginx}/conf/fastcgi.conf;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_pass unix:${fireflyPhpSocket};
            '';
          };

          ${onedriveIndexHost} = {
            locations."/" = {
              proxyPass = "http://127.0.0.1:3000";
              proxyWebsockets = true;
            };
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
