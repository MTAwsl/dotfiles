_: {
  flake.modules.features.disable-wifi =
    { pkgs, ... }:
    {
      systemd.services.disable-wifi-on-boot = {
        description = "Disable Wi-Fi on boot leaving Bluetooth intact";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.util-linux}/bin/rfkill block wifi";
          RemainAfterExit = true;
        };
      };
    };
}
