{ self, ... }:
{
  flake.modules.nixos.nvidia =
    { config, pkgs, ... }:
    {
      boot.initrd.kernelModules = [
        # All of these takes about 150M in initramrs
        # Just for a single monitor to lightup and prompt for LUKS password.
        # What can I say?
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];

      boot.kernelModules = [ ];
      boot.kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia-drm.fbdev=1"
        "acpi_backlight=video"
      ];

      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        open = true;
        modesetting.enable = true;
        powerManagement.enable = true;
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
}
