_: {
  flake.modules.features.wireshark = _: {
    programs.wireshark = {
      enable = true;
      dumpcap.enable = true;
      usbmon.enable = true;
    };

    users.groups.wireshark = { };
  };
}
