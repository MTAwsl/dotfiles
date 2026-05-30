_: {
  flake.modules.features.network =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        nettools
      ];
      networking = {
        networkmanager = {
          enable = true;
          dhcp = "internal";
          wifi = {
            backend = "iwd";
            powersave = false; # Fix most of driver issues
          };

          # Temporarily disable IPV6 until my ISP finally thrilled to announce supports.
          # enableIPv6 = false;
          # settings = {
          #   connection = {
          #     "ipv6.method" = "auto";
          #   };
          # };
        };
      };

      # The bluetooth device is ready to pair.
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General = {
          Experimental = true;
          FastConnectable = true;
        };
      };
    };
}
