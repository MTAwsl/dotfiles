{ ... }:
{
  flake.modules.nixos.network =
    { ... }:
    {
      networking = {
        enableIPv6 = true;
        networkmanager = {
          enable = true;
          dhcp = "internal";
          wifi = {
            backend = "iwd";
            powersave = false;
          };
          settings = {
            connection = {
              "ipv6.method" = "auto";
            };
          };
        };
      };

      # The bluetooth device is ready to pair.
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };
}
