_: {
  flake.modules.features.veracrypt = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ veracrypt ];
  };
}
