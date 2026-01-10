{ ... }:
{
  flake.modules.nixos.plymouth = { pkgs, ... }:
  {
    boot = {
      plymouth = {
        enable = true;
        theme = "mac-style";
        themePackages = [ pkgs.mac-style-plymouth ];
      };

      # Enable "Silent boot"
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];

      # Hide the OS choice for bootloaders.
      # Press any key to open OS seletion menu.
      loader.timeout = 0;
    };
  };
}
