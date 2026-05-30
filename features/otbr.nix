# After importing this module, set services.openthread-border-router.backboneInterfaces
# and radio in host's nix file.
_: {
  flake.modules.features.otbr =
    { pkgs, ... }:
    {
      boot.kernelModules = [
        "ip6_tables"
        "ip6table_filter"
        "ip6table_mangle"
        "ip6table_raw"
        "ip_set"
        "ip_set_hash_net"
        "xt_set"
      ];

      boot.kernel.sysctl = {
        "net.ipv6.conf.all.accept_ra" = 2;
        "net.ipv6.conf.default.accept_ra" = 2;
      };

      networking.firewall = {
        allowedTCPPorts = [ 5684 ];
        allowedUDPPorts = [ 5683 ];
      };

      networking.networkmanager.unmanaged = [
        "interface-name:wpan0"
      ];

      services.avahi.openFirewall = true;
      services.openthread-border-router = {
        enable = true;
        rest = {
          listenPort = 8081;
        };
        web = {
          enable = true;
          listenPort = 8082;
        };
        interfaceName = "wpan0";
      };
      services.matter-server = {
        enable = true;
        extraArgs = { };
      };
      systemd.services.matter-server.path = [
        pkgs.local.chip-ota-provider-app
      ];
    };
}
