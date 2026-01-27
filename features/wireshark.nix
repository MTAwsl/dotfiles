{ ... }:
{
  flake.modules.nixos.wireshark =
    { ... }:
    {
      programs.wireshark = {
        enable = true;
        dumpcap.enable = true;
        usbmon.enable = true;
      };

      users.groups.wireshark = { };
    };
}
