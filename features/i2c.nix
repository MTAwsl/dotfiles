_: {
  flake.modules.features.i2c =
    { pkgs, ... }:
    {
      hardware.i2c.enable = true;
      environment.systemPackages = with pkgs; [
        i2c-tools
      ];
    };
}
