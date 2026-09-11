_: {
  flake.modules.features.printer = { pkgs, ... }: {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
    };

    services.ipp-usb.enable = true;
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
    };
    services.udev.packages = [ pkgs.sane-airscan ];
  };
}
