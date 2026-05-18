_: {
  flake.modules.features.nvidia =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.hardware.nvidia.power-limit = lib.mkOption {
        type = lib.types.int; # Once enabled, user must declare limit
        default = 0;
      };

      config = {
        systemd.services.nvidia-power-limit =
          let
            limit = config.hardware.nvidia.power-limit;
          in
          lib.mkIf (limit > 0) {
            description = "Set NVIDIA GPU Power Limit";
            wantedBy = [ "multi-user.target" ];
            after = [ "systemd-modules-load.service" ];

            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pl ${lib.toString limit}";
            };
          };

        boot = {
          initrd.kernelModules = [
            # All of these takes about 150M in initramrs
            # Just for a single monitor to lightup and prompt for LUKS password.
            # What can I say?
            "nvidia"
            "nvidia_modeset"
            "nvidia_uvm"
            "nvidia_drm"
          ];

          kernelModules = [ ];
          kernelParams = [
            "nvidia-drm.modeset=1"
            "nvidia-drm.fbdev=1"
            "acpi_backlight=video"
          ];
        };

        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.nvidia = {
          open = true;
          modesetting.enable = true;
          powerManagement.enable = true;
          dynamicBoost.enable = false;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = [ pkgs.nvidia-vaapi-driver ];
        };

        environment.variables = {
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          LIBVA_DRIVER_NAME = "nvidia";
          VDPAU_DRIVER = "nvidia";
          NVD_BACKEND = "direct";
        };
      };
    };
}
